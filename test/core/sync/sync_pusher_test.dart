import 'package:drift/drift.dart' show Value;
import 'package:expense_tracker/core/db/app_database.dart';
import 'package:expense_tracker/core/db/tables/sync_columns.dart';
import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/sync/sync_gateway.dart';
import 'package:expense_tracker/core/sync/sync_pusher.dart';
import 'package:expense_tracker/core/sync/sync_registry.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_database.dart';

/// Records upserts; can fail a table or run code while a request is "in flight".
class _FakeGateway implements SyncGateway {
  final calls = <(String table, List<Map<String, Object?>> rows)>[];
  final failures = <String, AppFailure>{};
  Future<void> Function(String table)? duringUpsert;

  @override
  Future<Result<void>> upsert(String table, List<Map<String, Object?>> rows) async {
    calls.add((table, rows));
    await duringUpsert?.call(table);
    final failure = failures[table];
    return failure == null ? Result.ok : Result.failure(failure);
  }

  @override
  Future<Result<List<Map<String, Object?>>>> fetchChanges(
    String table, {
    DateTime? after,
    String? afterId,
    required int limit,
  }) async => const Result.success([]);
}

void main() {
  const user = 'user-1';
  final at = DateTime.utc(2026, 10, 11, 9);

  late AppDatabase db;
  late _FakeGateway gateway;

  setUp(() async {
    db = createTestDatabase();
    gateway = _FakeGateway();
  });

  SyncPusher pusher({int batchSize = SyncPusher.defaultBatchSize}) =>
      SyncPusher(tables: syncableTables(db), gateway: gateway, batchSize: batchSize);

  Future<void> category(String id, {String userId = user}) => db
      .into(db.categories)
      .insert(
        CategoriesCompanion.insert(
          id: id,
          userId: userId,
          createdAt: at,
          updatedAt: at,
          name: id,
          icon: 'food',
          color: 0,
          type: 'expense',
        ),
      );

  Future<void> transaction(String id, {String categoryId = 'food', DateTime? deletedAt}) => db
      .into(db.transactions)
      .insert(
        TransactionsCompanion.insert(
          id: id,
          userId: user,
          createdAt: at,
          updatedAt: at,
          deletedAt: Value(deletedAt),
          type: 'expense',
          amountMinor: 100,
          categoryId: categoryId,
          occurredOn: DateTime(2026, 10, 11),
        ),
      );

  Future<Map<String, SyncStatus>> statuses() async => {
    for (final c in await db.select(db.categories).get()) c.id: c.syncStatus,
    for (final t in await db.select(db.transactions).get()) t.id: t.syncStatus,
  };

  test('pushes tables in dependency order and marks the rows synced', () async {
    await category('food');
    await transaction('t1', categoryId: 'food');

    final result = await pusher().push(user);

    expect(result.valueOrNull, 2);
    expect(gateway.calls.map((c) => c.$1), ['categories', 'transactions']);
    expect(gateway.calls.last.$2.single['id'], 't1');
    expect((await statuses()).values, everyElement(SyncStatus.synced));
  });

  test('splits large tables into batches', () async {
    await category('food');
    for (var i = 0; i < 5; i++) {
      await transaction('t$i');
    }

    await pusher(batchSize: 2).push(user);

    final batches = gateway.calls.where((c) => c.$1 == 'transactions').map((c) => c.$2.length);
    expect(batches, [2, 2, 1]);
  });

  test('stops at the first failure and leaves the rest pending', () async {
    await category('food');
    await transaction('t1');
    gateway.failures['transactions'] = const NetworkFailure('offline');

    final result = await pusher().push(user);

    expect(result.failureOrNull, isA<NetworkFailure>());
    expect(gateway.calls.map((c) => c.$1), ['categories', 'transactions']);
    expect((await statuses()), {'food': SyncStatus.synced, 't1': SyncStatus.pending});
  });

  test('nothing pending means no requests', () async {
    final result = await pusher().push(user);

    expect(result.valueOrNull, 0);
    expect(gateway.calls, isEmpty);
  });

  test('only pushes the user’s own rows', () async {
    await category('mine');
    await category('theirs', userId: 'user-2');

    await pusher().push(user);

    expect(gateway.calls.single.$2.map((r) => r['id']), ['mine']);
  });

  test('pushes soft deletes', () async {
    await category('food');
    await transaction('t1', deletedAt: at);

    await pusher().push(user);

    final sent = gateway.calls.firstWhere((c) => c.$1 == 'transactions').$2.single;
    expect(sent['deleted_at'], at.toIso8601String());
  });

  test('a row edited while its batch is in flight stays pending', () async {
    await category('food');
    gateway.duringUpsert = (table) async {
      if (table == 'categories') {
        await db.categoriesDao.updateCategory(
          user,
          'food',
          CategoriesCompanion(
            name: const Value('Groceries'),
            updatedAt: Value(at.add(const Duration(seconds: 1))),
          ),
        );
      }
    };

    final result = await pusher().push(user);

    expect(result.valueOrNull, 0);
    expect((await statuses())['food'], SyncStatus.pending);
  });

  group('local failures', () {
    test('reading pending rows fails: nothing is sent', () async {
      await db.customStatement('DROP TABLE reminders');

      final result = await pusher().push(user);

      expect(result.failureOrNull, isA<StorageFailure>());
      expect(gateway.calls.map((c) => c.$1), isNot(contains('reminders')));
    });

    test('marking synced fails after the upsert: rows stay pending for the next run', () async {
      await category('food');
      // Break the local update that marks rows synced, after the server accepted them.
      gateway.duringUpsert = (table) async {
        await db.customStatement(
          'CREATE TRIGGER block_mark BEFORE UPDATE ON categories '
          "BEGIN SELECT RAISE(ABORT, 'disk full'); END",
        );
      };

      final result = await pusher().push(user);

      expect(result.failureOrNull, isA<StorageFailure>());
      expect(gateway.calls.single.$1, 'categories');
      await db.customStatement('DROP TRIGGER block_mark');
      expect((await statuses())['food'], SyncStatus.pending);
    });
  });
}
