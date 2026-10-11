import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/features/goals/data/goal_repository_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'goal_detail_controller.g.dart';

/// Goal detail actions: delete the goal, remove a contribution and undo that. Returns the
/// [Result] so the page can close, offer Undo or show the error. Kept alive because it is only
/// used from callbacks.
@Riverpod(keepAlive: true)
class GoalDetailController extends _$GoalDetailController {
  @override
  void build() {}

  /// Deletes the goal and its contributions.
  Future<Result<void>> deleteGoal(String id) => ref.read(goalRepositoryProvider).delete(id);

  Future<Result<void>> deleteContribution(String id) =>
      ref.read(goalRepositoryProvider).deleteContribution(id);

  Future<Result<void>> restoreContribution(String id) =>
      ref.read(goalRepositoryProvider).restoreContribution(id);
}
