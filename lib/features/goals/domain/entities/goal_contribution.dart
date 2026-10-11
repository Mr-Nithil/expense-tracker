import 'package:expense_tracker/core/utils/money.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'goal_contribution.freezed.dart';

/// Money put towards a goal on a day.
@freezed
abstract class GoalContribution with _$GoalContribution {
  const factory GoalContribution({
    required String id,
    required String goalId,
    required Money amount,

    /// Date-only (local midnight).
    required DateTime contributedOn,
    String? note,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _GoalContribution;
}

/// What the user enters to add a contribution (the repository adds id and timestamps).
@freezed
abstract class ContributionDraft with _$ContributionDraft {
  const factory ContributionDraft({
    required String goalId,
    required Money amount,
    required DateTime contributedOn,
    String? note,
  }) = _ContributionDraft;
}
