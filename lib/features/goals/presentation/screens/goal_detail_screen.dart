import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/l10n/failure_l10n.dart';
import 'package:expense_tracker/core/theme/app_sizes.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/utils/clock.dart';
import 'package:expense_tracker/core/utils/date_utils.dart';
import 'package:expense_tracker/core/widgets/app_scaffold.dart';
import 'package:expense_tracker/core/widgets/async_value_view.dart';
import 'package:expense_tracker/core/widgets/confirm_dialog.dart';
import 'package:expense_tracker/core/widgets/empty_state.dart';
import 'package:expense_tracker/core/widgets/loading_view.dart';
import 'package:expense_tracker/core/widgets/section_header.dart';
import 'package:expense_tracker/core/widgets/swipe_to_delete.dart';
import 'package:expense_tracker/features/goals/domain/entities/goal.dart';
import 'package:expense_tracker/features/goals/domain/entities/goal_contribution.dart';
import 'package:expense_tracker/features/goals/presentation/providers/goal_detail_controller.dart';
import 'package:expense_tracker/features/goals/presentation/providers/goals_providers.dart';
import 'package:expense_tracker/features/goals/presentation/widgets/contribution_form_sheet.dart';
import 'package:expense_tracker/features/goals/presentation/widgets/contribution_tile.dart';
import 'package:expense_tracker/features/goals/presentation/widgets/goal_form_sheet.dart';
import 'package:expense_tracker/features/goals/presentation/widgets/goal_summary.dart';
import 'package:expense_tracker/features/profile/presentation/providers/profile_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

/// One goal: its progress (ring, saved of target, what to save each month or that it's reached),
/// "Add money", and its history (swipe a row away to remove it, with Undo). Edit and delete are in
/// the app bar.
class GoalDetailScreen extends ConsumerWidget {
  const GoalDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final goal = ref.watch(goalByIdProvider(id));

    return switch (goal) {
      AsyncData(value: final progress?) => AppScaffold(
        title: progress.goal.name,
        actions: [
          IconButton(
            tooltip: l10n.commonEdit,
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => GoalFormSheet.show(context, goal: progress.goal),
          ),
          IconButton(
            tooltip: l10n.goalDetailDelete,
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _delete(context, ref, progress.goal),
          ),
        ],
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => ContributionFormSheet.show(context, goalId: id),
          icon: const Icon(Icons.add),
          label: Text(l10n.goalsAddMoney),
        ),
        body: AsyncValueView(
          value: ref.watch(currencyCodeProvider),
          // The currency comes from the profile; reload that.
          onRetry: () => ref.invalidate(profileProvider),
          data: (currencyCode) => _History(
            goalId: id,
            currencyCode: currencyCode,
            header: GoalSummary(
              progress: progress,
              today: AppDateUtils.dateOnly(ref.watch(clockProvider).now()),
              currencyCode: currencyCode,
            ),
          ),
        ),
      ),
      // Missing or deleted, e.g. on another device.
      AsyncData() => AppScaffold(
        title: l10n.goalsTitle,
        body: EmptyState(
          icon: Icons.flag_outlined,
          title: l10n.goalDetailMissingTitle,
          message: l10n.goalDetailMissingMessage,
        ),
      ),
      AsyncError() => AppScaffold(
        title: l10n.goalsTitle,
        body: AsyncValueView(
          value: goal,
          onRetry: () => ref.invalidate(goalByIdProvider(id)),
          data: (_) => const SizedBox.shrink(),
        ),
      ),
      _ => AppScaffold(title: l10n.goalsTitle, body: const LoadingView()),
    };
  }

  /// Confirms, closes the page, then deletes (so the "not found" state never flashes).
  Future<void> _delete(BuildContext context, WidgetRef ref, Goal goal) async {
    final l10n = context.l10n;
    final confirmed = await ConfirmDialog.show(
      context,
      title: l10n.goalDeleteConfirmTitle(goal.name),
      message: l10n.goalDeleteConfirmMessage,
      confirmLabel: l10n.commonDelete,
      isDestructive: true,
    );
    if (!confirmed || !context.mounted) return;
    // Read before leaving: this page's context is gone afterwards.
    final controller = ref.read(goalDetailControllerProvider.notifier);
    final messenger = ScaffoldMessenger.of(context);
    context.pop();
    final result = await controller.deleteGoal(goal.id);
    if (result case Failure(:final failure)) {
      messenger.showSnackBar(SnackBar(content: Text(failure.localize(l10n))));
    }
  }
}

/// The summary, then the goal's contributions, newest first. A swiped row hides at once and can
/// be brought back with Undo.
class _History extends ConsumerStatefulWidget {
  const _History({required this.goalId, required this.currencyCode, required this.header});

  final String goalId;
  final String currencyCode;
  final Widget header;

  @override
  ConsumerState<_History> createState() => _HistoryState();
}

class _HistoryState extends ConsumerState<_History> {
  /// Swiped away and being deleted: hidden at once (a dismissed row must leave the tree).
  final _hidden = <String>{};

  /// Bumped whenever a row is shown again, so it gets a fresh Dismissible.
  final _revisions = <String, int>{};

  void _show(String id) {
    _hidden.remove(id);
    _revisions.update(id, (revision) => revision + 1, ifAbsent: () => 1);
  }

  Future<void> _remove(GoalContribution contribution) async {
    final l10n = context.l10n;
    // Read once: Undo must work even if this list is rebuilt or gone.
    final controller = ref.read(goalDetailControllerProvider.notifier);
    setState(() => _hidden.add(contribution.id));
    final result = await controller.deleteContribution(contribution.id);
    if (!mounted) return;
    switch (result) {
      case Success():
        context.showUndoSnack(
          l10n.goalContributionDeleted,
          onUndo: () => _undo(controller, contribution.id),
        );
      case Failure(:final failure):
        setState(() => _show(contribution.id));
        context.showSnack(failure.toL10n(context));
    }
  }

  Future<void> _undo(GoalDetailController controller, String id) async {
    final result = await controller.restoreContribution(id);
    if (!mounted) return;
    setState(() => _show(id));
    if (result case Failure(:final failure)) context.showSnack(failure.toL10n(context));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final muted = context.text.bodyMedium?.copyWith(color: context.colorScheme.onSurfaceVariant);
    final contributions = ref.watch(goalContributionsProvider(widget.goalId));
    final visible = [
      for (final c in contributions.value ?? const <GoalContribution>[])
        if (!_hidden.contains(c.id)) c,
    ];

    return ListView(
      padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSizes.fabClearance),
      children: [
        widget.header,
        const Gap(AppSpacing.lg),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: SectionHeader(title: l10n.goalDetailHistory),
        ),
        switch (contributions) {
          AsyncError(:final error) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text(
              errorMessageOf(error, context),
              style: context.text.bodyMedium?.copyWith(color: context.colorScheme.error),
            ),
          ),
          AsyncData() when visible.isEmpty => Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text(l10n.goalDetailHistoryEmpty, style: muted),
          ),
          AsyncData() => Column(
            children: [
              for (final c in visible)
                SwipeToDelete(
                  itemKey: ValueKey((c.id, _revisions[c.id] ?? 0)),
                  onDelete: () => _remove(c),
                  child: ContributionTile(contribution: c, currencyCode: widget.currencyCode),
                ),
            ],
          ),
          _ => const LoadingView(),
        },
      ],
    );
  }
}
