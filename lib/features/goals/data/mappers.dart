import 'package:expense_tracker/core/db/app_database.dart';
import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/features/goals/domain/entities/goal.dart';
import 'package:expense_tracker/features/goals/domain/entities/goal_contribution.dart';

extension GoalRowMapper on GoalRow {
  Goal toEntity() => Goal(
    id: id,
    name: name,
    target: Money(targetMinor),
    deadlineOn: deadlineOn,
    icon: icon,
    color: color,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

extension GoalContributionRowMapper on GoalContributionRow {
  GoalContribution toEntity() => GoalContribution(
    id: id,
    goalId: goalId,
    amount: Money(amountMinor),
    contributedOn: contributedOn,
    note: note,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
