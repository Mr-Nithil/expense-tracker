import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/theme/app_radius.dart';
import 'package:expense_tracker/core/theme/app_sizes.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/utils/date_utils.dart';
import 'package:expense_tracker/features/transactions/domain/entities/day_totals.dart';
import 'package:flutter/material.dart';

/// One calendar day: its number and, if anything happened, its net amount (compact, green when
/// positive, red when negative). Read out as the full date and the exact signed amount.
class CalendarDayCell extends StatelessWidget {
  const CalendarDayCell({
    super.key,
    required this.day,
    required this.currencyCode,
    this.totals,
    this.isToday = false,
    this.isSelected = false,
  });

  /// The day (local midnight).
  final DateTime day;
  final String currencyCode;

  /// `null` when the day has no transactions.
  final DayTotals? totals;
  final bool isToday;

  /// The calendar's selected day: filled background.
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = context.localeTag;
    final date = AppDateUtils.formatLongDate(day, locale);
    final net = totals?.net;
    final color = switch (net) {
      null => null,
      _ when net.isNegative => context.colors.expense,
      _ when net.isPositive => context.colors.income,
      _ => context.colorScheme.onSurfaceVariant,
    };

    return Semantics(
      selected: isSelected,
      label: net == null
          ? l10n.calendarDayEmpty(date)
          : l10n.calendarDayLabel(
              date,
              net.format(locale: locale, currencyCode: currencyCode, signed: true),
            ),
      excludeSemantics: true,
      child: Container(
        margin: const EdgeInsets.all(AppSpacing.xxs),
        decoration: isToday || isSelected
            ? BoxDecoration(
                color: isSelected ? context.colorScheme.primaryContainer : null,
                border: isToday
                    ? Border.all(
                        color: context.colorScheme.primary,
                        width: AppSizes.selectionBorder,
                      )
                    : null,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              )
            : null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              context.formatNumber(day.day),
              style: isToday
                  ? context.text.bodyMedium?.copyWith(color: context.colorScheme.primary)
                  : context.text.bodyMedium,
            ),
            if (net != null)
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  net.formatCompact(locale: locale, currencyCode: currencyCode, signed: true),
                  style: context.text.labelSmall?.copyWith(color: color),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
