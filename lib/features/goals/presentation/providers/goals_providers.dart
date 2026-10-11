import 'package:expense_tracker/core/session/session.dart';
import 'package:expense_tracker/features/goals/data/goal_repository_provider.dart';
import 'package:expense_tracker/features/goals/domain/entities/goal_contribution.dart';
import 'package:expense_tracker/features/goals/domain/entities/goal_progress.dart';
import 'package:expense_tracker/features/goals/domain/entities/goals_summary.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show ProviderListenableSelect;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'goals_providers.g.dart';

/// Non-deleted goals, oldest first, with what was saved. Re-subscribes for a new user.
@riverpod
Stream<List<GoalProgress>> goals(Ref ref) {
  ref.watch(sessionProvider.select((user) => user?.userId));
  return ref.watch(goalRepositoryProvider).watchAll();
}

/// [goalsProvider] at a glance: totals, how many are reached, the closest unfinished goals.
@riverpod
AsyncValue<GoalsSummary> goalsSummary(Ref ref) =>
    ref.watch(goalsProvider).whenData(GoalsSummary.of);

/// One non-deleted goal with what was saved; `null` when missing or deleted (e.g. on another
/// device). Re-subscribes for a new user.
@riverpod
Stream<GoalProgress?> goalById(Ref ref, String id) {
  ref.watch(sessionProvider.select((user) => user?.userId));
  return ref.watch(goalRepositoryProvider).watchById(id);
}

/// A goal's non-deleted contributions, newest first. Re-subscribes for a new user.
@riverpod
Stream<List<GoalContribution>> goalContributions(Ref ref, String goalId) {
  ref.watch(sessionProvider.select((user) => user?.userId));
  return ref.watch(goalRepositoryProvider).watchContributions(goalId);
}
