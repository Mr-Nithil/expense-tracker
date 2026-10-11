import 'package:drift/drift.dart' show Value;
import 'package:expense_tracker/core/db/app_database.dart';
import 'package:expense_tracker/core/db/tables/sync_columns.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/session/session.dart';
import 'package:expense_tracker/core/sync/sync_gateway.dart';
import 'package:expense_tracker/core/sync/sync_puller.dart';
import 'package:expense_tracker/core/sync/sync_pusher.dart';
import 'package:expense_tracker/core/sync/sync_registry.dart';
import 'package:expense_tracker/core/sync/sync_service.dart';
import 'package:expense_tracker/core/utils/clock.dart';
import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/features/goals/data/goal_repository_impl.dart';
import 'package:expense_tracker/features/goals/domain/entities/goal.dart';
import 'package:expense_tracker/features/goals/domain/entities/goal_contribution.dart';
import 'package:expense_tracker/features/goals/domain/goal_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_sync_trigger.dart';
import '../../helpers/test_database.dart';

const _user = 'user-1';

/// Supabase as the app sees it, including `0002_keep_newer_rows.sql`: an upsert older than the
/// stored row keeps the stored row, and every write stamps a fresh `server_updated_at`.
class _SharedServer implements SyncGateway {
  final _tables = <String, Map<String, Map<String, Object?>>>{};
  var _clock = DateTime.utc(2026, 10, 12, 12);

  String _stamp() {
    _clock = _clock.add(const Duration(milliseconds: 10));
    return _clock.toIso8601String().replaceFirst('Z', '+00:00');
  }

  static DateTime _time(Object? iso) => DateTime.parse(iso! as String).toUtc();

  Map<String, Object?>? row(String table, String id) => _tables[table]?[id];

  @override
  Future<Result<void>> upsert(String table, List<Map<String, Object?>> rows) async {
    final stored = _tables.putIfAbsent(table, () => {});
    for (final incoming in rows) {
      final id = incoming['id']! as String;
      final existing = stored[id];
      final keepExisting =
          existing != null && _time(incoming['updated_at']).isBefore(_time(existing['updated_at']));
      stored[id] = {...(keepExisting ? existing : incoming), 'server_updated_at': _stamp()};
    }
    return Result.ok;
  }

  @override
  Future<Result<List<Map<String, Object?>>>> fetchChanges(
    String table, {
    DateTime? after,
    String? afterId,
    required int limit,
  }) async {
    final rows =
        [
          for (final row in (_tables[table] ?? const {}).values)
            if (after == null ||
                _time(row['server_updated_at']).isAfter(after) ||
                (afterId != null &&
                    _time(row['server_updated_at']) == after &&
                    (row['id']! as String).compareTo(afterId) > 0))
              row,
        ]..sort((a, b) {
          final byStamp = _time(a['server_updated_at']).compareTo(_time(b['server_updated_at']));
          return byStamp != 0 ? byStamp : (a['id']! as String).compareTo(b['id']! as String);
        });
    return Result.success(rows.take(limit).toList());
  }
}

/// One phone: its own database and the real sync engine, signed in as [_user].
class _Device {
  _Device(_SharedServer server) : db = createTestDatabase() {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final session = container.read(sessionProvider.notifier)..set(const SessionUser(userId: _user));
    goals = GoalRepositoryImpl(
      dao: db.goalsDao,
      clock: FixedClock(DateTime(2026, 10, 12, 9)),
      session: session,
      syncTrigger: FakeSyncTrigger(),
    );
    final tables = syncableTables(db);
    sync = SyncService(
      pusher: SyncPusher(tables: tables, gateway: server),
      puller: SyncPuller(db: db, tables: tables, gateway: server),
      session: session,
    );
  }

  final AppDatabase db;
  late final SyncService sync;

  /// The real goals repository on this phone (M6.1).
  late final GoalRepository goals;

  /// A local write, as a repository makes it: pending, with this device's `updated_at`.
  Future<void> saveCategory(
    String id, {
    required String name,
    required DateTime at,
    DateTime? deletedAt,
  }) => db
      .into(db.categories)
      .insertOnConflictUpdate(
        CategoriesCompanion.insert(
          id: id,
          userId: _user,
          createdAt: DateTime.utc(2026, 10),
          updatedAt: at,
          deletedAt: Value(deletedAt),
          name: name,
          icon: 'food',
          color: 0,
          type: 'expense',
          syncStatus: const Value(SyncStatus.pending),
        ),
      );

  Future<CategoryRow?> category(String id) => db.categoriesDao.getById(_user, id);

  Future<void> syncOk() async {
    final result = await sync.run();
    expect(result.isSuccess, isTrue, reason: '$result');
  }
}

