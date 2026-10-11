import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/widgets/category_icon.dart';
import 'package:expense_tracker/core/widgets/progress_bar.dart';
import 'package:expense_tracker/core/widgets/progress_ring.dart';
import 'package:expense_tracker/features/goals/domain/entities/goal_progress.dart';
import 'package:flutter/material.dart';

/// One goal in a list: its icon and name, "saved of target" with its deadline (or "Completed"),
/// and a progress ring with the percent.
class GoalTile extends StatelessWidget {
  const GoalTile({super.key, required this.progress, required this.currencyCode, this.onTap});

  final GoalProgress progress;
  final String currencyCode;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = context.localeTag;
    final goal = progress.goal;
    final deadline = goal.deadlineOn;
    final amounts = l10n.goalsSavedOfTarget(
      progress.saved.format(locale: locale, currencyCode: currencyCode),
      goal.target.format(locale: locale, currencyCode: currencyCode),
    );
    final status = progress.isCompleted
        ? l10n.goalsCompleted
        : deadline == null
        ? null
        : l10n.goalsDeadline(context.formatDate(deadline));

    return MergeSemantics(
      child: ListTile(
        onTap: onTap,
        leading: CategoryIcon(iconKey: goal.icon, color: goal.color),
        title: Text(goal.name),
        subtitle: Text(status == null ? amounts : l10n.goalsListSubtitle(amounts, status)),
        trailing: ProgressRing(
          value: progress.fraction,
          level: progress.isCompleted ? ProgressLevel.complete : ProgressLevel.normal,
          child: Text(l10n.goalsPercent(progress.percent), style: context.text.labelSmall),
        ),
      ),
    );
  }
}
