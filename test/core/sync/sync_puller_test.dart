import 'package:drift/drift.dart' show Value;
import 'package:expense_tracker/core/db/app_database.dart';
import 'package:expense_tracker/core/db/tables/sync_columns.dart';
import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/sync/row_sealer.dart';
import 'package:expense_tracker/core/sync/sync_gateway.dart';
import 'package:expense_tracker/core/sync/sync_puller.dart';
import 'package:expense_tracker/core/sync/sync_registry.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_database.dart';

/// Rows "on the server", filtered and ordered like PostgREST does for `fetchChanges`.
class _FakeServer implements SyncGateway {
  final rows = <String, List<Map<String, Object?>>>{};
  final fetches = <(String table, DateTime? after, String? afterId)>[];
  int? failOnFetch;

  DateTime _stamp(Map<String, Object?> row) =>
      DateTime.parse(row['server_updated_at']! as String).toUtc();

  @override
  Future<Result<List<Map<String, Object?>>>> fetchChanges(
    String table, {
    DateTime? after,
    String? afterId,
    required int limit,
  }) async {
    fetches.add((table, after, afterId));
    if (failOnFetch == fetches.length) return const Result.failure(NetworkFailure('offline'));
    final matching =
        [
          for (final row in rows[table] ?? const <Map<String, Object?>>[])
            if (after == null ||
                _stamp(row).isAfter(after) ||
                (afterId != null &&
                    _stamp(row) == after &&
                    (row['id']! as String).compareTo(afterId) > 0))
              row,
        ]..sort((a, b) {
          final byStamp = _stamp(a).compareTo(_stamp(b));
          return byStamp != 0 ? byStamp : (a['id']! as String).compareTo(b['id']! as String);
        });
    return Result.success(matching.take(limit).toList());
  }

  @override
  Future<Result<void>> upsert(String table, List<Map<String, Object?>> rows) async => Result.ok;
}

