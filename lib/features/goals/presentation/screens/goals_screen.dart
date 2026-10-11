import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/router/routes.dart';
import 'package:expense_tracker/core/sync/sync_status_button.dart';
import 'package:expense_tracker/core/theme/app_sizes.dart';
import 'package:expense_tracker/core/widgets/always_scrollable.dart';
import 'package:expense_tracker/core/widgets/app_scaffold.dart';
import 'package:expense_tracker/core/widgets/async_value_view.dart';
import 'package:expense_tracker/core/widgets/empty_state.dart';
import 'package:expense_tracker/features/goals/presentation/providers/goals_providers.dart';
import 'package:expense_tracker/features/goals/presentation/shared/goal_tile.dart';
import 'package:expense_tracker/features/goals/presentation/widgets/goal_form_sheet.dart';
import 'package:expense_tracker/features/profile/presentation/providers/profile_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The goals tab: every savings goal with how much was saved, as progress rings. The + button
/// adds a goal; tapping one opens its page. Pull to refresh syncs.
class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    return AppScaffold(
      title: l10n.goalsTitle,
      actions: const [SyncStatusButton()],
      onRefresh: () => SyncStatusButton.syncNow(context, ref),
      floatingActionButton: FloatingActionButton(
        tooltip: l10n.goalsAdd,
        onPressed: () => GoalFormSheet.show(context),
        child: const Icon(Icons.add),
      ),
      body: AsyncValueView(
        value: ref.watch(currencyCodeProvider),
        // The currency comes from the profile; reload that.
        onRetry: () => ref.invalidate(profileProvider),
        data: (currencyCode) => AsyncValueView(
          value: ref.watch(goalsProvider),
          onRetry: () => ref.invalidate(goalsProvider),
          data: (goals) => goals.isEmpty
              ? AlwaysScrollable(
                  child: EmptyState(
                    icon: Icons.flag_outlined,
                    title: l10n.goalsEmptyTitle,
                    message: l10n.goalsEmptyMessage,
                    actionLabel: l10n.goalsAdd,
                    onAction: () => GoalFormSheet.show(context),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: AppSizes.fabClearance),
                  itemCount: goals.length,
                  itemBuilder: (context, index) => GoalTile(
                    key: ValueKey(goals[index].goal.id),
                    progress: goals[index],
                    currencyCode: currencyCode,
                    onTap: () => context.pushNamed(
                      Routes.goalDetail,
                      pathParameters: {Routes.goalIdParam: goals[index].goal.id},
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
