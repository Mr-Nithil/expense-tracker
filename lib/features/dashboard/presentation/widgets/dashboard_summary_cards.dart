import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/core/widgets/amount_text.dart';
import 'package:expense_tracker/core/widgets/app_card.dart';
import 'package:expense_tracker/features/transactions/domain/entities/month_totals.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// The month's balance (full width), then its income and expenses side by side.
class DashboardSummaryCards extends StatelessWidget {
  const DashboardSummaryCards({super.key, required this.totals, required this.currencyCode});

  final MonthTotals totals;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SummaryCard(
          label: l10n.dashboardBalance,
          money: totals.balance,
          currencyCode: currencyCode,
          type: AmountType.neutral,
          style: context.text.headlineSmall,
        ),
        const Gap(AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                label: l10n.commonIncome,
                money: totals.income,
                currencyCode: currencyCode,
                type: AmountType.income,
                style: context.text.titleMedium,
              ),
            ),
            const Gap(AppSpacing.sm),
            Expanded(
              child: _SummaryCard(
                label: l10n.commonExpense,
                money: totals.expense,
                currencyCode: currencyCode,
                type: AmountType.expense,
                style: context.text.titleMedium,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// A label above an amount, read out together.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.money,
    required this.currencyCode,
    required this.type,
    required this.style,
  });

  final String label;
  final Money money;
  final String currencyCode;
  final AmountType type;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: context.text.labelLarge?.copyWith(color: context.colorScheme.onSurfaceVariant),
            ),
            const Gap(AppSpacing.xs),
            // Large amounts shrink instead of overflowing on small screens.
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: AmountText(money, currencyCode: currencyCode, type: type, style: style),
            ),
          ],
        ),
      ),
    );
  }
}
