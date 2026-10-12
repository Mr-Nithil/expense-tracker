import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/features/budget/domain/entities/budget.dart';
import 'package:expense_tracker/features/budget/domain/entities/budget_overview.dart';
import 'package:expense_tracker/features/budget/domain/entities/budget_progress.dart';
import 'package:expense_tracker/features/budget/domain/entities/budget_status.dart';
import 'package:expense_tracker/features/budget/domain/services/budget_alert_check.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  BudgetProgress progress(String id, int spent, {String? categoryId}) => BudgetProgress(
    budget: Budget(
      id: id,
      month: DateTime(2026, 10),
      categoryId: categoryId,
      limit: const Money(10000),
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    ),
    spent: Money(spent),
  );

  BudgetOverview overview({int overall = 0, int food = 0}) => BudgetOverview(
    overall: progress('overall', overall),
    categories: [progress('food', food, categoryId: 'food')],
  );

  List<(String, BudgetStatus)> alerts(Map<String, BudgetStatus>? before, BudgetOverview now) => [
    for (final alert in BudgetAlertCheck.crossings(before, now))
      (alert.progress.budget.id, alert.status),
  ];

  test('statuses lists every budget by id', () {
    expect(BudgetAlertCheck.statuses(overview(overall: 8500, food: 12000)), {
      'overall': BudgetStatus.warning,
      'food': BudgetStatus.exceeded,
    });
  });

  test('crossing 80% alerts as a warning, crossing 100% as exceeded', () {
    final before = BudgetAlertCheck.statuses(overview(overall: 7000, food: 9000));

    expect(alerts(before, overview(overall: 8000, food: 10000)), [
      ('overall', BudgetStatus.warning),
      ('food', BudgetStatus.exceeded),
    ]);
  });

  test('jumping from normal straight past 100% alerts once, as exceeded', () {
    final before = BudgetAlertCheck.statuses(overview());

    expect(alerts(before, overview(food: 15000)), [('food', BudgetStatus.exceeded)]);
  });

  test('staying in the same state or going down never alerts', () {
    final warning = BudgetAlertCheck.statuses(overview(overall: 8500, food: 12000));

    expect(alerts(warning, overview(overall: 9000, food: 13000)), isEmpty);
    expect(alerts(warning, overview(overall: 2000, food: 5000)), isEmpty);
  });

  test('nothing without a previous snapshot (the app just opened)', () {
    expect(alerts(null, overview(food: 15000)), isEmpty);
  });

  test('a budget not seen before is its own baseline', () {
    final before = {'overall': BudgetStatus.normal};

    expect(alerts(before, overview(food: 15000)), isEmpty);
  });

  test('ids are per budget, stable, and far above the reminder ids', () {
    expect(BudgetAlertIds.of('food'), BudgetAlertIds.of('food'));
    expect(BudgetAlertIds.of('food'), isNot(BudgetAlertIds.of('overall')));
    expect(BudgetAlertIds.of('food'), greaterThanOrEqualTo(1 << 28));
    expect(BudgetAlertIds.of('food'), lessThan((1 << 28) + (1 << 20)));
  });
}
