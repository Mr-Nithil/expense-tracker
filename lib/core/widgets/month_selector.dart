import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/utils/date_utils.dart';
import 'package:flutter/material.dart';

/// ‹ October 2026 › — steps one month at a time. The caller owns the month; arrows are disabled
/// at [firstMonth] / [lastMonth]. Months are passed and reported as their first day.
class MonthSelector extends StatelessWidget {
  const MonthSelector({
    super.key,
    required this.month,
    required this.onChanged,
    this.firstMonth,
    this.lastMonth,
  });

  final DateTime month;
  final ValueChanged<DateTime> onChanged;
  final DateTime? firstMonth;
  final DateTime? lastMonth;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final current = AppDateUtils.monthStart(month);
    final first = firstMonth == null ? null : AppDateUtils.monthStart(firstMonth!);
    final last = lastMonth == null ? null : AppDateUtils.monthStart(lastMonth!);
    final canGoBack = first == null || current.isAfter(first);
    final canGoForward = last == null || current.isBefore(last);

    return Row(
      children: [
        IconButton(
          tooltip: l10n.commonPreviousMonth,
          icon: const Icon(Icons.chevron_left),
          onPressed: canGoBack ? () => onChanged(AppDateUtils.addMonths(current, -1)) : null,
        ),
        Expanded(
          child: Semantics(
            liveRegion: true,
            child: Text(
              AppDateUtils.formatMonthYear(current, context.localeTag),
              style: context.text.titleMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        IconButton(
          tooltip: l10n.commonNextMonth,
          icon: const Icon(Icons.chevron_right),
          onPressed: canGoForward ? () => onChanged(AppDateUtils.addMonths(current, 1)) : null,
        ),
      ],
    );
  }
}
