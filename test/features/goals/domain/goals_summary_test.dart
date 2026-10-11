import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/features/goals/domain/entities/goal.dart';
import 'package:expense_tracker/features/goals/domain/entities/goal_progress.dart';
import 'package:expense_tracker/features/goals/domain/entities/goals_summary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  GoalProgress goal(String id, int target, int saved) => GoalProgress(
    goal: Goal(
      id: id,
      name: id,
      target: Money(target),
      icon: 'savings',
      color: 0,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    ),
    saved: Money(saved),
  );

  test('totals everything and counts reached goals', () {
    final summary = GoalsSummary.of([
      goal('laptop', 150000, 50000),
      goal('bike', 40000, 40000),
      goal('trip', 90000, 120000),
    ]);

    expect(summary.totalSaved, const Money(210000));
    expect(summary.totalTarget, const Money(280000));
    expect(summary.reachedCount, 2);
    expect(summary.isEmpty, isFalse);
  });

  test('top lists unfinished goals closest to done first, up to the count', () {
    final summary = GoalsSummary.of([
      goal('a', 100, 10),
      goal('done', 100, 100),
      goal('b', 100, 90),
      goal('c', 100, 50),
      goal('d', 100, 70),
    ]);

    expect(summary.top.map((g) => g.goal.id), ['b', 'd', 'c']);
  });

  test('ties keep the goals\' order', () {
    final summary = GoalsSummary.of([goal('first', 100, 50), goal('second', 100, 50)]);

    expect(summary.top.map((g) => g.goal.id), ['first', 'second']);
  });

  test('without goals it is empty', () {
    final summary = GoalsSummary.of(const []);

    expect(summary.isEmpty, isTrue);
    expect(summary.top, isEmpty);
    expect(summary.reachedCount, 0);
  });
}
