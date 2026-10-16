import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/features/goals/domain/entities/goal.dart';
import 'package:expense_tracker/features/goals/domain/entities/goal_stage.dart';
import 'package:expense_tracker/features/goals/domain/services/goal_calculator.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'goal_progress.freezed.dart';

/// A goal and how much has been put towards it (its non-deleted contributions).
@freezed
abstract class GoalProgress with _$GoalProgress {
  const factory GoalProgress({required Goal goal, required Money saved}) = _GoalProgress;

  const GoalProgress._();

  int get percent => GoalCalculator.percentSaved(goal.target, saved);

  double get fraction => GoalCalculator.fractionSaved(goal.target, saved);

  Money get remaining => GoalCalculator.remaining(goal.target, saved);

  bool get isCompleted => GoalCalculator.isCompleted(goal.target, saved);

  /// How grown the goal's plant is.
  GoalStage get stage => GoalStage.of(percent);
}
