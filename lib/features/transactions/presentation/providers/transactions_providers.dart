import 'package:expense_tracker/core/session/session.dart';
import 'package:expense_tracker/core/utils/clock.dart';
import 'package:expense_tracker/core/utils/date_utils.dart';
import 'package:expense_tracker/features/transactions/data/transaction_repository_provider.dart';
import 'package:expense_tracker/features/transactions/domain/entities/day_totals.dart';
import 'package:expense_tracker/features/transactions/domain/entities/month_totals.dart';
import 'package:expense_tracker/features/transactions/domain/entities/spending_breakdown.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction.dart';
import 'package:expense_tracker/features/transactions/domain/services/transaction_grouping.dart';
import 'package:expense_tracker/features/transactions/domain/services/transaction_validator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show ProviderListenableSelect;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'transactions_providers.g.dart';

/// What the transactions tab shows: one month, optionally narrowed by type and category.
/// Starts at the current month, unfiltered, and resets when the signed-in user changes.
@Riverpod(keepAlive: true)
class TransactionFilterController extends _$TransactionFilterController {
  @override
  TransactionFilter build() {
    ref.watch(sessionProvider.select((user) => user?.userId));
    return TransactionFilter(month: AppDateUtils.monthStart(ref.watch(clockProvider).now()));
  }

  /// Months that can hold transactions (`TransactionValidator`'s date range), as first days.
  static ({DateTime first, DateTime last}) monthBounds(DateTime today) => (
    first: AppDateUtils.monthStart(TransactionValidator.earliestDate),
    last: AppDateUtils.monthStart(TransactionValidator.latestDate(today)),
  );

  void setMonth(DateTime month) {
    final bounds = monthBounds(ref.read(clockProvider).now());
    var target = AppDateUtils.monthStart(month);
    if (target.isBefore(bounds.first)) target = bounds.first;
    if (target.isAfter(bounds.last)) target = bounds.last;
    state = state.copyWith(month: target);
  }

  void previousMonth() => setMonth(AppDateUtils.addMonths(state.month, -1));

  void nextMonth() => setMonth(AppDateUtils.addMonths(state.month, 1));

  /// `null` shows both types. Changing the type drops the category (it belonged to the old type).
  void setType(TransactionType? type) {
    if (type == state.type) return;
    state = state.copyWith(type: type, categoryId: null);
  }

  void setCategory(String? categoryId) => state = state.copyWith(categoryId: categoryId);

  /// Removes type and category, keeping the month.
  void clearFilters() => state = TransactionFilter(month: state.month);
}

/// Non-deleted transactions matching [filter], newest first. Re-subscribes for a new user.
@riverpod
Stream<List<Transaction>> transactions(Ref ref, TransactionFilter filter) {
  ref.watch(sessionProvider.select((user) => user?.userId));
  return ref.watch(transactionRepositoryProvider).watch(filter);
}

/// [transactionsProvider] grouped into newest-first days with subtotals.
@riverpod
AsyncValue<List<TransactionDay>> transactionDays(Ref ref, TransactionFilter filter) =>
    ref.watch(transactionsProvider(filter)).whenData(groupTransactionsByDay);

/// Income and expense totals of the month containing [month]. Re-subscribes for a new user.
@riverpod
Stream<MonthTotals> monthTotals(Ref ref, DateTime month) {
  ref.watch(sessionProvider.select((user) => user?.userId));
  return ref.watch(transactionRepositoryProvider).watchMonthTotals(month);
}

/// Expenses of the month containing [month] by category, largest first, the tail folded into
/// "Other". Re-subscribes for a new user.
@riverpod
Stream<SpendingBreakdown> spendingBreakdown(Ref ref, DateTime month) {
  ref.watch(sessionProvider.select((user) => user?.userId));
  return ref
      .watch(transactionRepositoryProvider)
      .watchMonthSpendingByCategory(month)
      .map(SpendingBreakdown.of);
}

/// Income and expenses per day of the month containing [month], keyed by day (local midnight) in
/// date order. A day without transactions has no entry. Re-subscribes for a new user.
@riverpod
Stream<Map<DateTime, DayTotals>> monthDailyTotals(Ref ref, DateTime month) {
  ref.watch(sessionProvider.select((user) => user?.userId));
  return ref
      .watch(transactionRepositoryProvider)
      .watchMonthDailyTotals(month)
      .map((days) => {for (final day in days) day.date: day});
}

/// One transaction, including a soft-deleted one (`isDeleted`). Re-subscribes for a new user.
@riverpod
Stream<Transaction?> transactionById(Ref ref, String id) {
  ref.watch(sessionProvider.select((user) => user?.userId));
  return ref.watch(transactionRepositoryProvider).watchById(id);
}
