import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/features/goals/domain/entities/goal.dart';
import 'package:expense_tracker/features/goals/domain/entities/goal_progress.dart';
import 'package:expense_tracker/features/goals/domain/entities/goal_status.dart';
import 'package:expense_tracker/features/goals/domain/services/goal_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const target = Money(150000);

  group('percentSaved', () {
    test('is a whole percent, rounded down', () {
      expect(GoalCalculator.percentSaved(target, Money.zero), 0);
      expect(GoalCalculator.percentSaved(target, const Money(50000)), 33);
      expect(GoalCalculator.percentSaved(target, const Money(149999)), 99);
      expect(GoalCalculator.percentSaved(target, target), 100);
    });

    test('is not capped when saved beyond the target', () {
      expect(GoalCalculator.percentSaved(target, const Money(180000)), 120);
    });

    test('large amounts stay exact', () {
      const big = Money(900000000000000);
      expect(GoalCalculator.percentSaved(big, const Money(450000000000000)), 50);
    });
  });

  test('fractionSaved is clamped to 0..1', () {
    expect(GoalCalculator.fractionSaved(target, const Money(75000)), 0.5);
    expect(GoalCalculator.fractionSaved(target, const Money(300000)), 1.0);
  });

  test('remaining never goes below zero', () {
    expect(GoalCalculator.remaining(target, const Money(50000)), const Money(100000));
    expect(GoalCalculator.remaining(target, target), Money.zero);
    expect(GoalCalculator.remaining(target, const Money(200000)), Money.zero);
  });

  test('completed once saved reaches the target', () {
    expect(GoalCalculator.isCompleted(target, const Money(149999)), isFalse);
    expect(GoalCalculator.isCompleted(target, target), isTrue);
    expect(GoalCalculator.isCompleted(target, const Money(160000)), isTrue);
  });

  test('GoalProgress exposes the calculations', () {
    final progress = GoalProgress(
      goal: Goal(
        id: 'g',
        name: 'Laptop',
        target: target,
        icon: 'savings',
        color: 0,
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
      ),
      saved: const Money(50000),
    );

    expect(progress.percent, 33);
    expect(progress.fraction, closeTo(1 / 3, 1e-9));
    expect(progress.remaining, const Money(100000));
    expect(progress.isCompleted, isFalse);
  });

  group('status', () {
    final today = DateTime(2026, 10, 11, 15);
    GoalStatus status(int saved, DateTime? deadline) => GoalCalculator.status(
      target: target,
      saved: Money(saved),
      deadline: deadline,
      today: today,
    );

    test('completed wins, even past the deadline', () {
      expect(status(150000, DateTime(2026, 1)), GoalStatus.completed);
    });

    test('overdue only when the deadline is before today', () {
      expect(status(0, DateTime(2026, 10, 10)), GoalStatus.overdue);
      expect(status(0, DateTime(2026, 10, 11)), GoalStatus.onTrack);
      expect(status(0, null), GoalStatus.onTrack);
    });
  });

  group('monthsLeft', () {
    final today = DateTime(2026, 10, 11);

    test('counts this month and the deadline month', () {
      expect(GoalCalculator.monthsLeft(today, DateTime(2026, 10, 31)), 1);
      expect(GoalCalculator.monthsLeft(today, DateTime(2026, 12, 1)), 3);
      expect(GoalCalculator.monthsLeft(today, DateTime(2027, 10, 1)), 13);
    });

    test('is 0 once the deadline has passed', () {
      expect(GoalCalculator.monthsLeft(today, DateTime(2026, 10, 10)), 0);
    });
  });

  group('neededPerMonth', () {
    final today = DateTime(2026, 10, 11);
    Money? needed(int saved, DateTime? deadline) => GoalCalculator.neededPerMonth(
      target: target,
      saved: Money(saved),
      deadline: deadline,
      today: today,
    );

    test('splits what is left over the months left', () {
      // $1,000 left over Oct, Nov, Dec, Jan: $250 a month.
      expect(needed(50000, DateTime(2027, 1, 15)), const Money(25000));
    });

    test('rounds up so following it reaches the target', () {
      // $1,500 over 7 months = 21428.57… cents → 21429.
      expect(needed(0, DateTime(2027, 4, 1)), const Money(21429));
      expect(const Money(21429) * 7 >= target, isTrue);
    });

    test('a deadline this month needs everything that is left', () {
      expect(needed(140000, DateTime(2026, 10, 31)), const Money(10000));
    });

    test('is null without a deadline, once completed, or past the deadline', () {
      expect(needed(0, null), isNull);
      expect(needed(150000, DateTime(2027)), isNull);
      expect(needed(0, DateTime(2026, 9, 30)), isNull);
    });
  });

  group('edge cases', () {
    test('the time of day does not matter: late on the deadline day is still on track', () {
      final lateToday = DateTime(2026, 10, 11, 23, 59);
      final deadline = DateTime(2026, 10, 11);

      expect(
        GoalCalculator.status(
          target: target,
          saved: const Money(100000),
          deadline: deadline,
          today: lateToday,
        ),
        GoalStatus.onTrack,
      );
      expect(GoalCalculator.monthsLeft(lateToday, deadline), 1);
      expect(
        GoalCalculator.neededPerMonth(
          target: target,
          saved: const Money(100000),
          deadline: deadline,
          today: lateToday,
        ),
        const Money(50000),
      );
    });

    test('across a year end: Nov 20 to Feb 1 is four months', () {
      // $1,500 over Nov, Dec, Jan, Feb = $375 a month.
      expect(
        GoalCalculator.neededPerMonth(
          target: target,
          saved: Money.zero,
          deadline: DateTime(2027, 2),
          today: DateTime(2026, 11, 20),
        ),
        const Money(37500),
      );
    });

    test('large amounts stay exact (integer maths)', () {
      // 9 trillion minor units over 12 months, rounded up.
      const big = Money(900000000000001);
      final perMonth = GoalCalculator.neededPerMonth(
        target: big,
        saved: Money.zero,
        deadline: DateTime(2027, 9, 30),
        today: DateTime(2026, 10, 11),
      )!;

      expect(perMonth, const Money(75000000000001));
      expect(perMonth * 12 >= big, isTrue);
    });
  });
}
