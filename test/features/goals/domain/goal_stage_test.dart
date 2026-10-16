import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/features/goals/domain/entities/goal.dart';
import 'package:expense_tracker/features/goals/domain/entities/goal_progress.dart';
import 'package:expense_tracker/features/goals/domain/entities/goal_stage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'stage boundaries: 0–4 seed, 5–24 sprout, 25–59 seedling, 60–99 young plant, 100+ bloom',
    () {
      final cases = {
        0: GoalStage.seed,
        4: GoalStage.seed,
        5: GoalStage.sprout,
        24: GoalStage.sprout,
        25: GoalStage.seedling,
        59: GoalStage.seedling,
        60: GoalStage.youngPlant,
        99: GoalStage.youngPlant,
        100: GoalStage.bloom,
        250: GoalStage.bloom,
      };
      cases.forEach((percent, stage) => expect(GoalStage.of(percent), stage, reason: '$percent %'));
    },
  );

  test('numbers the stages 1 to 5', () {
    expect(GoalStage.values.map((s) => s.number), [1, 2, 3, 4, 5]);
  });

  test('a goal uses its rounded-down percent: 59.99 % is still a seedling', () {
    GoalProgress progress(int saved) => GoalProgress(
      goal: Goal(
        id: 'g',
        name: 'Bike',
        target: const Money(10000),
        icon: 'savings',
        color: 0,
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
      ),
      saved: Money(saved),
    );
    expect(progress(5999).stage, GoalStage.seedling);
    expect(progress(6000).stage, GoalStage.youngPlant);
    expect(progress(9999).stage, GoalStage.youngPlant);
    expect(progress(10000).stage, GoalStage.bloom);
  });
}
