import 'package:expense_tracker/core/session/session.dart';
import 'package:expense_tracker/core/utils/clock.dart';
import 'package:expense_tracker/core/utils/date_utils.dart';
import 'package:expense_tracker/features/transactions/presentation/providers/transactions_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show ProviderListenableSelect;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dashboard_providers.g.dart';

/// The month the dashboard shows, as its first day. Its own month (not shared with other tabs):
/// starts at the current month and resets when the signed-in user changes.
@Riverpod(keepAlive: true)
class DashboardMonthController extends _$DashboardMonthController {
  @override
  DateTime build() {
    ref.watch(sessionProvider.select((user) => user?.userId));
    return AppDateUtils.monthStart(ref.watch(clockProvider).now());
  }

  /// Months that can hold transactions, as first days (same as the transactions tab).
  static ({DateTime first, DateTime last}) monthBounds(DateTime today) =>
      TransactionFilterController.monthBounds(today);

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
