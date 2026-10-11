import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/sync/sync_status_button.dart';
import 'package:expense_tracker/core/theme/app_sizes.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/utils/clock.dart';
import 'package:expense_tracker/core/utils/date_utils.dart';
import 'package:expense_tracker/core/widgets/app_scaffold.dart';
import 'package:expense_tracker/core/widgets/async_value_view.dart';
import 'package:expense_tracker/core/widgets/month_selector.dart';
import 'package:expense_tracker/features/calendar/presentation/providers/calendar_providers.dart';
import 'package:expense_tracker/features/calendar/presentation/widgets/calendar_day_cell.dart';
import 'package:expense_tracker/features/calendar/presentation/widgets/calendar_day_panel.dart';
import 'package:expense_tracker/features/profile/presentation/providers/profile_providers.dart';
import 'package:expense_tracker/features/transactions/domain/entities/day_totals.dart';
import 'package:expense_tracker/features/transactions/presentation/providers/transactions_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:table_calendar/table_calendar.dart';

/// The calendar: a month grid with each day's net amount. Arrows or a swipe change the month;
/// tapping a day shows its transactions below (and adds one on that date). Pull to refresh syncs.
class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final (:month, :selectedDay) = ref.watch(calendarControllerProvider);
    final today = AppDateUtils.dateOnly(ref.watch(clockProvider).now());
    final bounds = CalendarController.monthBounds(today);
    void setMonth(DateTime month) => ref.read(calendarControllerProvider.notifier).setMonth(month);

    return AppScaffold(
      title: l10n.calendarTitle,
      actions: const [SyncStatusButton()],
      onRefresh: () => SyncStatusButton.syncNow(context, ref),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: MonthSelector(
              month: month,
              firstMonth: bounds.first,
              lastMonth: bounds.last,
              onChanged: setMonth,
            ),
          ),
          Expanded(
            child: AsyncValueView(
              value: ref.watch(currencyCodeProvider),
              // The currency comes from the profile; reload that.
              onRetry: () => ref.invalidate(profileProvider),
              data: (currencyCode) {
                Widget calendar(Map<DateTime, DayTotals> totals) => ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.sm,
                    0,
                    AppSpacing.sm,
                    AppSpacing.lg,
                  ),
                  children: [
                    _MonthGrid(
                      month: month,
                      today: today,
                      selectedDay: selectedDay,
                      bounds: bounds,
                      totals: totals,
                      currencyCode: currencyCode,
                      onMonthChanged: setMonth,
                      onDaySelected: ref.read(calendarControllerProvider.notifier).selectDay,
                    ),
                    if (selectedDay != null) ...[
                      const Gap(AppSpacing.md),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                        child: CalendarDayPanel(day: selectedDay, currencyCode: currencyCode),
                      ),
                    ],
                  ],
                );
                return AsyncValueView(
                  value: ref.watch(monthDailyTotalsProvider(month)),
                  onRetry: () => ref.invalidate(monthDailyTotalsProvider(month)),
                  // The grid shows at once; the amounts appear when loaded.
                  loading: () => calendar(const {}),
                  data: calendar,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.month,
    required this.today,
    required this.selectedDay,
    required this.bounds,
    required this.totals,
    required this.currencyCode,
    required this.onMonthChanged,
    required this.onDaySelected,
  });

  final DateTime month;
  final DateTime today;
  final DateTime? selectedDay;
  final ({DateTime first, DateTime last}) bounds;
  final Map<DateTime, DayTotals> totals;
  final String currencyCode;
  final ValueChanged<DateTime> onMonthChanged;
  final ValueChanged<DateTime> onDaySelected;

  /// `table_calendar` passes UTC dates; the totals are keyed by local midnight.
  static DateTime _local(DateTime day) => DateTime(day.year, day.month, day.day);

  /// `MaterialLocalizations` counts from Sunday (0); `StartingDayOfWeek` from Monday.
  static StartingDayOfWeek _firstDayOfWeek(BuildContext context) =>
      StartingDayOfWeek.values[(MaterialLocalizations.of(context).firstDayOfWeekIndex + 6) % 7];

  @override
  Widget build(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    final weekday = context.text.labelSmall?.copyWith(color: context.colorScheme.onSurfaceVariant);

    Widget cell(DateTime day) {
      final local = _local(day);
      return CalendarDayCell(
        day: local,
        totals: totals[local],
        currencyCode: currencyCode,
        isToday: local == today,
        isSelected: local == selectedDay,
      );
    }

    return TableCalendar<void>(
      locale: context.localeTag,
      focusedDay: month,
      firstDay: bounds.first,
      lastDay: AppDateUtils.nextMonthStart(bounds.last).subtract(const Duration(days: 1)),
      currentDay: today,
      headerVisible: false,
      startingDayOfWeek: _firstDayOfWeek(context),
      availableGestures: AvailableGestures.horizontalSwipe,
      rowHeight: scaler.scale(AppSizes.calendarRowHeight),
      daysOfWeekHeight: scaler.scale(AppSizes.calendarDaysOfWeekHeight),
      daysOfWeekStyle: DaysOfWeekStyle(weekdayStyle: weekday!, weekendStyle: weekday),
      selectedDayPredicate: (day) => _local(day) == selectedDay,
      onDaySelected: (day, _) => onDaySelected(_local(day)),
      onPageChanged: (focused) => onMonthChanged(AppDateUtils.monthStart(_local(focused))),
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (_, day, _) => cell(day),
        todayBuilder: (_, day, _) => cell(day),
        selectedBuilder: (_, day, _) => cell(day),
        outsideBuilder: (_, _, _) => const SizedBox.shrink(),
      ),
    );
  }
}
