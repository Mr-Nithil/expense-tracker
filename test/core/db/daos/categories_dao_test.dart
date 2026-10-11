import 'package:drift/drift.dart' show Value;
import 'package:expense_tracker/core/db/app_database.dart';
import 'package:expense_tracker/core/utils/id.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_database.dart';

void main() {
  const userId = 'u1';
  final now = DateTime.utc(2026, 10, 10);

  late AppDatabase db;

  setUp(() => db = createTestDatabase());

  Future<String> insert({
    String name = 'Food',
    String type = 'expense',
    int sortOrder = 0,
    String user = userId,
    DateTime? deletedAt,
  }) async {
    final id = IdGenerator.newId();
    await db.categoriesDao.insertCategory(
      CategoriesCompanion.insert(
        id: id,
        userId: user,
        createdAt: now,
        updatedAt: now,
        name: name,
        icon: 'food',
        color: 0xFF4CAF50,
        type: type,
        sortOrder: Value(sortOrder),
        deletedAt: Value(deletedAt),
      ),
    );
    return id;
  }

  Future<void> insertTransaction(String categoryId, {DateTime? deletedAt}) => db
      .into(db.transactions)
      .insert(
        TransactionsCompanion.insert(
          id: IdGenerator.newId(),
          userId: userId,
          createdAt: now,
          updatedAt: now,
          type: 'expense',
          amountMinor: 100,
          categoryId: categoryId,
          occurredOn: DateTime(2026, 10, 10),
          deletedAt: Value(deletedAt),
        ),
      );

  test('watchActive orders by sort order then name and filters by type', () async {
    await insert(name: 'Transport', sortOrder: 1);
    await insert(name: 'Bills', sortOrder: 1);
    await insert(name: 'Food');
    await insert(name: 'Salary', type: 'income');

    final expense = await db.categoriesDao.watchActive(userId, type: 'expense').first;
    final all = await db.categoriesDao.watchActive(userId).first;

    expect(expense.map((c) => c.name), ['Food', 'Bills', 'Transport']);
    expect(all, hasLength(4));
  });

  test('archived and other users’ categories are not active', () async {
    await insert(name: 'Old', deletedAt: now);
    await insert(name: 'Theirs', user: 'u2');

    expect(await db.categoriesDao.watchActive(userId).first, isEmpty);
  });

  test('getById includes archived rows but not other users’', () async {
    final archived = await insert(deletedAt: now);
    final theirs = await insert(user: 'u2');

    expect(await db.categoriesDao.getById(userId, archived), isNotNull);
    expect(await db.categoriesDao.getById(userId, theirs), isNull);
  });

  test('activeNameExists is case-insensitive, per type, and can exclude a row', () async {
    final food = await insert();
    await insert(name: 'Gone', deletedAt: now);

    expect(await db.categoriesDao.activeNameExists(userId, 'expense', 'FOOD'), isTrue);
    expect(await db.categoriesDao.activeNameExists(userId, 'income', 'Food'), isFalse);
    expect(
      await db.categoriesDao.activeNameExists(userId, 'expense', 'food', excludeId: food),
      isFalse,
    );
    expect(await db.categoriesDao.activeNameExists(userId, 'expense', 'gone'), isFalse);
  });

  test('maxSortOrder ignores archived rows and is null when empty', () async {
    expect(await db.categoriesDao.maxSortOrder(userId, 'expense'), isNull);

    await insert(sortOrder: 3);
    await insert(sortOrder: 9, deletedAt: now);

    expect(await db.categoriesDao.maxSortOrder(userId, 'expense'), 3);
  });

  test('countActiveTransactions ignores deleted transactions', () async {
    final food = await insert();
    await insertTransaction(food);
    await insertTransaction(food, deletedAt: now);

    expect(await db.categoriesDao.countActiveTransactions(userId, food), 1);
  });

  test('updateCategory only touches the user’s own row', () async {
    final theirs = await insert(user: 'u2');

    final changed = await db.categoriesDao.updateCategory(
      userId,
      theirs,
      const CategoriesCompanion(name: Value('Hacked')),
    );

    expect(changed, 0);
  });
}
