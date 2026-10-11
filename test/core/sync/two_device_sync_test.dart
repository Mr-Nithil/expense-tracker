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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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
    final tables = syncableTables(db);
    sync = SyncService(
      pusher: SyncPusher(tables: tables, gateway: server),
      puller: SyncPuller(db: db, tables: tables, gateway: server),
      session: session,
    );
  }

  final AppDatabase db;
  late final SyncService sync;

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
}
