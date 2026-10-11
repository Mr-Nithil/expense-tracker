import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/l10n/failure_l10n.dart';
import 'package:expense_tracker/core/router/routes.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/widgets/app_button.dart';
import 'package:expense_tracker/core/widgets/app_card.dart';
import 'package:expense_tracker/core/widgets/loading_view.dart';
import 'package:expense_tracker/core/widgets/section_header.dart';
import 'package:expense_tracker/features/goals/presentation/providers/goals_providers.dart';
import 'package:expense_tracker/features/goals/presentation/shared/goal_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

/// "Goals": saved across all goals, how many are reached, and the unfinished goals closest to
/// their target. "See all" opens the Goals tab; a goal opens its page there.
class DashboardGoalsSection extends ConsumerWidget {
  const DashboardGoalsSection({super.key, required this.currencyCode});

  final String currencyCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = context.localeTag;
    final muted = context.text.bodyMedium?.copyWith(color: context.colorScheme.onSurfaceVariant);
    void openGoals() => context.goNamed(Routes.goals);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: l10n.goalsTitle, actionLabel: l10n.commonSeeAll, onAction: openGoals),
        switch (ref.watch(goalsSummaryProvider)) {
          AsyncData(value: final summary) when summary.isEmpty => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.dashboardGoalsEmpty, style: muted),
              const Gap(AppSpacing.sm),
              AppButton.secondary(label: l10n.dashboardGoalsSet, onPressed: openGoals),
            ],
          ),
          AsyncData(value: final summary) => AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.xs,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.dashboardGoalsTotal(
                          summary.totalSaved.format(locale: locale, currencyCode: currencyCode),
                          summary.totalTarget.format(locale: locale, currencyCode: currencyCode),
                        ),
                        style: context.text.titleMedium,
                      ),
                      if (summary.reachedCount > 0)
                        Text(l10n.dashboardGoalsReached(summary.reachedCount), style: muted),
                    ],
                  ),
                ),
                for (final progress in summary.top)
                  GoalTile(
                    key: ValueKey(progress.goal.id),
                    progress: progress,
                    currencyCode: currencyCode,
                    onTap: () => context.goNamed(
                      Routes.goalDetail,
                      pathParameters: {Routes.goalIdParam: progress.goal.id},
                    ),
                  ),
              ],
            ),
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
                // The summary is derived from the goals; reload those.
                onPressed: () => ref.invalidate(goalsProvider),
              ),
            ],
          ),
          _ => const LoadingView(),
        },
      ],
    );
  }
}
