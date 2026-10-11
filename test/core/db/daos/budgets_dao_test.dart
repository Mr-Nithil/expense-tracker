import 'package:drift/drift.dart' show Value;
import 'package:expense_tracker/core/db/app_database.dart';
import 'package:expense_tracker/core/utils/id.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_database.dart';

void main() {
  const userId = 'u1';
  final now = DateTime.utc(2026, 10, 10, 12);

  late AppDatabase db;
  late String food;

  setUp(() async {
    db = createTestDatabase();
    food = IdGenerator.newId();
    await db.categoriesDao.insertCategory(
      CategoriesCompanion.insert(
        id: food,
        userId: userId,
        createdAt: now,
        updatedAt: now,
        name: 'Food',
        icon: 'food',
        color: 0,
        type: 'expense',
      ),
    );
  });

  Future<String> insert({
    String user = userId,
    DateTime? month,
    String? categoryId,
    DateTime? createdAt,
    bool deleted = false,
  }) async {
    final id = IdGenerator.newId();
    await db.budgetsDao.insertBudget(
      BudgetsCompanion.insert(
        id: id,
        userId: user,
        createdAt: createdAt ?? now,
        updatedAt: now,
        month: month ?? DateTime(2026, 10),
        categoryId: Value(categoryId),
        limitMinor: 1000,
        deletedAt: Value(deleted ? now : null),
      ),
    );
    return id;
  }

  test('watchMonth lists the overall budget first, then categories by creation', () async {
    final category = await insert(
      categoryId: food,
      createdAt: now.subtract(const Duration(days: 1)),
    );
    final overall = await insert();

    final rows = await db.budgetsDao.watchMonth(userId, DateTime(2026, 10, 20)).first;

    expect(rows.map((r) => r.id), [overall, category]);
  });

  test('watchMonth skips deleted rows, other months and other users', () async {
    final kept = await insert();
    await insert(deleted: true, categoryId: food);
    await insert(month: DateTime(2026, 9));
    await insert(user: 'u2');

    final rows = await db.budgetsDao.watchMonth(userId, DateTime(2026, 10)).first;

    expect(rows.map((r) => r.id), [kept]);
  });

  test('getMonth reads the same rows as watchMonth, once', () async {
    final category = await insert(categoryId: food);
    final overall = await insert(createdAt: now.add(const Duration(days: 1)));
    await insert(deleted: true, month: DateTime(2026, 10));
    await insert(month: DateTime(2026, 9));
    await insert(user: 'u2');

    final rows = await db.budgetsDao.getMonth(userId, DateTime(2026, 10, 31));

    expect(rows.map((r) => r.id), [overall, category]);
  });

  test('getById includes deleted rows and is scoped to the user', () async {
    final id = await insert(deleted: true);

    expect((await db.budgetsDao.getById(userId, id))?.deletedAt, isNotNull);
    expect(await db.budgetsDao.getById('u2', id), isNull);
  });

  test('updateBudget only touches the user\'s row', () async {
    final id = await insert();

    expect(
      await db.budgetsDao.updateBudget('u2', id, const BudgetsCompanion(limitMinor: Value(5))),
      0,
    );
    expect(
      await db.budgetsDao.updateBudget(userId, id, const BudgetsCompanion(limitMinor: Value(5))),
      1,
    );
    expect((await db.budgetsDao.getById(userId, id))!.limitMinor, 5);
  });

  group('watchMonthWithSpent', () {
    late String rent;

    setUp(() async {
      rent = IdGenerator.newId();
      await db.categoriesDao.insertCategory(
        CategoriesCompanion.insert(
          id: rent,
          userId: userId,
          createdAt: now,
          updatedAt: now,
          name: 'Rent',
          icon: 'home',
          color: 0,
          type: 'expense',
        ),
      );
    });

    /// Adds a transaction and returns its id.
    Future<String> spend(
      int amount, {
      String? categoryId,
      DateTime? on,
      String type = 'expense',
      String user = userId,
      bool deleted = false,
    }) async {
      if (user != userId) {
        // Other users need their own category (foreign key).
        categoryId = IdGenerator.newId();
        await db.categoriesDao.insertCategory(
          CategoriesCompanion.insert(
            id: categoryId,
            userId: user,
            createdAt: now,
            updatedAt: now,
            name: 'Other',
            icon: 'food',
            color: 0,
            type: 'expense',
          ),
        );
      }
      final id = IdGenerator.newId();
      await db.transactionsDao.insertTransaction(
        TransactionsCompanion.insert(
          id: id,
          userId: user,
          createdAt: now,
          updatedAt: now,
          type: type,
          amountMinor: amount,
          categoryId: categoryId ?? food,
          occurredOn: on ?? DateTime(2026, 10, 15),
          deletedAt: Value(deleted ? now : null),
        ),
      );
      return id;
    }

    Future<void> edit(String id, TransactionsCompanion changes) async =>
        expect(await db.transactionsDao.updateTransaction(userId, id, changes), 1);

    Future<Map<String?, int>> spentByCategory() async {
      final rows = await db.budgetsDao.watchMonthWithSpent(userId, DateTime(2026, 10)).first;
      return {for (final row in rows) row.budget.categoryId: row.spentMinor};
    }

    test('overall counts every expense, a category budget only its own', () async {
      await insert();
      await insert(categoryId: food);
      await insert(categoryId: rent);
      await spend(100);
      await spend(250);
      await spend(1000, categoryId: rent);

      expect(await spentByCategory(), {null: 1350, food: 350, rent: 1000});
    });

    test('ignores income, deleted rows, other months and other users', () async {
      await insert();
      await spend(100);
      await spend(5000, type: 'income');
      await spend(7, deleted: true);
      await spend(8, on: DateTime(2026, 9, 30));
      await spend(9, on: DateTime(2026, 11));
      await spend(10, user: 'u2');

      expect(await spentByCategory(), {null: 100});
    });

    test('includes the first and last day of the month', () async {
      await insert();
      await spend(1, on: DateTime(2026, 10));
      await spend(2, on: DateTime(2026, 10, 31));

      expect(await spentByCategory(), {null: 3});
    });

    test('is zero without spending, and skips deleted budgets', () async {
      await insert();
      await insert(categoryId: food, deleted: true);

      expect(await spentByCategory(), {null: 0});
    });

    test('emits again when a transaction is added', () async {
      await insert();
      final stream = db.budgetsDao.watchMonthWithSpent(userId, DateTime(2026, 10));
      final spent = stream.map((rows) => rows.single.spentMinor);

      final expectation = expectLater(spent, emitsInOrder([0, 400]));
      await pumpEventQueue();
      await spend(400);
      await expectation;
    });

    test('an archived category still counts, for the overall and its own budget', () async {
      await insert();
      await insert(categoryId: food);
      await spend(300);
      await db.categoriesDao.updateCategory(
        userId,
        food,
        CategoriesCompanion(deletedAt: Value(now)),
      );

      expect(await spentByCategory(), {null: 300, food: 300});
    });

    test('follows edits: amount, category, month and soft delete', () async {
      await insert();
      await insert(categoryId: food);
      await insert(categoryId: rent);
      final id = await spend(400);
      expect(await spentByCategory(), {null: 400, food: 400, rent: 0});

      await edit(id, const TransactionsCompanion(amountMinor: Value(500)));
      expect(await spentByCategory(), {null: 500, food: 500, rent: 0});

      await edit(id, TransactionsCompanion(categoryId: Value(rent)));
      expect(await spentByCategory(), {null: 500, food: 0, rent: 500});

      await edit(id, TransactionsCompanion(occurredOn: Value(DateTime(2026, 11, 2))));
      expect(await spentByCategory(), {null: 0, food: 0, rent: 0});

      await edit(id, TransactionsCompanion(occurredOn: Value(DateTime(2026, 10, 2))));
      await edit(id, TransactionsCompanion(deletedAt: Value(now)));
      expect(await spentByCategory(), {null: 0, food: 0, rent: 0});
    });

    test('emits again when a transaction is edited or deleted', () async {
      await insert();
      final id = await spend(400);
      final spent = db.budgetsDao
          .watchMonthWithSpent(userId, DateTime(2026, 10))
          .map((rows) => rows.single.spentMinor);

      final expectation = expectLater(spent, emitsInOrder([400, 650, 0]));
      await pumpEventQueue();
      await edit(id, const TransactionsCompanion(amountMinor: Value(650)));
      await pumpEventQueue();
      await edit(id, TransactionsCompanion(deletedAt: Value(now)));
      await expectation;
    });
  });
}
