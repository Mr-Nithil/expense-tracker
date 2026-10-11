import 'package:expense_tracker/core/session/session.dart';
import 'package:expense_tracker/core/utils/clock.dart';
import 'package:expense_tracker/core/utils/date_utils.dart';
import 'package:expense_tracker/features/budget/data/budget_repository_provider.dart';
import 'package:expense_tracker/features/budget/domain/entities/budget_overview.dart';
import 'package:expense_tracker/features/budget/domain/services/budget_validator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show ProviderListenableSelect;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'budget_providers.g.dart';

/// The month the budget tab shows, as its first day. Starts at the current month and resets when
/// the signed-in user changes.
@Riverpod(keepAlive: true)
class BudgetMonthController extends _$BudgetMonthController {
  @override
  DateTime build() {
    ref.watch(sessionProvider.select((user) => user?.userId));
    return AppDateUtils.monthStart(ref.watch(clockProvider).now());
  }

  /// Months that can hold budgets (`BudgetValidator`'s range), as first days.
  static ({DateTime first, DateTime last}) monthBounds(DateTime today) =>
      (first: BudgetValidator.earliestMonth, last: BudgetValidator.latestMonth(today));

  void setMonth(DateTime month) {
    final bounds = monthBounds(ref.read(clockProvider).now());
    var target = AppDateUtils.monthStart(month);
    if (target.isBefore(bounds.first)) target = bounds.first;
    if (target.isAfter(bounds.last)) target = bounds.last;
    state = target;
  }

  void previousMonth() => setMonth(AppDateUtils.addMonths(state, -1));

  void nextMonth() => setMonth(AppDateUtils.addMonths(state, 1));
}

/// The budgets of the month containing [month] with their spending. Updates when budgets or
/// transactions change; re-subscribes for a new user.
@riverpod
Stream<BudgetOverview> budgetOverview(Ref ref, DateTime month) {
  ref.watch(sessionProvider.select((user) => user?.userId));
  return ref
      .watch(budgetRepositoryProvider)
      .watchMonthProgress(month)
      .map(BudgetOverview.fromProgress);
}
