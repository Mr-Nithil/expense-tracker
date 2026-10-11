import 'package:drift/drift.dart' show Value;
import 'package:expense_tracker/core/db/app_database.dart';
import 'package:expense_tracker/core/utils/id.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_database.dart';

void main() {
  const userId = 'u1';
  final now = DateTime.utc(2026, 10, 10, 12);
  final october = (from: DateTime(2026, 10), to: DateTime(2026, 11));

  late AppDatabase db;
  late String food;
  late String salary;

  Future<String> insertCategory(String name, String type, {String user = userId}) async {
    final id = IdGenerator.newId();
    await db.categoriesDao.insertCategory(
      CategoriesCompanion.insert(
        id: id,
        userId: user,
        createdAt: now,
        updatedAt: now,
        name: name,
        icon: 'food',
        color: 0,
        type: type,
      ),
    );
    return id;
  }

  setUp(() async {
    db = createTestDatabase();
    food = await insertCategory('Food', 'expense');
    salary = await insertCategory('Salary', 'income');
  });

  Future<String> insert({
    required DateTime on,
    String type = 'expense',
    int amount = 100,
    String? categoryId,
    String user = userId,
    DateTime? createdAt,
    DateTime? deletedAt,
  }) async {
    final id = IdGenerator.newId();
    await db.transactionsDao.insertTransaction(
      TransactionsCompanion.insert(
        id: id,
        userId: user,
        createdAt: createdAt ?? now,
        updatedAt: now,
        type: type,
        amountMinor: amount,
        categoryId: categoryId ?? (type == 'expense' ? food : salary),
        occurredOn: on,
        deletedAt: Value(deletedAt),
      ),
    );
    return id;
  }

  Future<List<String>> ids({String? type, String? categoryId}) async =>
      (await db.transactionsDao
              .watchFiltered(
                userId,
                from: october.from,
                to: october.to,
                type: type,
                categoryId: categoryId,
              )
              .first)
          .map((t) => t.id)
          .toList();

  test('includes the first day of the month and excludes the next month', () async {
    final first = await insert(on: DateTime(2026, 10));
    final last = await insert(on: DateTime(2026, 10, 31));
    await insert(on: DateTime(2026, 11));
    await insert(on: DateTime(2026, 9, 30));

    expect(await ids(), unorderedEquals([first, last]));
  });

  test('orders by date, then by entry time, newest first', () async {
    final early = await insert(on: DateTime(2026, 10, 3));
    final lateFirst = await insert(on: DateTime(2026, 10, 9), createdAt: now);
    final lateSecond = await insert(
      on: DateTime(2026, 10, 9),
      createdAt: now.add(const Duration(minutes: 5)),
    );

    expect(await ids(), [lateSecond, lateFirst, early]);
  });

  test('filters by type and category', () async {
    final expense = await insert(on: DateTime(2026, 10, 5));
    final income = await insert(on: DateTime(2026, 10, 5), type: 'income');

    expect(await ids(type: 'expense'), [expense]);
    expect(await ids(type: 'income'), [income]);
    expect(await ids(categoryId: salary), [income]);
  });

  test('deleted and other users’ transactions are not listed', () async {
    await insert(on: DateTime(2026, 10, 5), deletedAt: now);
    final otherCategory = await insertCategory('Theirs', 'expense', user: 'u2');
    await insert(on: DateTime(2026, 10, 5), user: 'u2', categoryId: otherCategory);

    expect(await ids(), isEmpty);
  });

  test('getById includes deleted rows but not other users’', () async {
    final deleted = await insert(on: DateTime(2026, 10, 5), deletedAt: now);
    final otherCategory = await insertCategory('Theirs', 'expense', user: 'u2');
    final theirs = await insert(on: DateTime(2026, 10, 5), user: 'u2', categoryId: otherCategory);

    expect(await db.transactionsDao.getById(userId, deleted), isNotNull);
    expect(await db.transactionsDao.getById(userId, theirs), isNull);
  });

  test('updateTransaction only touches the user’s own row', () async {
    final otherCategory = await insertCategory('Theirs', 'expense', user: 'u2');
    final theirs = await insert(on: DateTime(2026, 10, 5), user: 'u2', categoryId: otherCategory);

    final changed = await db.transactionsDao.updateTransaction(
      userId,
      theirs,
      const TransactionsCompanion(amountMinor: Value(1)),
    );

    expect(changed, 0);
  });

  group('watchMonthTotals', () {
    Future<({int incomeMinor, int expenseMinor})> totals() =>
        db.transactionsDao.watchMonthTotals(userId, DateTime(2026, 10, 20)).first;

    test('sums income and expenses of the month separately', () async {
      await insert(on: DateTime(2026, 10, 1), type: 'income', amount: 500000);
      await insert(on: DateTime(2026, 10, 5), amount: 1250);
      await insert(on: DateTime(2026, 10, 31), amount: 750);

      expect(await totals(), (incomeMinor: 500000, expenseMinor: 2000));
    });

    test('is zero for a month without transactions', () async {
      expect(await totals(), (incomeMinor: 0, expenseMinor: 0));
    });

    test('ignores deleted rows, other months and other users', () async {
      final otherFood = await insertCategory('Food', 'expense', user: 'u2');
      await insert(on: DateTime(2026, 10, 5), amount: 100);
      await insert(on: DateTime(2026, 10, 5), amount: 7, deletedAt: now);
      await insert(on: DateTime(2026, 9, 30), amount: 8);
      await insert(on: DateTime(2026, 11), amount: 9);
      await insert(on: DateTime(2026, 10, 5), amount: 10, user: 'u2', categoryId: otherFood);

      expect(await totals(), (incomeMinor: 0, expenseMinor: 100));
    });

    test('emits again when a transaction changes', () async {
      final id = await insert(on: DateTime(2026, 10, 5), amount: 100);
      final expenses = db.transactionsDao
          .watchMonthTotals(userId, DateTime(2026, 10))
          .map((t) => t.expenseMinor);

      final expectation = expectLater(expenses, emitsInOrder([100, 300, 0]));
      await pumpEventQueue();
      await db.transactionsDao.updateTransaction(
        userId,
        id,
        const TransactionsCompanion(amountMinor: Value(300)),
      );
      await pumpEventQueue();
      await db.transactionsDao.updateTransaction(
        userId,
        id,
        TransactionsCompanion(deletedAt: Value(now)),
      );
      await expectation;
    });
  });

  group('watchMonthSpendingByCategory', () {
    Future<List<({String categoryId, int spentMinor})>> spending() =>
        db.transactionsDao.watchMonthSpendingByCategory(userId, DateTime(2026, 10, 20)).first;

    test('sums expenses per category, largest first', () async {
      final rent = await insertCategory('Rent', 'expense');
      await insert(on: DateTime(2026, 10, 1), amount: 300);
      await insert(on: DateTime(2026, 10, 31), amount: 200);
      await insert(on: DateTime(2026, 10, 5), amount: 900, categoryId: rent);

      expect(await spending(), [
        (categoryId: rent, spentMinor: 900),
        (categoryId: food, spentMinor: 500),
      ]);
    });

    test('ignores income, deleted rows, other months and other users', () async {
      final otherFood = await insertCategory('Food', 'expense', user: 'u2');
      await insert(on: DateTime(2026, 10, 5), amount: 100);
      await insert(on: DateTime(2026, 10, 5), type: 'income', amount: 5000);
      await insert(on: DateTime(2026, 10, 5), amount: 7, deletedAt: now);
      await insert(on: DateTime(2026, 9, 30), amount: 8);
      await insert(on: DateTime(2026, 11), amount: 9);
      await insert(on: DateTime(2026, 10, 5), amount: 10, user: 'u2', categoryId: otherFood);

      expect(await spending(), [(categoryId: food, spentMinor: 100)]);
    });

    test('ties are ordered by category id', () async {
      final a = await insertCategory('A', 'expense');
      final b = await insertCategory('B', 'expense');
      await insert(on: DateTime(2026, 10, 5), amount: 100, categoryId: b);
      await insert(on: DateTime(2026, 10, 5), amount: 100, categoryId: a);

      final ids = [for (final row in await spending()) row.categoryId];
      expect(ids, [a, b]..sort());
    });

    test('is empty without expenses, and emits again when one is added', () async {
      expect(await spending(), isEmpty);

      final counts = db.transactionsDao
          .watchMonthSpendingByCategory(userId, DateTime(2026, 10))
          .map((rows) => rows.length);
      final expectation = expectLater(counts, emitsInOrder([0, 1]));
      await pumpEventQueue();
      await insert(on: DateTime(2026, 10, 5));
      await expectation;
    });
  });

}
