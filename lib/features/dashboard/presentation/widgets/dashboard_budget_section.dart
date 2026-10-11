import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/l10n/failure_l10n.dart';
import 'package:expense_tracker/core/router/routes.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/utils/date_utils.dart';
import 'package:expense_tracker/core/widgets/app_button.dart';
import 'package:expense_tracker/core/widgets/app_card.dart';
import 'package:expense_tracker/core/widgets/loading_view.dart';
import 'package:expense_tracker/core/widgets/section_header.dart';
import 'package:expense_tracker/features/budget/presentation/providers/budget_providers.dart';
import 'package:expense_tracker/features/budget/presentation/shared/budget_overall_card.dart';
import 'package:expense_tracker/features/budget/presentation/shared/budget_progress_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

/// "Budgets": the month's overall budget and the category budgets closest to their limit, as on
/// the Budget tab. Every action opens the Budget tab on the same month.
class DashboardBudgetSection extends ConsumerWidget {
  const DashboardBudgetSection({super.key, required this.month, required this.currencyCode});

  final DateTime month;
  final String currencyCode;

  /// Category budgets shown here; the rest are on the Budget tab.
  static const maxCategories = 3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    void openBudget() {
      ref.read(budgetMonthControllerProvider.notifier).setMonth(month);
      context.goNamed(Routes.budget);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: l10n.dashboardBudgetsTitle,
          actionLabel: l10n.commonSeeAll,
          onAction: openBudget,
        ),
        switch (ref.watch(budgetOverviewProvider(month))) {
          AsyncData(value: final overview) when overview.isEmpty => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.dashboardBudgetsEmpty(
                  AppDateUtils.formatMonthYear(month, context.localeTag),
                ),
                style: context.text.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
              const Gap(AppSpacing.sm),
              AppButton.secondary(label: l10n.dashboardBudgetsSet, onPressed: openBudget),
            ],
          ),
          AsyncData(value: final overview) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BudgetOverallCard(
                overall: overview.overall,
                currencyCode: currencyCode,
                onTap: openBudget,
              ),
              if (overview.mostUsedCategories(maxCategories) case final categories
                  when categories.isNotEmpty) ...[
                const Gap(AppSpacing.sm),
                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      for (final progress in categories)
                        BudgetProgressTile(
                          key: ValueKey(progress.budget.id),
                          progress: progress,
                          currencyCode: currencyCode,
                          onTap: openBudget,
                        ),
                    ],
                  ),
                ),
              ],
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
                onPressed: () => ref.invalidate(budgetOverviewProvider(month)),
              ),
            ],
          ),
          _ => const LoadingView(),
        },
      ],
    );
  }
}
