import 'package:drift/drift.dart' show Value;
import 'package:expense_tracker/core/db/app_database.dart';
import 'package:expense_tracker/core/session/session.dart';
import 'package:expense_tracker/core/utils/clock.dart';
import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/features/budget/data/budget_repository_provider.dart';
import 'package:expense_tracker/features/budget/presentation/providers/budget_providers.dart';
import 'package:expense_tracker/features/transactions/data/transaction_repository_provider.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/test_database.dart';

void main() {
  final now = DateTime(2026, 10, 11, 15, 45);
  final october = DateTime(2026, 10);

  late AppDatabase db;
  late ProviderContainer container;

  setUp(() async {
    db = createTestDatabase();
    container = createTestContainer(
      db: db,
      overrides: [clockProvider.overrideWithValue(FixedClock(now))],
    );
    container.read(sessionProvider.notifier).set(const SessionUser(userId: 'u1'));
    await db.categoriesDao.insertCategory(
      CategoriesCompanion.insert(
        id: 'food',
        userId: 'u1',
        createdAt: now.toUtc(),
        updatedAt: now.toUtc(),
        name: 'Food',
        icon: 'food',
        color: 0,
        type: 'expense',
        sortOrder: const Value(0),
      ),
    );
  });

  Future<void> setBudget(int limit, {String? categoryId}) async {
    final result = await container
        .read(budgetRepositoryProvider)
        .set(month: october, categoryId: categoryId, limit: Money(limit));
    expect(result.isSuccess, isTrue);
  }

  Future<void> spend(int amount) async {
    final result = await container
        .read(transactionRepositoryProvider)
        .create(
          TransactionDraft(
            type: TransactionType.expense,
            amount: Money(amount),
            categoryId: 'food',
            occurredOn: DateTime(2026, 10, 5),
          ),
        );
    expect(result.isSuccess, isTrue);
  }

  group('BudgetMonthController', () {
    BudgetMonthController controller() => container.read(budgetMonthControllerProvider.notifier);
    DateTime month() => container.read(budgetMonthControllerProvider);

    test('starts at the first day of the current month', () {
      expect(month(), october);
    });

    test('steps months across a year boundary', () {
      controller().setMonth(DateTime(2026, 1, 20));
      controller().previousMonth();
      expect(month(), DateTime(2025, 12));
      controller()
        ..nextMonth()
        ..nextMonth();
      expect(month(), DateTime(2026, 2));
    });

    test('clamps to the months that can hold budgets', () {
      controller().setMonth(DateTime(1999, 5));
      expect(month(), DateTime(2000));

      controller().setMonth(DateTime(2030));
      expect(month(), DateTime(2027, 10));
      controller().nextMonth();
      expect(month(), DateTime(2027, 10));
    });

    test('resets for a new user', () {
      container.listen(budgetMonthControllerProvider, (_, _) {});
      controller().previousMonth();

      container.read(sessionProvider.notifier).set(const SessionUser(userId: 'u2'));

      expect(month(), october);
    });
  });

  test('budgetOverview splits the month and follows spending', () async {
    container.listen(budgetOverviewProvider(october), (_, _) {});
    await setBudget(10000, categoryId: 'food');
    await setBudget(50000);
    await pumpEventQueue();

    var overview = await container.read(budgetOverviewProvider(october).future);
    expect(overview.overall?.budget.limit, const Money(50000));
    expect(overview.categories.single.budget.categoryId, 'food');

    await spend(2500);
    await pumpEventQueue();

    overview = await container.read(budgetOverviewProvider(october).future);
    expect(overview.overall?.spent, const Money(2500));
    expect(overview.categories.single.spent, const Money(2500));
  });

  test('budgetOverview re-subscribes for a different user', () async {
    container.listen(budgetOverviewProvider(october), (_, _) {});
    await setBudget(50000);
    await pumpEventQueue();
    expect((await container.read(budgetOverviewProvider(october).future)).isEmpty, isFalse);

    container.read(sessionProvider.notifier).set(const SessionUser(userId: 'u2'));
    await pumpEventQueue();

    expect((await container.read(budgetOverviewProvider(october).future)).isEmpty, isTrue);
  });
}
