import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/utils/date_utils.dart';
import 'package:expense_tracker/core/utils/id.dart';
import 'package:expense_tracker/core/utils/money.dart';

/// Budget rules that need no database, and the budget id. The repository adds the category checks.
abstract final class BudgetValidator {
  /// Budgets can be planned ahead, but not for years ahead (a typo).
  static const maxMonthsAhead = 12;

  static final earliestMonth = DateTime(2000);

  static DateTime latestMonth(DateTime today) =>
      AppDateUtils.addMonths(AppDateUtils.monthStart(today), maxMonthsAhead);

  static const limitField = 'limit';
  static const monthField = 'month';
  static const categoryField = 'categoryId';

  /// `ValidationFailure.message` reasons, shared by the repository and the form.
  static const limitNotPositive = 'limitNotPositive';
  static const monthOutOfRange = 'monthOutOfRange';
  static const categoryNotFound = 'categoryNotFound';
  static const categoryArchived = 'categoryArchived';
  static const categoryNotExpense = 'categoryNotExpense';

  /// Key part used for the overall budget (no category) in [idFor].
  static const overallKey = 'overall';

  /// The id of the budget for ([userId], month of [month], [categoryId]).
  ///
  /// Deterministic (UUID v5), so the same budget set on two devices offline is one row after
  /// sync (last write wins) instead of two. Never change the key format: existing ids depend on it.
  static String idFor({required String userId, required DateTime month, String? categoryId}) =>
      IdGenerator.deterministic([
        userId,
        AppDateUtils.toIsoDate(AppDateUtils.monthStart(month)),
        categoryId ?? overallKey,
      ]);

  /// The first problem found, or `null` when valid. [today] comes from the injected clock.
  static ValidationFailure? validate({
    required Money limit,
    required DateTime month,
    required DateTime today,
  }) {
    if (!limit.isPositive) {
      return const ValidationFailure(limitNotPositive, field: limitField);
    }
    return validateMonth(month, today: today);
  }

  /// `monthOutOfRange` unless [month] is between [earliestMonth] and [latestMonth].
  static ValidationFailure? validateMonth(DateTime month, {required DateTime today}) {
    final start = AppDateUtils.monthStart(month);
    if (start.isBefore(earliestMonth) || start.isAfter(latestMonth(today))) {
      return const ValidationFailure(monthOutOfRange, field: monthField);
    }
    return null;
  }
}
