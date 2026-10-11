import 'package:expense_tracker/core/session/session.dart';
import 'package:expense_tracker/core/utils/clock.dart';
import 'package:expense_tracker/core/utils/date_utils.dart';
import 'package:expense_tracker/features/transactions/presentation/providers/transactions_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show ProviderListenableSelect;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'calendar_providers.g.dart';

/// What the calendar shows: a month (its first day) and the selected day in it, if any.
typedef CalendarState = ({DateTime month, DateTime? selectedDay});

/// The calendar's own month (like the dashboard's) and selected day. Starts at the current month
/// with today selected, and resets when the signed-in user changes.
@Riverpod(keepAlive: true)
class CalendarController extends _$CalendarController {
  @override
  CalendarState build() {
    ref.watch(sessionProvider.select((user) => user?.userId));
    final today = _today();
    return (month: AppDateUtils.monthStart(today), selectedDay: today);
  }

  /// Months that can hold transactions, as first days (same as the transactions tab).
  static ({DateTime first, DateTime last}) monthBounds(DateTime today) =>
      TransactionFilterController.monthBounds(today);

  DateTime _today() => AppDateUtils.dateOnly(ref.read(clockProvider).now());

  /// Shows [month] (clamped to [monthBounds]); today is selected if it is in that month.
  void setMonth(DateTime month) {
    final today = _today();
    final bounds = monthBounds(today);
    var target = AppDateUtils.monthStart(month);
    if (target.isBefore(bounds.first)) target = bounds.first;
    if (target.isAfter(bounds.last)) target = bounds.last;
    state = (
      month: target,
      selectedDay: AppDateUtils.isSameMonth(today, target) ? today : null,
    );
  }

  /// Selects [day] and shows its month.
  void selectDay(DateTime day) {
    final date = AppDateUtils.dateOnly(day);
    state = (month: AppDateUtils.monthStart(date), selectedDay: date);
  }
}
