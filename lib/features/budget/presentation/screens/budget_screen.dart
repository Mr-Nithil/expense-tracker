import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/l10n/failure_l10n.dart';
import 'package:expense_tracker/core/sync/sync_status_button.dart';
import 'package:expense_tracker/core/theme/app_sizes.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/utils/clock.dart';
import 'package:expense_tracker/core/utils/date_utils.dart';
import 'package:expense_tracker/core/widgets/always_scrollable.dart';
import 'package:expense_tracker/core/widgets/app_scaffold.dart';
import 'package:expense_tracker/core/widgets/async_value_view.dart';
import 'package:expense_tracker/core/widgets/empty_state.dart';
import 'package:expense_tracker/core/widgets/month_selector.dart';
import 'package:expense_tracker/core/widgets/section_header.dart';
import 'package:expense_tracker/features/budget/domain/entities/budget_overview.dart';
import 'package:expense_tracker/features/budget/presentation/providers/budget_list_controller.dart';
import 'package:expense_tracker/features/budget/presentation/providers/budget_providers.dart';
import 'package:expense_tracker/features/budget/presentation/shared/budget_overall_card.dart';
import 'package:expense_tracker/features/budget/presentation/shared/budget_progress_tile.dart';
import 'package:expense_tracker/features/budget/presentation/widgets/budget_form_sheet.dart';
import 'package:expense_tracker/features/profile/presentation/providers/profile_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The budget tab: a month selector above that month's overall budget card and its category
/// budgets with progress. The + button adds a budget, tapping one edits it, and the app bar copies
/// last month's budgets. Pull to refresh syncs.
class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final month = ref.watch(budgetMonthControllerProvider);
    final bounds = BudgetMonthController.monthBounds(ref.watch(clockProvider).now());

    return AppScaffold(
      title: l10n.budgetTitle,
      actions: [
        IconButton(
          tooltip: l10n.budgetCopyPrevious,
          icon: const Icon(Icons.content_copy_outlined),
          onPressed: () => _copyPreviousMonth(context, ref, month),
        ),
        const SyncStatusButton(),
      ],
      onRefresh: () => SyncStatusButton.syncNow(context, ref),
      floatingActionButton: FloatingActionButton(
        tooltip: l10n.budgetAdd,
        onPressed: () => _add(context, ref, month),
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
                  ref.read(budgetMonthControllerProvider.notifier).setMonth(month),
            ),
          ),
          Expanded(
            child: AsyncValueView(
              value: ref.watch(currencyCodeProvider),
              // The currency comes from the profile; reload that.
              onRetry: () => ref.invalidate(profileProvider),
              data: (currencyCode) => AsyncValueView(
                value: ref.watch(budgetOverviewProvider(month)),
                onRetry: () => ref.invalidate(budgetOverviewProvider(month)),
                data: (overview) => overview.isEmpty
                    ? AlwaysScrollable(
                        child: EmptyState(
                          icon: Icons.savings_outlined,
                          title: l10n.budgetEmptyTitle(
                            AppDateUtils.formatMonthYear(month, context.localeTag),
                          ),
                          message: l10n.budgetEmptyMessage,
                          actionLabel: l10n.budgetAdd,
                          onAction: () => _add(context, ref, month),
                        ),
                      )
                    : _BudgetList(
                        overview: overview,
                        currencyCode: currencyCode,
                        onAdd: () => _add(context, ref, month),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Opens the add sheet for [month], offering only targets without a budget yet.
void _add(BuildContext context, WidgetRef ref, DateTime month) => BudgetFormSheet.showAdd(
  context,
  month: month,
  overview: ref.read(budgetOverviewProvider(month)).value ?? const BudgetOverview(),
);

/// Copies last month's budgets into [month] and says how many were added (or why it failed).
Future<void> _copyPreviousMonth(BuildContext context, WidgetRef ref, DateTime month) async {
  final result = await ref.read(budgetListControllerProvider.notifier).copyPreviousMonth(month);
  if (!context.mounted) return;
  context.showSnack(switch (result) {
    Success(:final value) => context.l10n.budgetCopied(value),
    Failure(:final failure) => failure.toL10n(context),
  });
}

class _BudgetList extends StatelessWidget {
  const _BudgetList({required this.overview, required this.currencyCode, required this.onAdd});

  final BudgetOverview overview;
  final String currencyCode;

  /// Used by the overall card when there is no overall budget yet.
  final VoidCallback onAdd;

  /// The overall card, then (if any) the "Categories" header.
  int get _leading => overview.categories.isEmpty ? 1 : 2;

  @override
  Widget build(BuildContext context) {
    final categories = overview.categories;
    return ListView.builder(
      padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSizes.fabClearance),
      itemCount: _leading + categories.length,
      itemBuilder: (context, index) => switch (index) {
        0 => Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: BudgetOverallCard(
            overall: overview.overall,
            currencyCode: currencyCode,
            onTap: switch (overview.overall) {
              final overall? => () => BudgetFormSheet.showEdit(context, overall.budget),
              null => onAdd,
            },
          ),
        ),
        1 when categories.isNotEmpty => Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
          child: SectionHeader(title: context.l10n.budgetCategoriesHeader),
        ),
        _ => BudgetProgressTile(
          key: ValueKey(categories[index - _leading].budget.id),
          progress: categories[index - _leading],
          currencyCode: currencyCode,
          onTap: () => BudgetFormSheet.showEdit(context, categories[index - _leading].budget),
        ),
      },
    );
  }
}