void main() {
  const user = 'user-1';
  final base = DateTime.utc(2026, 10, 11, 9);

  late AppDatabase db;
  late _FakeServer server;

  setUp(() {
    db = createTestDatabase();
    server = _FakeServer();
  });

  SyncPuller puller({int pageSize = SyncPuller.defaultPageSize}) =>
      SyncPuller(db: db, tables: syncableTables(db), gateway: server, pageSize: pageSize);

  String iso(DateTime at) => at.toIso8601String().replaceFirst('Z', '+00:00');

  Map<String, Object?> categoryJson(
    String id, {
    required DateTime serverAt,
    String name = 'Food',
    DateTime? updatedAt,
    String userId = user,
  }) => {
    'id': id,
    'user_id': userId,
    'name': name,
    'icon': 'food',
    'color': 0,
    'type': 'expense',
    'is_default': false,
    'sort_order': 0,
    'created_at': iso(base),
    'updated_at': iso(updatedAt ?? base),
    'deleted_at': null,
    'server_updated_at': iso(serverAt),
  };

  Map<String, Object?> transactionJson(
    String id,
    String categoryId, {
    required DateTime serverAt,
  }) => {
    'id': id,
    'user_id': user,
    'type': 'expense',
    'amount_minor': 1250,
    'category_id': categoryId,
    'occurred_on': '2026-10-11',
    'note': null,
    'created_at': iso(base),
    'updated_at': iso(base),
    'deleted_at': null,
    'server_updated_at': iso(serverAt),
  };

  Future<DateTime?> cursor(String table) async => (await (db.select(
    db.syncState,
  )..where((s) => s.syncTable.equals(table))).getSingleOrNull())?.lastPulledAt;

  Future<List<String>> categoryIds() async =>
      [for (final c in await db.select(db.categories).get()) c.id]..sort();

  test('a first pull merges every table and sets each cursor to its newest row', () async {
    server.rows['categories'] = [
      categoryJson('food', serverAt: base.add(const Duration(seconds: 1))),
      categoryJson('bills', serverAt: base.add(const Duration(seconds: 3))),
    ];
    server.rows['transactions'] = [
      transactionJson('t1', 'food', serverAt: base.add(const Duration(seconds: 2))),
    ];

    final result = await puller().pull(user, sealer: RowSealer.none);

    expect(result.valueOrNull, 3);
    expect(await categoryIds(), ['bills', 'food']);
    expect((await db.transactionsDao.getById(user, 't1'))?.syncStatus, SyncStatus.synced);
    expect(await cursor('categories'), base.add(const Duration(seconds: 3)));
    expect(await cursor('transactions'), base.add(const Duration(seconds: 2)));
    expect(server.fetches.first, ('profiles', null, null));
  });

  test('pages through a large table by keyset without missing rows', () async {
    server.rows['categories'] = [
      for (var i = 0; i < 5; i++) categoryJson('c$i', serverAt: base.add(Duration(seconds: i))),
    ];

    await puller(pageSize: 2).pull(user, sealer: RowSealer.none);

    expect(await categoryIds(), ['c0', 'c1', 'c2', 'c3', 'c4']);
    final pages = server.fetches.where((f) => f.$1 == 'categories').toList();
    expect(pages, hasLength(3));
    expect(pages[1], ('categories', base.add(const Duration(seconds: 1)), 'c1'));
  });

  test('rows sharing a timestamp across a page boundary are not skipped', () async {
    final same = base.add(const Duration(seconds: 1));
    server.rows['categories'] = [
      for (final id in ['a', 'b', 'c']) categoryJson(id, serverAt: same),
    ];

    await puller(pageSize: 2).pull(user, sealer: RowSealer.none);

    expect(await categoryIds(), ['a', 'b', 'c']);
  });

  test(
    'the next pull starts at cursor minus the overlap, without duplicates or rewinding',
    () async {
      server.rows['categories'] = [categoryJson('food', serverAt: base)];
      await puller().pull(user, sealer: RowSealer.none);
      server.fetches.clear();
      // Committed late: its server time is before the cursor, but inside the overlap.
      server.rows['categories']!.add(
        categoryJson('late', serverAt: base.subtract(const Duration(seconds: 2))),
      );

      final result = await puller().pull(user, sealer: RowSealer.none);

      final first = server.fetches.firstWhere((f) => f.$1 == 'categories');
      expect(first.$2, base.subtract(SyncPuller.defaultOverlap));
      expect(await categoryIds(), ['food', 'late']);
      expect(result.valueOrNull, 2);
      expect(await cursor('categories'), base);
    },
  );

  test('a failure keeps merged pages and the next pull resumes from the cursor', () async {
    server.rows['categories'] = [
      for (var i = 0; i < 4; i++) categoryJson('c$i', serverAt: base.add(Duration(seconds: i))),
    ];
    // profiles is fetch 1, categories page 1 is fetch 2, page 2 is fetch 3.
    server.failOnFetch = 3;

    final failed = await puller(pageSize: 2).pull(user, sealer: RowSealer.none);

    expect(failed.failureOrNull, isA<NetworkFailure>());
    expect(await categoryIds(), ['c0', 'c1']);
    expect(await cursor('categories'), base.add(const Duration(seconds: 1)));

    server.failOnFetch = null;
    await puller(pageSize: 2).pull(user, sealer: RowSealer.none);
    expect(await categoryIds(), ['c0', 'c1', 'c2', 'c3']);
  });

  test('a newer pending local edit survives a pull (last-write-wins)', () async {
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            id: 'food',
            userId: user,
            createdAt: base,
            updatedAt: base.add(const Duration(minutes: 5)),
            name: 'Groceries',
            icon: 'food',
            color: 0,
            type: 'expense',
            syncStatus: const Value(SyncStatus.pending),
          ),
        );
    server.rows['categories'] = [
      categoryJson('food', serverAt: base.add(const Duration(seconds: 1)), name: 'Food'),
    ];

    await puller().pull(user, sealer: RowSealer.none);

    final local = await db.categoriesDao.getById(user, 'food');
    expect(local?.name, 'Groceries');
    expect(local?.syncStatus, SyncStatus.pending);
  });

  test('ignores other users’ rows', () async {
    server.rows['categories'] = [
      categoryJson('theirs', serverAt: base, userId: 'user-2'),
    ];

    final result = await puller().pull(user, sealer: RowSealer.none);

    expect(result.valueOrNull, 0);
    expect(await categoryIds(), isEmpty);
  });

  group('first pull', () {
    test('an empty server still completes the first pull (a new account)', () async {
      expect(await puller().hasCompletedFirstPull(), isFalse);

      final result = await puller().pull(user, sealer: RowSealer.none);

      expect(result.isSuccess, isTrue);
      expect(await puller().hasCompletedFirstPull(), isTrue);
      expect(await cursor('categories'), isNull);
    });

    test('a pull that failed halfway is not a completed first pull', () async {
      // profiles, then categories fails.
      server.failOnFetch = 2;

      await puller().pull(user, sealer: RowSealer.none);

      expect(await puller().hasCompletedFirstPull(), isFalse);
    });
  });

  test('a page that fails locally rolls back completely, rows and cursor', () async {
    server.rows['categories'] = [categoryJson('food', serverAt: base)];
    server.rows['transactions'] = [
      transactionJson('t1', 'food', serverAt: base.add(const Duration(seconds: 1))),
      // Its category doesn't exist: the local foreign key fails halfway through the page.
      transactionJson('t2', 'missing', serverAt: base.add(const Duration(seconds: 2))),
    ];

    final result = await puller().pull(user, sealer: RowSealer.none);

    expect(result.failureOrNull, isA<StorageFailure>());
    expect(await categoryIds(), ['food']);
    expect(await db.transactionsDao.getById(user, 't1'), isNull);
    expect(await cursor('transactions'), isNull);
    expect(await puller().hasCompletedFirstPull(), isFalse);
  });
}
