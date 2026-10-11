import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/features/budget/domain/entities/budget.dart';
import 'package:expense_tracker/features/budget/domain/entities/budget_progress.dart';
import 'package:expense_tracker/features/budget/domain/entities/budget_status.dart';
import 'package:expense_tracker/features/budget/domain/services/budget_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const limit = Money(10000);

  group('remaining', () {
    test('is the limit minus spent', () {
      expect(BudgetCalculator.remaining(limit, const Money(2500)), const Money(7500));
    });

    test('is negative when over budget', () {
      expect(BudgetCalculator.remaining(limit, const Money(12000)), const Money(-2000));
    });
  });

  group('percentUsed', () {
    test('is a whole percent, rounded down', () {
      expect(BudgetCalculator.percentUsed(limit, Money.zero), 0);
      expect(BudgetCalculator.percentUsed(limit, const Money(7999)), 79);
      expect(BudgetCalculator.percentUsed(limit, const Money(8000)), 80);
      expect(BudgetCalculator.percentUsed(limit, const Money(9999)), 99);
      expect(BudgetCalculator.percentUsed(limit, limit), 100);
    });

    test('is not capped when over budget', () {
      expect(BudgetCalculator.percentUsed(limit, const Money(15000)), 150);
    });

    test('a tiny limit still works', () {
      expect(BudgetCalculator.percentUsed(const Money(1), const Money(3)), 300);
    });

    test('large amounts stay exact', () {
      const big = Money(900000000000000); // 9 trillion in cents
      expect(BudgetCalculator.percentUsed(big, const Money(720000000000000)), 80);
    });
  });

  group('fractionUsed', () {
    test('is spent over limit', () {
      expect(BudgetCalculator.fractionUsed(limit, const Money(2500)), 0.25);
    });

    test('is clamped to 1 when over budget', () {
      expect(BudgetCalculator.fractionUsed(limit, const Money(30000)), 1.0);
    });
  });

  group('status', () {
    BudgetStatus status(int spent) => BudgetCalculator.status(limit, Money(spent));

    test('is normal below 80%', () {
      expect(status(0), BudgetStatus.normal);
      expect(status(7999), BudgetStatus.normal);
    });

    test('is a warning from exactly 80% up to just below the limit', () {
      expect(status(8000), BudgetStatus.warning);
      expect(status(9999), BudgetStatus.warning);
    });

    test('is exceeded at the limit and above', () {
      expect(status(10000), BudgetStatus.exceeded);
      expect(status(25000), BudgetStatus.exceeded);
    });

    test('uses whole percents, so a tiny overshoot of 80% is still a warning', () {
      expect(BudgetCalculator.status(const Money(3), const Money(2)), BudgetStatus.normal);
      expect(BudgetCalculator.status(const Money(5), const Money(4)), BudgetStatus.warning);
    });
  });

  test('BudgetProgress exposes the calculations', () {
    final progress = BudgetProgress(
      budget: Budget(
        id: 'b',
        month: DateTime(2026, 10),
        limit: limit,
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
      ),
      spent: const Money(8500),
    );

    expect(progress.remaining, const Money(1500));
    expect(progress.percentUsed, 85);
    expect(progress.fractionUsed, 0.85);
    expect(progress.status, BudgetStatus.warning);
  });
}
