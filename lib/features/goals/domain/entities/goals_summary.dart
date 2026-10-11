import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/features/goals/domain/entities/goal_progress.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'goals_summary.freezed.dart';

/// All goals at a glance: totals, how many are reached, and the unfinished goals closest to
/// their target (for summaries with room for only a few).
@freezed
abstract class GoalsSummary with _$GoalsSummary {
  const factory GoalsSummary({
    required Money totalSaved,
    required Money totalTarget,
    required int reachedCount,

    /// Unfinished goals, highest percent first.
    required List<GoalProgress> top,
  }) = _GoalsSummary;

  const GoalsSummary._();

  /// Up to [count] unfinished goals in [top]; ties keep the goals' order (oldest first).
  factory GoalsSummary.of(List<GoalProgress> goals, {int count = 3}) {
    final unfinished =
        [
          for (final (index, goal) in goals.indexed)
            if (!goal.isCompleted) (index, goal),
        ]..sort((a, b) {
          final byPercent = b.$2.percent.compareTo(a.$2.percent);
          return byPercent != 0 ? byPercent : a.$1.compareTo(b.$1);
        });
    return GoalsSummary(
      totalSaved: goals.fold(Money.zero, (sum, goal) => sum + goal.saved),
      totalTarget: goals.fold(Money.zero, (sum, goal) => sum + goal.goal.target),
      reachedCount: goals.where((goal) => goal.isCompleted).length,
      top: [for (final (_, goal) in unfinished.take(count)) goal],
    );
  }

  /// No goals at all.
  bool get isEmpty => totalTarget == Money.zero;
}
