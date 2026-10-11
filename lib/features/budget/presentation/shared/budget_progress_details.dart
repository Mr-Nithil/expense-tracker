import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/theme/app_sizes.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/core/widgets/progress_bar.dart';
import 'package:expense_tracker/features/budget/domain/entities/budget_progress.dart';
import 'package:expense_tracker/features/budget/presentation/shared/budget_status_ui.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// "$250.00 of $500.00 · 50% used", a progress bar colored by the budget's status, then what is
/// left (or how far over) and, from 80%, the status ("Close to limit" / "Limit reached").
/// Shared by the overall card and the category rows.
class BudgetProgressDetails extends StatelessWidget {
  const BudgetProgressDetails({
    super.key,
    required this.progress,
    required this.currencyCode,
    required this.label,
  });

  final BudgetProgress progress;
  final String currencyCode;

  /// The budget's name, announced with the bar.
  final String label;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final muted = context.text.bodySmall?.copyWith(color: context.colorScheme.onSurfaceVariant);
    String format(Money money) =>
        money.format(locale: context.localeTag, currencyCode: currencyCode);
    final remaining = progress.remaining;
    final status = progress.status;
    final statusLabel = status.label(context);
    final statusColor = status.color(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(
              child: Text(
                l10n.budgetSpentOfLimit(format(progress.spent), format(progress.budget.limit)),
                style: context.text.bodyMedium,
              ),
            ),
            const Gap(AppSpacing.sm),
            Text(l10n.budgetPercentUsed(progress.percentUsed), style: muted),
          ],
        ),
        const Gap(AppSpacing.xs),
        ProgressBar(
          value: progress.fractionUsed,
          level: status.progressLevel,
          semanticsLabel: label,
        ),
        const Gap(AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.sm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              remaining.isNegative
                  ? l10n.budgetOver(format(remaining.abs()))
                  : l10n.budgetRemaining(format(remaining)),
              style: muted,
            ),
            if (statusLabel != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ExcludeSemantics(
                    child: Icon(status.icon, size: AppSizes.iconSm, color: statusColor),
                  ),
                  const Gap(AppSpacing.xs),
                  Flexible(
                    child: Text(
                      statusLabel,
                      style: context.text.bodySmall?.copyWith(color: statusColor),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}
