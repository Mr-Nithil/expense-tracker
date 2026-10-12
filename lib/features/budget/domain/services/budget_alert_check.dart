import 'package:expense_tracker/core/utils/stable_hash.dart';
import 'package:expense_tracker/features/budget/domain/entities/budget_overview.dart';
import 'package:expense_tracker/features/budget/domain/entities/budget_progress.dart';
import 'package:expense_tracker/features/budget/domain/entities/budget_status.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'budget_alert_check.freezed.dart';

/// A budget that just moved up into [status] (warning or exceeded).
@freezed
abstract class BudgetAlert with _$BudgetAlert {
  const factory BudgetAlert({required BudgetProgress progress, required BudgetStatus status}) =
      _BudgetAlert;
}

/// When to alert: a budget moving **up** into warning (80%) or exceeded (100%).
abstract final class BudgetAlertCheck {
  /// Each budget's status, by budget id.
  static Map<String, BudgetStatus> statuses(BudgetOverview overview) => {
    for (final progress in [?overview.overall, ...overview.categories])
      progress.budget.id: progress.status,
  };

  /// Budgets in [current] whose status rose above their [previous] one into warning or exceeded.
  /// Nothing without a [previous] snapshot (the app just opened), and nothing for a budget not in
  /// it (just created: its status is what the user is looking at).
  static List<BudgetAlert> crossings(Map<String, BudgetStatus>? previous, BudgetOverview current) {
    if (previous == null) return const [];
    return [
      for (final progress in [?current.overall, ...current.categories])
        if (previous[progress.budget.id] case final before?)
          if (progress.status != BudgetStatus.normal && progress.status.index > before.index)
            BudgetAlert(progress: progress, status: progress.status),
    ];
  }
}

/// One notification id per budget, far above the reminder ids (`ReminderNotificationIds`, from
/// 2^24), so a newer alert for the same budget (100% after 80%) replaces the older one.
abstract final class BudgetAlertIds {
  static const base = 1 << 28;
  static const _buckets = 1 << 20;

  static int of(String budgetId) => base + StableHash.fnv1a(budgetId) % _buckets;
}
