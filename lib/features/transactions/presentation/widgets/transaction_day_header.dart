import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/utils/date_utils.dart';
import 'package:expense_tracker/core/widgets/amount_text.dart';
import 'package:expense_tracker/features/transactions/domain/services/transaction_grouping.dart';
import 'package:flutter/material.dart';

/// Header above one day's transactions: "Today" / "Yesterday" / "Fri, Oct 9" and the day's net.
class TransactionDayHeader extends StatelessWidget {
  const TransactionDayHeader({
    super.key,
    required this.day,
    required this.today,
    required this.currencyCode,
  });

  final TransactionDay day;

  /// From the injected clock, so "Today" is testable.
  final DateTime today;
  final String currencyCode;

  String _label(BuildContext context) {
    final yesterday = DateTime(today.year, today.month, today.day - 1);
    if (AppDateUtils.isSameDay(day.date, today)) return context.l10n.commonToday;
    if (AppDateUtils.isSameDay(day.date, yesterday)) return context.l10n.commonYesterday;
    return AppDateUtils.formatWeekdayDate(day.date, context.localeTag);
  }

  @override
  Widget build(BuildContext context) {
    final style = context.text.titleSmall?.copyWith(color: context.colorScheme.onSurfaceVariant);
    return Semantics(
      header: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.xs,
        ),
        child: Row(
          children: [
            Expanded(child: Text(_label(context), style: style)),
            AmountText(day.net, currencyCode: currencyCode, style: style),
          ],
        ),
      ),
    );
  }
}
