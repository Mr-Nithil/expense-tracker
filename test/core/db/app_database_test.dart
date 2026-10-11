import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart' show SqliteException;
import 'package:expense_tracker/core/db/app_database.dart';
import 'package:expense_tracker/core/db/tables/sync_columns.dart';
import 'package:expense_tracker/core/utils/id.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_database.dart';

void main() {
  late AppDatabase db;
  const userId = 'user-1';
  final now = DateTime.utc(2026, 10, 3, 12, 30, 15, 123);

  setUp(() => db = createTestDatabase());

  CategoriesCompanion category({String? id, String type = 'expense'}) => CategoriesCompanion.insert(
    id: id ?? IdGenerator.newId(),
    userId: userId,
    createdAt: now,
    updatedAt: now,
    name: 'Food',
    icon: 'food',
    color: 0xFF4CAF50,
    type: type,
  );

  TransactionsCompanion transaction({required String categoryId, int amountMinor = 1200}) =>
      TransactionsCompanion.insert(
        id: IdGenerator.newId(),
        userId: userId,
        createdAt: now,
        updatedAt: now,
        type: 'expense',
        amountMinor: amountMinor,
        categoryId: categoryId,
        occurredOn: DateTime(2026, 10, 3),
      );

  test('schema version is 1', () {
    expect(db.schemaVersion, 1);
  });

  test('new synced rows default to pending with no server timestamp or deletion', () async {
    final row = await db.into(db.categories).insertReturning(category());
    expect(row.syncStatus, SyncStatus.pending);
    expect(row.serverUpdatedAt, isNull);
    expect(row.deletedAt, isNull);
    expect(row.isDefault, isFalse);
  });

  test('timestamps keep millisecond precision (needed for last-write-wins)', () async {
    final row = await db.into(db.categories).insertReturning(category());
    expect(row.updatedAt.toUtc(), now);
  });

  test('date-only columns round-trip as yyyy-MM-dd text', () async {
    final categoryRow = await db.into(db.categories).insertReturning(category());
    final txn = await db
        .into(db.transactions)
        .insertReturning(transaction(categoryId: categoryRow.id));
    expect(txn.occurredOn, DateTime(2026, 10, 3));

    final raw = await db
        .customSelect(
          'SELECT occurred_on FROM transactions WHERE id = ?',
          variables: [
            Variable(txn.id),
          ],
        )
        .getSingle();
    expect(raw.read<String>('occurred_on'), '2026-10-03');
  });

  test('foreign keys are enforced', () async {
    expect(
      () => db.into(db.transactions).insert(transaction(categoryId: 'missing')),
      throwsA(isA<SqliteException>()),
    );
  });

  test('check constraints reject invalid values', () async {
    final categoryRow = await db.into(db.categories).insertReturning(category());
    expect(
      () =>
          db.into(db.transactions).insert(transaction(categoryId: categoryRow.id, amountMinor: 0)),
      throwsA(isA<SqliteException>()),
    );
    expect(
      () => db.into(db.categories).insert(category(type: 'transfer')),
      throwsA(isA<SqliteException>()),
    );
  });

  test('required indexes exist', () async {
    final rows = await db.customSelect("SELECT name FROM sqlite_master WHERE type = 'index'").get();
    final names = rows.map((r) => r.read<String>('name')).toSet();
    expect(
      names,
      containsAll([
        'transactions_user_occurred_idx',
        'transactions_category_idx',
        for (final table in [
          'profiles',
          'categories',
          'transactions',
          'budgets',
          'goals',
          'goal_contributions',
          'reminders',
        ])
          '${table}_sync_status_idx',
      ]),
    );
  });

  test('clearAllData empties every table', () async {
    final categoryRow = await db.into(db.categories).insertReturning(category());
    await db.into(db.transactions).insert(transaction(categoryId: categoryRow.id));
    await db.appSettingsDao.setValue('k', 'v');

    await db.clearAllData();

    for (final table in db.allTables) {
      final count = await db
          .customSelect('SELECT COUNT(*) AS c FROM ${table.actualTableName}')
          .getSingle();
      expect(count.read<int>('c'), 0, reason: table.actualTableName);
    }
  });

  group('countPendingRows', () {
    test('is 0 for an empty database', () async {
      expect(await db.countPendingRows(), 0);
    });

    test('counts pending rows across synced tables and ignores synced ones', () async {
      final food = await db.into(db.categories).insertReturning(category());
      await db
          .into(db.categories)
          .insert(
            category().copyWith(syncStatus: const Value(SyncStatus.synced)),
          );
      await db.into(db.transactions).insert(transaction(categoryId: food.id));
      await db
          .into(db.transactions)
          .insert(
            transaction(categoryId: food.id).copyWith(deletedAt: Value(now)),
          );
      await db.appSettingsDao.setValue('theme_mode', 'dark');

      expect(await db.countPendingRows(), 3);
    });
  });

  test('watchPendingCount follows inserts, syncs and pending deletes', () async {
    final counts = <int>[];
    final subscription = db.watchPendingCount().listen(counts.add);
    addTearDown(subscription.cancel);
    await pumpEventQueue();

    final food = await db.into(db.categories).insertReturning(category());
    await pumpEventQueue();
    await (db.update(db.categories)..where((c) => c.id.equals(food.id))).write(
      const CategoriesCompanion(syncStatus: Value(SyncStatus.synced)),
    );
    await pumpEventQueue();
    await (db.update(db.categories)..where((c) => c.id.equals(food.id))).write(
      CategoriesCompanion(deletedAt: Value(now), syncStatus: const Value(SyncStatus.pending)),
    );
    await pumpEventQueue();

    expect(counts, [0, 1, 0, 1]);
  });
}
