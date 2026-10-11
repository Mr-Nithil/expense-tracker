/// How a budget is doing in its month (`BudgetCalculator.status`).
enum BudgetStatus {
  /// Below the warning threshold.
  normal,

  /// At or above the warning threshold (80%), below the limit.
  warning,

  /// The limit is reached or exceeded (100% or more).
  exceeded,
}
