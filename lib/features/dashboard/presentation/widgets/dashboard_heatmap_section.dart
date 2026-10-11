import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/l10n/failure_l10n.dart';
import 'package:expense_tracker/core/router/routes.dart';
import 'package:expense_tracker/core/theme/app_radius.dart';
import 'package:expense_tracker/core/theme/app_sizes.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/utils/date_utils.dart';
import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/core/widgets/app_button.dart';
import 'package:expense_tracker/core/widgets/loading_view.dart';
import 'package:expense_tracker/core/widgets/section_header.dart';
import 'package:expense_tracker/features/calendar/presentation/providers/calendar_providers.dart';
import 'package:expense_tracker/features/transactions/domain/entities/day_totals.dart';
import 'package:expense_tracker/features/transactions/domain/services/spending_levels.dart';
import 'package:expense_tracker/features/transactions/presentation/providers/transactions_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

/// "Daily spending": the month as a grid of days shaded by how much was spent (one hue, darker
/// = more, relative to the month's biggest day), with a "Less … More" key. "See all" opens the
/// calendar on this month; tapping a day opens it on that day.
class DashboardHeatmapSection extends ConsumerWidget {
  const DashboardHeatmapSection({super.key, required this.month, required this.currencyCode});

  final DateTime month;
  final String currencyCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    void openCalendar({DateTime? day}) {
      final calendar = ref.read(calendarControllerProvider.notifier);
      day == null ? calendar.setMonth(month) : calendar.selectDay(day);
      context.pushNamed(Routes.calendar);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: l10n.dashboardHeatmapTitle,
          actionLabel: l10n.commonSeeAll,
          onAction: openCalendar,
        ),
        switch (ref.watch(monthDailyTotalsProvider(month))) {
          AsyncData(value: final totals) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Grid(
                month: month,
                totals: totals,
                currencyCode: currencyCode,
                onDaySelected: (day) => openCalendar(day: day),
              ),
              const Gap(AppSpacing.sm),
              const _Key(),
            ],
          ),
          AsyncError(:final error) => Row(
            children: [
              Expanded(
                child: Text(
                  errorMessageOf(error, context),
                  style: context.text.bodyMedium?.copyWith(color: context.colorScheme.error),
                ),
              ),
              AppButton.text(
                label: l10n.commonRetry,
                onPressed: () => ref.invalidate(monthDailyTotalsProvider(month)),
              ),
            ],
          ),
          _ => const LoadingView(),
        },
      ],
    );
  }
}

/// Colors of the heatmap: the empty shade for level 0, then one hue from light to dark.
abstract final class _Shades {
  /// Where the ramp starts between `primaryContainer` and `primary`: lower and the lightest
  /// shade disappears into the background (checked against both themes for >= 2:1 contrast).
  static const _start = 0.4;

  static Color of(BuildContext context, int level) {
    final scheme = context.colorScheme;
    if (level == 0) return scheme.surfaceContainerHighest;
    final t = _start + (1 - _start) * (level - 1) / (SpendingLevels.count - 1);
    return Color.lerp(scheme.primaryContainer, scheme.primary, t)!;
  }
}

class _Grid extends StatelessWidget {
  const _Grid({
    required this.month,
    required this.totals,
    required this.currencyCode,
    required this.onDaySelected,
  });

  final DateTime month;
  final Map<DateTime, DayTotals> totals;
  final String currencyCode;
  final ValueChanged<DateTime> onDaySelected;

  static const _columns = DateTime.daysPerWeek;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = context.localeTag;
    final materialL10n = MaterialLocalizations.of(context);
    final firstWeekday = materialL10n.firstDayOfWeekIndex; // 0 = Sunday
    final max = totals.values.fold(
      Money.zero,
      (biggest, day) => day.expense > biggest ? day.expense : biggest,
    );
    // DateTime.weekday: Monday = 1 … Sunday = 7; columns start at firstWeekday.
    final leading = (month.weekday % _columns - firstWeekday) % _columns;
    final days = AppDateUtils.daysInMonth(month);
    final muted = context.text.labelSmall?.copyWith(color: context.colorScheme.onSurfaceVariant);

    Widget cell(int index) {
      final dayOfMonth = index - leading + 1;
      if (dayOfMonth < 1 || dayOfMonth > days) return const SizedBox.shrink();
      final day = DateTime(month.year, month.month, dayOfMonth);
      final spent = totals[day]?.expense ?? Money.zero;
      final date = AppDateUtils.formatLongDate(day, locale);
      return Semantics(
        label: spent.isPositive
            ? l10n.dashboardHeatmapDay(
                date,
                spent.format(locale: locale, currencyCode: currencyCode),
              )
            : l10n.dashboardHeatmapDayNone(date),
        button: true,
        excludeSemantics: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onDaySelected(day),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxs / 2),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: _Shades.of(context, SpendingLevels.of(spent, max)),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
            ),
          ),
        ),
      );
    }

    final rows = (leading + days + _columns - 1) ~/ _columns;
    return Column(
      children: [
        ExcludeSemantics(
          child: Row(
            children: [
              for (var column = 0; column < _columns; column++)
                Expanded(
                  child: Text(
                    materialL10n.narrowWeekdays[(firstWeekday + column) % _columns],
                    style: muted,
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
        const Gap(AppSpacing.xs),
        for (var row = 0; row < rows; row++)
          Row(
            children: [
              for (var column = 0; column < _columns; column++)
                Expanded(
                  child: AspectRatio(aspectRatio: 1, child: cell(row * _columns + column)),
                ),
            ],
          ),
      ],
    );
  }
}

/// "Less ▢▢▢▢▢ More": the shades from no spending to the most.
class _Key extends StatelessWidget {
  const _Key();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final muted = context.text.labelSmall?.copyWith(color: context.colorScheme.onSurfaceVariant);
    return ExcludeSemantics(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(l10n.dashboardHeatmapLess, style: muted),
          const Gap(AppSpacing.xs),
          for (var level = 0; level <= SpendingLevels.count; level++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs / 2),
              child: Container(
                key: ValueKey('heatmap-key-$level'),
                width: AppSizes.iconSm,
                height: AppSizes.iconSm,
                decoration: BoxDecoration(
                  color: _Shades.of(context, level),
                  borderRadius: BorderRadius.circular(AppRadius.sm / 2),
                ),
              ),
            ),
          const Gap(AppSpacing.xs),
          Text(l10n.dashboardHeatmapMore, style: muted),
        ],
      ),
    );
  }
}