void main() {
  final t0 = DateTime.utc(2026, 10, 12, 9);
  final earlier = t0.add(const Duration(minutes: 1));
  final later = t0.add(const Duration(minutes: 2));

  late _SharedServer server;
  late _Device a;
  late _Device b;

  setUp(() {
    server = _SharedServer();
    a = _Device(server);
    b = _Device(server);
  });

  /// Both phones and the server agree on the row, and nothing is left pending.
  Future<void> expectConverged(String id, {required String name, bool deleted = false}) async {
    for (final (label, device) in [('A', a), ('B', b)]) {
      final row = await device.category(id);
      expect(row?.name, name, reason: 'name on $label');
      expect(row?.deletedAt != null, deleted, reason: 'deleted on $label');
      expect(row?.syncStatus, SyncStatus.synced, reason: 'status on $label');
    }
    expect(server.row('categories', id)?['name'], name);
  }

  test('a row created on one phone reaches the other', () async {
    await a.saveCategory('food', name: 'Food', at: t0);

    await a.syncOk();
    await b.syncOk();

    await expectConverged('food', name: 'Food');
  });

  group('both phones edit the same row offline: the newer edit wins', () {
    setUp(() async {
      await a.saveCategory('food', name: 'Food', at: t0);
      await a.syncOk();
      await b.syncOk();
      await a.saveCategory('food', name: 'Groceries (A, earlier)', at: earlier);
      await b.saveCategory('food', name: 'Food & drink (B, later)', at: later);
    });

    test('when the older edit syncs first', () async {
      await a.syncOk();
      await b.syncOk();
      await a.syncOk();

      await expectConverged('food', name: 'Food & drink (B, later)');
    });

    test('when the newer edit syncs first', () async {
      await b.syncOk();
      await a.syncOk();
      await b.syncOk();

      await expectConverged('food', name: 'Food & drink (B, later)');
    });
  });

  group('delete vs edit', () {
    setUp(() async {
      await a.saveCategory('food', name: 'Food', at: t0);
      await a.syncOk();
      await b.syncOk();
    });

    test('a newer delete beats an older edit', () async {
      await b.saveCategory('food', name: 'Groceries', at: earlier);
      await a.saveCategory('food', name: 'Food', at: later, deletedAt: later);

      await b.syncOk();
      await a.syncOk();
      await b.syncOk();

      await expectConverged('food', name: 'Food', deleted: true);
    });

    test('a newer edit beats an older delete (the row comes back)', () async {
      await a.saveCategory('food', name: 'Food', at: earlier, deletedAt: earlier);
      await b.saveCategory('food', name: 'Groceries', at: later);

      await a.syncOk();
      await b.syncOk();
      await a.syncOk();

      await expectConverged('food', name: 'Groceries');
    });
  });

  test('a newer pending edit survives a pull, then wins on the server', () async {
    await a.saveCategory('food', name: 'Food', at: t0);
    await a.syncOk();
    await b.syncOk();
    await a.saveCategory('food', name: 'Groceries (A, earlier)', at: earlier);
    await a.syncOk();
    await b.saveCategory('food', name: 'Food & drink (B, later)', at: later);

    // B's pull sees A's older edit: B keeps its own newer pending one, then pushes it.
    await b.syncOk();
    await a.syncOk();

    await expectConverged('food', name: 'Food & drink (B, later)');
  });

  group('goals and contributions', () {
    test('a goal and its contributions reach the other phone with the same saved total', () async {
      final goal = (await a.goals.create(
        const GoalDraft(name: 'Laptop', target: Money(150000), icon: 'savings', color: 0),
      )).valueOrNull!;
      for (final amount in [3000, 2000]) {
        final result = await a.goals.addContribution(
          ContributionDraft(
            goalId: goal.id,
            amount: Money(amount),
            contributedOn: DateTime(2026, 10, 5),
          ),
        );
        expect(result.isSuccess, isTrue);
      }

      await a.syncOk();
      await b.syncOk();

      final onB = await b.goals.watchById(goal.id).first;
      expect(onB?.goal.name, 'Laptop');
      expect(onB?.saved, const Money(5000));
      expect(await b.goals.watchContributions(goal.id).first, hasLength(2));
      expect(server.row('goals', goal.id)?['target_minor'], 150000);
    });

    test('deleting a goal on one phone removes it and its contributions on the other', () async {
      final goal = (await a.goals.create(
        const GoalDraft(name: 'Bike', target: Money(40000), icon: 'sports', color: 0),
      )).valueOrNull!;
      final contribution = (await a.goals.addContribution(
        ContributionDraft(goalId: goal.id, amount: const Money(1000), contributedOn: t0),
      )).valueOrNull!;
      await a.syncOk();
      await b.syncOk();

      expect((await b.goals.delete(goal.id)).isSuccess, isTrue);
      await b.syncOk();
      await a.syncOk();

      expect(await a.goals.watchAll().first, isEmpty);
      expect(await a.goals.watchContributions(goal.id).first, isEmpty);
      expect((await a.db.goalsDao.getById(_user, goal.id))?.deletedAt, isNotNull);
      expect(
        (await a.db.goalsDao.getContributionById(_user, contribution.id))?.deletedAt,
        isNotNull,
      );
      expect(server.row('goal_contributions', contribution.id)?['deleted_at'], isNotNull);
    });
  });
}
