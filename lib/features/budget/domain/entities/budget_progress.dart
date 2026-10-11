import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/features/budget/domain/entities/budget.dart';
import 'package:expense_tracker/features/budget/domain/entities/budget_status.dart';
import 'package:expense_tracker/features/budget/domain/services/budget_calculator.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'budget_progress.freezed.dart';

/// A budget and what was spent against it in its month.
@freezed
abstract class BudgetProgress with _$BudgetProgress {
  const factory BudgetProgress({required Budget budget, required Money spent}) = _BudgetProgress;

  const BudgetProgress._();

  Money get remaining => BudgetCalculator.remaining(budget.limit, spent);

  int get percentUsed => BudgetCalculator.percentUsed(budget.limit, spent);

  double get fractionUsed => BudgetCalculator.fractionUsed(budget.limit, spent);

  BudgetStatus get status => BudgetCalculator.status(budget.limit, spent);
}
