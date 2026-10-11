import 'package:expense_tracker/core/utils/money.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'goal.freezed.dart';

/// A savings goal: save [target] for something, optionally by [deadlineOn].
@freezed
abstract class Goal with _$Goal {
  const factory Goal({
    required String id,
    required String name,
    required Money target,

    /// Date-only (local midnight); `null` without a deadline.
    DateTime? deadlineOn,

    /// Icon key (`CategoryIcon` keys).
    required String icon,

    /// ARGB color value.
    required int color,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Goal;
}

/// What the user enters to create a goal (the repository adds id and timestamps).
@freezed
abstract class GoalDraft with _$GoalDraft {
  const factory GoalDraft({
    required String name,
    required Money target,
    DateTime? deadlineOn,
    required String icon,
    required int color,
  }) = _GoalDraft;
}
