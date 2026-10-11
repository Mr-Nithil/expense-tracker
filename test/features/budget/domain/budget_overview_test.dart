import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/features/budget/domain/entities/budget.dart';
import 'package:expense_tracker/features/budget/domain/entities/budget_overview.dart';
import 'package:expense_tracker/features/budget/domain/entities/budget_progress.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final at = DateTime.utc(2026, 10, 1);

  BudgetProgress progress(String id, {String? categoryId, int spent = 2500}) => BudgetProgress(
    budget: Budget(
      id: id,
      month: DateTime(2026, 10),
      categoryId: categoryId,
      limit: const Money(10000),
      createdAt: at,
      updatedAt: at,
    ),
    spent: Money(spent),
  );

  test('splits the overall budget from the category budgets, keeping their order', () {
    final overall = progress('overall');
    final food = progress('food', categoryId: 'food');
    final bills = progress('bills', categoryId: 'bills');

    final overview = BudgetOverview.fromProgress([food, overall, bills]);

    expect(overview.overall, overall);
    expect(overview.categories, [food, bills]);
    expect(overview.isEmpty, isFalse);
  });

  test('has no overall budget when only categories are set', () {
    final food = progress('food', categoryId: 'food');

    final overview = BudgetOverview.fromProgress([food]);

    expect(overview.overall, isNull);
    expect(overview.categories, [food]);
    expect(overview.isEmpty, isFalse);
  });

  test('is empty without budgets', () {
    expect(BudgetOverview.fromProgress(const []).isEmpty, isTrue);
    expect(BudgetOverview.fromProgress([progress('overall')]).isEmpty, isFalse);
  });

  group('mostUsedCategories', () {
    test('lists the most used first, up to the count, without the overall budget', () {
      final low = progress('low', categoryId: 'low', spent: 1000);
      final over = progress('over', categoryId: 'over', spent: 15000);
      final high = progress('high', categoryId: 'high', spent: 9000);
      final mid = progress('mid', categoryId: 'mid', spent: 5000);
      final overview = BudgetOverview.fromProgress([
        progress('overall', spent: 99999),
        low,
        over,
        high,
        mid,
      ]);

      expect(overview.mostUsedCategories(3), [over, high, mid]);
      expect(overview.mostUsedCategories(10), [over, high, mid, low]);
    });

    test('ties keep their order', () {
      final first = progress('a', categoryId: 'a', spent: 5000);
      final second = progress('b', categoryId: 'b', spent: 5000);

      expect(BudgetOverview(categories: [first, second]).mostUsedCategories(2), [first, second]);
    });

    test('is empty without category budgets', () {
      expect(const BudgetOverview().mostUsedCategories(3), isEmpty);
    });
  });
}
