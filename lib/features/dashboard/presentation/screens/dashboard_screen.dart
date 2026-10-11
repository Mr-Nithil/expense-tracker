import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/sync/sync_status_button.dart';
import 'package:expense_tracker/core/theme/app_sizes.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/utils/clock.dart';
import 'package:expense_tracker/core/widgets/app_scaffold.dart';
import 'package:expense_tracker/core/widgets/async_value_view.dart';
import 'package:expense_tracker/core/widgets/month_selector.dart';
import 'package:expense_tracker/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:expense_tracker/features/dashboard/presentation/widgets/dashboard_budget_section.dart';
import 'package:expense_tracker/features/dashboard/presentation/widgets/dashboard_goals_section.dart';
import 'package:expense_tracker/features/dashboard/presentation/widgets/dashboard_heatmap_section.dart';
import 'package:expense_tracker/features/dashboard/presentation/widgets/dashboard_recent_section.dart';
import 'package:expense_tracker/features/dashboard/presentation/widgets/dashboard_spending_section.dart';
import 'package:expense_tracker/features/dashboard/presentation/widgets/dashboard_summary_cards.dart';
import 'package:expense_tracker/features/profile/presentation/providers/profile_providers.dart';
import 'package:expense_tracker/features/transactions/presentation/providers/transactions_providers.dart';
import 'package:expense_tracker/features/transactions/presentation/shared/transaction_form_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

/// The dashboard tab: its own month selector above that month's balance, income and expenses,
/// then its daily spending heatmap, spending by category, budgets, goals and latest
/// transactions. The + button adds a
/// transaction; pull to refresh syncs.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final month = ref.watch(dashboardMonthControllerProvider);
    final bounds = DashboardMonthController.monthBounds(ref.watch(clockProvider).now());

    return AppScaffold(
      title: l10n.dashboardTitle,
      actions: const [SyncStatusButton()],
      onRefresh: () => SyncStatusButton.syncNow(context, ref),
      floatingActionButton: FloatingActionButton(
        tooltip: l10n.transactionsAdd,
        onPressed: () => TransactionFormSheet.show(context),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: MonthSelector(
              month: month,
              firstMonth: bounds.first,
              lastMonth: bounds.last,
              onChanged: (month) =>
                  ref.read(dashboardMonthControllerProvider.notifier).setMonth(month),
            ),
          ),
          Expanded(
            child: AsyncValueView(
              value: ref.watch(currencyCodeProvider),
              // The currency comes from the profile; reload that.
              onRetry: () => ref.invalidate(profileProvider),
              data: (currencyCode) => AsyncValueView(
                value: ref.watch(monthTotalsProvider(month)),
                onRetry: () => ref.invalidate(monthTotalsProvider(month)),
                data: (totals) => ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSizes.fabClearance,
                  ),
                  children: [
                    DashboardSummaryCards(totals: totals, currencyCode: currencyCode),
                    const Gap(AppSpacing.lg),
                    DashboardHeatmapSection(month: month, currencyCode: currencyCode),
                    const Gap(AppSpacing.lg),
                    DashboardSpendingSection(month: month, currencyCode: currencyCode),
                    const Gap(AppSpacing.lg),
                    DashboardBudgetSection(month: month, currencyCode: currencyCode),
                    const Gap(AppSpacing.lg),
                    DashboardGoalsSection(currencyCode: currencyCode),
                    const Gap(AppSpacing.lg),
                    DashboardRecentSection(month: month, currencyCode: currencyCode),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
