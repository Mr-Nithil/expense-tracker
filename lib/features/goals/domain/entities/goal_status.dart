/// Where a goal stands today (`GoalCalculator.status`).
enum GoalStatus {
  /// Not reached yet; no deadline, or the deadline is today or later.
  onTrack,

  /// Not reached and the deadline has passed.
  overdue,

  /// Saved at least the target.
  completed,
}
