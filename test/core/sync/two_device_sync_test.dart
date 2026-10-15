import 'package:drift/drift.dart' show Value;
import 'package:expense_tracker/core/crypto/data_key_service.dart';
import 'package:expense_tracker/core/crypto/row_cipher.dart';
import 'package:expense_tracker/core/db/app_database.dart';
import 'package:expense_tracker/core/db/tables/sync_columns.dart';
import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/session/session.dart';
import 'package:expense_tracker/core/sync/row_resealer.dart';
import 'package:expense_tracker/core/sync/row_sealer.dart';
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
import 'package:expense_tracker/features/reminders/data/reminder_repository_impl.dart';
import 'package:expense_tracker/features/reminders/domain/entities/reminder.dart';
import 'package:expense_tracker/features/reminders/domain/reminder_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_data_key_gateway.dart';
import '../../helpers/fake_secure_storage.dart';
import '../../helpers/fake_sync_trigger.dart';
import '../../helpers/test_database.dart';

const _user = 'user-1';

/// Supabase as the app sees it, including `0002_keep_newer_rows.sql`: an upsert older than the
/// stored row keeps the stored row, and every write stamps a fresh `server_updated_at`.
class _SharedServer implements SyncGateway {
  /// The `user-key` function: one key per user, shared by both phones.
  final keys = FakeKeyServer();

  final _tables = <String, Map<String, Map<String, Object?>>>{};
  var _clock = DateTime.utc(2026, 10, 12, 12);

  String _stamp() {
    _clock = _clock.add(const Duration(milliseconds: 10));
    return _clock.toIso8601String().replaceFirst('Z', '+00:00');
  }

  static DateTime _time(Object? iso) => DateTime.parse(iso! as String).toUtc();

  Map<String, Object?>? row(String table, String id) => _tables[table]?[id];

  Iterable<Map<String, Object?>> get allRows => _tables.values.expand((rows) => rows.values);

