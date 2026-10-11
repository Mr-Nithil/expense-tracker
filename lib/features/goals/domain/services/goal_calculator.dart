import 'package:expense_tracker/core/utils/date_utils.dart';
import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/features/goals/domain/entities/goal_status.dart';

/// Goal maths. [target] is always positive (`GoalValidator`); [saved] is never negative.
abstract final class GoalCalculator {
  /// Whole percent of [target] saved, rounded down (so 100 means reached) and not capped.
  static int percentSaved(Money target, Money saved) => saved.minor * 100 ~/ target.minor;

  /// Share of [target] saved, clamped to `0..1`, for progress rings (a display ratio, not money).
  static double fractionSaved(Money target, Money saved) =>
      (saved.minor / target.minor).clamp(0.0, 1.0);

  /// What is still to save; zero once the target is reached (never negative).
  static Money remaining(Money target, Money saved) =>
      saved >= target ? Money.zero : target - saved;

  static bool isCompleted(Money target, Money saved) => saved >= target;

  /// Completed once reached; otherwise overdue when [deadline] is before [today].
  static GoalStatus status({
    required Money target,
    required Money saved,
    required DateTime? deadline,
    required DateTime today,
  }) {
    if (isCompleted(target, saved)) return GoalStatus.completed;
    if (deadline != null &&
        AppDateUtils.dateOnly(deadline).isBefore(AppDateUtils.dateOnly(today))) {
      return GoalStatus.overdue;
    }
    return GoalStatus.onTrack;
  }

  /// Calendar months from [today]'s month to [deadline]'s month, both included (Oct 11 → Dec 1
  /// is 3). 0 when the deadline is before today.
  static int monthsLeft(DateTime today, DateTime deadline) {
    final from = AppDateUtils.dateOnly(today);
    final to = AppDateUtils.dateOnly(deadline);
    if (to.isBefore(from)) return 0;
    return (to.year - from.year) * 12 + to.month - from.month + 1;
  }

  /// What to put aside each month to reach [target] by [deadline], rounded up to the minor unit
  /// so following it always reaches the target. `null` without a deadline, once completed, or
  /// when the deadline has passed.
  static Money? neededPerMonth({
    required Money target,
    required Money saved,
    required DateTime? deadline,
    required DateTime today,
  }) {
    if (deadline == null) return null;
    if (status(target: target, saved: saved, deadline: deadline, today: today) !=
        GoalStatus.onTrack) {
      return null;
    }
    final months = monthsLeft(today, deadline);
    final left = remaining(target, saved).minor;
    return Money((left + months - 1) ~/ months);
  }
}
