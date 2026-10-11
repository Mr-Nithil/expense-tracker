import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/features/budget/domain/entities/budget.dart';
import 'package:expense_tracker/features/budget/domain/entities/budget_progress.dart';

/// The signed-in user's monthly budgets, in the local DB (synced later).
///
/// Writes validate input (see `BudgetValidator`, plus: the category must exist, be an expense
/// category and not be archived unless the budget already exists) and fail with
/// `ValidationFailure`, `NotFoundFailure`, `AuthFailure` (no session) or `StorageFailure`.
/// They never throw.
abstract interface class BudgetRepository {
  /// Non-deleted budgets of the month containing [month], the overall budget first.
  Stream<List<Budget>> watchMonth(DateTime month);

  /// [watchMonth] with each budget's spending in that month (all expenses for the overall
  /// budget, the category's for a category budget). Updates when transactions change.
  Stream<List<BudgetProgress>> watchMonthProgress(DateTime month);

  /// Creates or updates the budget for ([month], [categoryId]); a null [categoryId] is the overall
  /// budget. A previously deleted budget for the same key is restored with the new [limit].
  Future<Result<Budget>> set({required DateTime month, String? categoryId, required Money limit});

  /// Copies the budgets of the month containing [from] into the month containing [to], with the
  /// same limits. Budgets [to] already has are kept as they are; categories that are archived or
  /// gone are skipped. Returns how many budgets were copied (0 when there was nothing to copy).
  Future<Result<int>> copyMonth({required DateTime from, required DateTime to});

  /// Soft delete.
  Future<Result<void>> delete(String id);
}
