import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/theme/app_sizes.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/core/widgets/progress_bar.dart';
import 'package:expense_tracker/core/widgets/progress_ring.dart';
import 'package:expense_tracker/features/goals/domain/entities/goal_progress.dart';
import 'package:expense_tracker/features/goals/domain/entities/goal_status.dart';
import 'package:expense_tracker/features/goals/domain/services/goal_calculator.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// The top of a goal's page: a big ring with the percent, "saved of target", and where it
/// stands: reached, overdue, or what is left (and, with a deadline, what to save each month).
class GoalSummary extends StatelessWidget {
  const GoalSummary({
    super.key,
    required this.progress,
    required this.today,
    required this.currencyCode,
  });

  final GoalProgress progress;

  /// From the injected clock.
  final DateTime today;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = context.localeTag;
    final goal = progress.goal;
    final deadline = goal.deadlineOn;
    String money(Money m) => m.format(locale: locale, currencyCode: currencyCode);
    final status = GoalCalculator.status(
      target: goal.target,
      saved: progress.saved,
      deadline: deadline,
      today: today,
    );
    final perMonth = GoalCalculator.neededPerMonth(
      target: goal.target,
      saved: progress.saved,
      deadline: deadline,
      today: today,
    );
    final muted = context.text.bodyMedium?.copyWith(color: context.colorScheme.onSurfaceVariant);

    return Column(
      children: [
        ProgressRing(
          value: progress.fraction,
          size: AppSizes.progressRingLarge,
          level: status == GoalStatus.completed ? ProgressLevel.complete : ProgressLevel.normal,
          semanticsLabel: goal.name,
          child: Text(l10n.goalsPercent(progress.percent), style: context.text.headlineSmall),
        ),
        const Gap(AppSpacing.md),
        Text(
          l10n.goalsSavedOfTarget(money(progress.saved), money(goal.target)),
          style: context.text.titleMedium,
          textAlign: TextAlign.center,
        ),
        const Gap(AppSpacing.xs),
        switch (status) {
          GoalStatus.completed => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ExcludeSemantics(
                child: Icon(
                  Icons.check_circle,
                  size: AppSizes.iconSm,
                  color: context.colors.success,
                ),
              ),
              const Gap(AppSpacing.xs),
              Text(
                l10n.goalDetailCompleted,
                style: context.text.bodyMedium?.copyWith(color: context.colors.success),
              ),
            ],
          ),
          GoalStatus.overdue => Text(
            l10n.goalDetailOverdue(context.formatDate(deadline!)),
            style: context.text.bodyMedium?.copyWith(color: context.colors.warning),
            textAlign: TextAlign.center,
          ),
          GoalStatus.onTrack => Column(
            children: [
              Text(l10n.goalDetailRemaining(money(progress.remaining)), style: muted),
              if (perMonth != null && deadline != null) ...[
                const Gap(AppSpacing.xs),
                Text(
                  l10n.goalDetailNeededPerMonth(money(perMonth), context.formatDate(deadline)),
                  style: context.text.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        },
      ],
    );
  }
}