  /// The stored row with its private columns decrypted with the user's key, as a phone sees it.
  Future<Map<String, Object?>?> opened(String table, String id) async {
    final stored = row(table, id);
    if (stored == null) return null;
    final payload = stored[RowSealer.payloadColumn] as String?;
    if (payload == null) return stored;
    final fields = await RowCipher(
      keys.keyOf(_user),
    ).open(payload, table: table, id: id, userId: _user);
    return {...stored, ...fields};
  }

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
    reminders = ReminderRepositoryImpl(
      dao: db.remindersDao,
      clock: FixedClock(DateTime(2026, 10, 12, 9)),
      session: session,
      syncTrigger: FakeSyncTrigger(),
    );
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
      dataKeys: DataKeyService(
        storage: FakeSecureStorage(),
        gateway: server.keys.gatewayFor(() => _user),
      ),
      resealer: RowResealer(db: db, tables: tables),
    );
  }

  final AppDatabase db;
  late final SyncService sync;

  /// The real goals repository on this phone (M6.1).
  late final GoalRepository goals;

  /// The real reminders repository on this phone (M8.2).
  late final ReminderRepository reminders;

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
    expect((await server.opened('categories', id))?['name'], name);
  }

  test('the server stores private columns only sealed', () async {
    await a.saveCategory('food', name: 'Secret groceries', at: t0);
    final goal = (await a.goals.create(
      const GoalDraft(name: 'Hidden laptop', target: Money(150000), icon: 'savings', color: 0),
    )).valueOrNull!;
    await a.goals.addContribution(
      ContributionDraft(
        goalId: goal.id,
        amount: const Money(4321),
        contributedOn: DateTime(2026, 10, 1),
        note: 'birthday money',
      ),
    );

    await a.syncOk();

    final stored = server.allRows.map((row) => row.toString()).join('\n');
    for (final secret in [
      'Secret groceries',
      'Hidden laptop',
      '150000',
      '4321',
      'birthday money',
    ]) {
      expect(stored, isNot(contains(secret)), reason: secret);
    }
    final category = server.row('categories', 'food')!;
    expect(category['name'], isNull);
    expect(category[RowSealer.payloadColumn], startsWith('v1.'));
    // Not private: still readable for sync and RLS.
    expect(category['type'], 'expense');
    expect(category['user_id'], _user);
  });

  test(
    'a row sealed for another row cannot be opened: the pull fails and nothing is skipped',
    () async {
      await a.saveCategory('food', name: 'Food', at: t0);
      await a.saveCategory('rent', name: 'Rent', at: t0);
      await a.syncOk();
      // Someone swaps the payloads on the server.
      final food = server.row('categories', 'food')!;
      final rent = server.row('categories', 'rent')!;
      final swapped = food[RowSealer.payloadColumn];
      food[RowSealer.payloadColumn] = rent[RowSealer.payloadColumn];
      rent[RowSealer.payloadColumn] = swapped;

      final result = await b.sync.run();

      expect(result.failureOrNull, isA<UnexpectedFailure>());
      expect(await b.category('food'), isNull);
    },
  );

  test(
    'an agent change arrives marked; a user edit marks it as the user\'s again (M10.14)',
    () async {
      // The agent service writes a sealed category, marked as its change.
      final payload = await RowCipher(
        server.keys.keyOf(_user),
      ).seal({'name': 'Coffee'}, table: 'categories', id: 'coffee', userId: _user);
      server._tables.putIfAbsent('categories', () => {})['coffee'] = {
        'id': 'coffee',
        'user_id': _user,
        'name': null,
        'payload_enc': payload,
        'icon': 'coffee',
        'color': 0,
        'type': 'expense',
        'is_default': false,
        'sort_order': 0,
        'created_at': t0.toIso8601String(),
        'updated_at': t0.toIso8601String(),
        'deleted_at': null,
        'created_by': 'agent',
        'updated_by': 'agent',
        'agent_proposal_id': 'proposal-1',
        'server_updated_at': server._stamp(),
      };

      await b.syncOk();
      final pulled = (await b.category('coffee'))!;
      expect(pulled.name, 'Coffee');
      expect(
        (pulled.createdBy, pulled.updatedBy, pulled.agentProposalId),
        ('agent', 'agent', 'proposal-1'),
      );

      await b.saveCategory('coffee', name: 'Coffee & tea', at: t0.add(const Duration(hours: 1)));
      await b.syncOk();

      final stored = server.row('categories', 'coffee')!;
      expect(
        (stored['created_by'], stored['updated_by'], stored['agent_proposal_id']),
        ('agent', 'user', null),
      );
      expect((await server.opened('categories', 'coffee'))?['name'], 'Coffee & tea');
    },
  );

  group('re-encrypting existing data (M11.7)', () {
    /// A row stored in plain text, as before M11 (or by an old app version).
    void storePlain(String id, String name, DateTime at) =>
        server._tables.putIfAbsent('categories', () => {})[id] = {
          'id': id,
          'user_id': _user,
          'name': name,
          'icon': 'food',
          'color': 0,
          'type': 'expense',
          'is_default': false,
          'sort_order': 0,
          'created_at': '2026-10-01T00:00:00.000Z',
          'updated_at': at.toIso8601String(),
          'deleted_at': null,
          'server_updated_at': server._stamp(),
        };

    test('plain rows already on the server are sealed by the next phone that syncs', () async {
      storePlain('food', 'Food', t0);

      await b.syncOk();

      expect((await b.category('food'))?.name, 'Food');
      final stored = server.row('categories', 'food')!;
      expect(stored['name'], isNull);
      expect(stored[RowSealer.payloadColumn], startsWith('v1.'));
      expect(stored['updated_at'], t0.toIso8601String(), reason: 'same version, only sealed');
      expect((await b.category('food'))?.syncStatus, SyncStatus.synced);

      await a.syncOk();
      expect((await a.category('food'))?.name, 'Food');
    });

    test('rows synced in plain text before the update are re-uploaded sealed, once', () async {
      // Synced before M11: on the phone as synced, on the server in plain text.
      await a.saveCategory('rent', name: 'Rent', at: t0);
      storePlain('rent', 'Rent', t0);
      await a.db.customStatement('UPDATE categories SET sync_status = ${SyncStatus.synced.index}');

      await a.syncOk();

      expect(server.row('categories', 'rent')!['name'], isNull);
      expect((await server.opened('categories', 'rent'))?['name'], 'Rent');
      expect(await a.db.appSettingsDao.getValue(RowResealer.flagKey), _user);
    });
  });

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
      expect((await server.opened('goals', goal.id))?['target_minor'], 150000);
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

  group('reminders', () {
    test('weekly and monthly reminders reach the other phone unchanged', () async {
      final weekly = (await a.reminders.create(
        const ReminderDraft(
          title: 'Log expenses',
          time: ReminderTime(hour: 20, minute: 30),
          repeat: ReminderRepeat.weekly,
          weekdays: {DateTime.monday, DateTime.thursday},
        ),
      )).valueOrNull!;
      final monthly = (await a.reminders.create(
        const ReminderDraft(
          title: 'Pay rent',
          time: ReminderTime(hour: 9, minute: 0),
          repeat: ReminderRepeat.monthly,
          dayOfMonth: 31,
        ),
      )).valueOrNull!;

      await a.syncOk();
      await b.syncOk();

      final onB = {for (final r in await b.reminders.watchAll().first) r.id: r};
      expect(onB[weekly.id]?.weekdays, {DateTime.monday, DateTime.thursday});
      expect(onB[weekly.id]?.time, const ReminderTime(hour: 20, minute: 30));
      expect(onB[monthly.id]?.dayOfMonth, 31);
      expect(server.row('reminders', monthly.id)?['day_of_month'], 31);
    });

    test('turning a reminder off on one phone reaches the other', () async {
      final reminder = (await a.reminders.create(
        const ReminderDraft(
          title: 'Log expenses',
          time: ReminderTime(hour: 20, minute: 0),
          repeat: ReminderRepeat.daily,
        ),
      )).valueOrNull!;
      await a.syncOk();
      await b.syncOk();

      expect((await b.reminders.setEnabled(reminder.id, enabled: false)).isSuccess, isTrue);
      await b.syncOk();
      await a.syncOk();

      expect((await a.reminders.watchById(reminder.id).first)?.enabled, isFalse);
    });
  });
}
