import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/widgets/app_card.dart';
import 'package:expense_tracker/features/budget/domain/entities/budget_progress.dart';
import 'package:expense_tracker/features/budget/presentation/shared/budget_progress_details.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// The month's overall budget (all expenses) with its progress, or a note that none is set.
class BudgetOverallCard extends StatelessWidget {
  const BudgetOverallCard({
    super.key,
    required this.overall,
    required this.currencyCode,
    this.onTap,
  });

  /// `null` when the month only has category budgets.
  final BudgetProgress? overall;
  final String currencyCode;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final progress = overall;

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            progress == null ? l10n.budgetOverallEmptyTitle : l10n.budgetOverallTitle,
            style: context.text.titleMedium,
          ),
          const Gap(AppSpacing.sm),
          if (progress == null)
            Text(
              l10n.budgetOverallEmptyMessage,
              style: context.text.bodyMedium?.copyWith(color: context.colorScheme.onSurfaceVariant),
            )
          else
            BudgetProgressDetails(
              progress: progress,
              currencyCode: currencyCode,
              label: l10n.budgetOverallTitle,
            ),
        ],
      ),
    );
  }
}
