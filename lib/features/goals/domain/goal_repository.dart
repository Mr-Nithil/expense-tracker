import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/features/goals/domain/entities/goal.dart';
import 'package:expense_tracker/features/goals/domain/entities/goal_contribution.dart';
import 'package:expense_tracker/features/goals/domain/entities/goal_progress.dart';

/// The signed-in user's savings goals and their contributions, in the local DB (synced later).
///
/// Writes validate input (`GoalValidator`, plus: a contribution's goal must exist and not be
/// deleted) and fail with `ValidationFailure`, `NotFoundFailure`, `AuthFailure` (no session) or
/// `StorageFailure`. They never throw.
abstract interface class GoalRepository {
  /// Non-deleted goals, oldest first, each with what was saved so far.
  Stream<List<GoalProgress>> watchAll();

  /// One non-deleted goal with what was saved, or `null` (missing or deleted).
  Stream<GoalProgress?> watchById(String id);

  Future<Result<Goal>> create(GoalDraft draft);

  /// Updates name, target, deadline, icon and color.
  Future<Result<Goal>> update(Goal goal);

  /// Soft-deletes the goal and its contributions.
  Future<Result<void>> delete(String id);

  /// Non-deleted contributions of [goalId], newest first.
  Stream<List<GoalContribution>> watchContributions(String goalId);

  Future<Result<GoalContribution>> addContribution(ContributionDraft draft);

  /// Soft delete. Restorable with [restoreContribution] (undo).
  Future<Result<void>> deleteContribution(String id);

  /// Undoes [deleteContribution]; fails with `ValidationFailure(goalNotFound)` if its goal was
  /// deleted since.
  Future<Result<void>> restoreContribution(String id);
}
