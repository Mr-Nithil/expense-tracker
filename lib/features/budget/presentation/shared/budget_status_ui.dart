import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/widgets/progress_bar.dart';
import 'package:expense_tracker/features/budget/domain/entities/budget_status.dart';
import 'package:flutter/material.dart';

/// How each [BudgetStatus] looks. Normal has no label, icon or color of its own.
extension BudgetStatusUi on BudgetStatus {
  ProgressLevel get progressLevel => switch (this) {
    BudgetStatus.normal => ProgressLevel.normal,
    BudgetStatus.warning => ProgressLevel.warning,
    BudgetStatus.exceeded => ProgressLevel.exceeded,
  };

  /// "Close to limit" / "Limit reached", so the state isn't told by color alone.
  String? label(BuildContext context) => switch (this) {
    BudgetStatus.normal => null,
    BudgetStatus.warning => context.l10n.budgetStatusWarning,
    BudgetStatus.exceeded => context.l10n.budgetStatusExceeded,
  };

  IconData? get icon => switch (this) {
    BudgetStatus.normal => null,
    BudgetStatus.warning => Icons.warning_amber_rounded,
    BudgetStatus.exceeded => Icons.error_outline,
  };

  /// Same colors as the bar (`ProgressBar`).
  Color? color(BuildContext context) => switch (this) {
    BudgetStatus.normal => null,
    BudgetStatus.warning => context.colors.warning,
    BudgetStatus.exceeded => context.colors.expense,
  };
}
