import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/features/budget/domain/entities/budget_status.dart';

/// Budget maths. [limit] is always positive (`BudgetValidator`); [spent] is never negative.
abstract final class BudgetCalculator {
  /// [percentUsed] from which a budget is [BudgetStatus.warning].
  static const warningPercent = 80;

  /// [percentUsed] from which a budget is [BudgetStatus.exceeded] (the limit is reached).
  static const exceededPercent = 100;

  /// What is left of [limit]. Negative when over budget.
  static Money remaining(Money limit, Money spent) => limit - spent;

  /// Whole percent of [limit] used, rounded down and not capped (150 when 1.5x over).
  ///
  /// Integer maths, so thresholds like 80% and 100% compare exactly.
  static int percentUsed(Money limit, Money spent) => spent.minor * 100 ~/ limit.minor;

  /// Share of [limit] used, clamped to `0..1`, for progress bars (a display ratio, not money).
  static double fractionUsed(Money limit, Money spent) =>
      (spent.minor / limit.minor).clamp(0.0, 1.0);

  /// Normal below [warningPercent], warning from it, exceeded from [exceededPercent].
  static BudgetStatus status(Money limit, Money spent) {
    final percent = percentUsed(limit, spent);
    if (percent >= exceededPercent) return BudgetStatus.exceeded;
    if (percent >= warningPercent) return BudgetStatus.warning;
    return BudgetStatus.normal;
  }
}
