import 'package:expense_tracker/features/budget/domain/entities/budget_progress.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'budget_overview.freezed.dart';

/// A month's budgets as shown on screen: the overall budget (if set) and the category budgets.
@freezed
abstract class BudgetOverview with _$BudgetOverview {
  const factory BudgetOverview({
    BudgetProgress? overall,
    @Default(<BudgetProgress>[]) List<BudgetProgress> categories,
  }) = _BudgetOverview;

  const BudgetOverview._();

  /// Splits [progress] into the overall budget and the category budgets, keeping their order.
  factory BudgetOverview.fromProgress(List<BudgetProgress> progress) => BudgetOverview(
    overall: progress.where((p) => p.budget.isOverall).firstOrNull,
    categories: [
      for (final p in progress)
        if (!p.budget.isOverall) p,
    ],
  );

  /// No budget at all for the month.
  bool get isEmpty => overall == null && categories.isEmpty;

  /// Up to [count] category budgets, the most used (highest `percentUsed`) first; ties keep
  /// their order. For summaries with room for only a few.
  List<BudgetProgress> mostUsedCategories(int count) {
    final indexed = categories.indexed.toList()
      ..sort((a, b) {
        final byUse = b.$2.percentUsed.compareTo(a.$2.percentUsed);
        return byUse != 0 ? byUse : a.$1.compareTo(b.$1);
      });
    return [for (final (_, progress) in indexed.take(count)) progress];
  }
}
