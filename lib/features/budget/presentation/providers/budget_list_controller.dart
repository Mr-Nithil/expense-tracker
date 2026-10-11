import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/utils/date_utils.dart';
import 'package:expense_tracker/features/budget/data/budget_repository_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'budget_list_controller.g.dart';

/// Budget tab actions. Returns the [Result] so the screen can say what happened. Kept alive
/// because it is only used from callbacks.
@Riverpod(keepAlive: true)
class BudgetListController extends _$BudgetListController {
  @override
  void build() {}

  /// Copies the previous month's budgets into [month]; the result is how many were copied.
  Future<Result<int>> copyPreviousMonth(DateTime month) => ref
      .read(budgetRepositoryProvider)
      .copyMonth(from: AppDateUtils.addMonths(AppDateUtils.monthStart(month), -1), to: month);
}
