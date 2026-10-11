import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/features/transactions/domain/entities/category_spending.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'spending_breakdown.freezed.dart';

/// One row of a [SpendingBreakdown]: a category, or "Other" ([categoryId] null) for the rest.
@freezed
abstract class SpendingShare with _$SpendingShare {
  const factory SpendingShare({
    String? categoryId,
    required Money amount,

    /// Whole percent of the total, rounded half up (shares may not add up to exactly 100).
    required int percent,

    /// [amount] over the total, for bar lengths (a display ratio, not money).
    required double fraction,

    /// How many categories "Other" groups (0 for a category's own share).
    @Default(0) int foldedCategories,
  }) = _SpendingShare;

  const SpendingShare._();

  bool get isOther => categoryId == null;
}

/// Spending split by category, largest first, with the tail folded into "Other".
@freezed
abstract class SpendingBreakdown with _$SpendingBreakdown {
  const factory SpendingBreakdown({required List<SpendingShare> shares, required Money total}) =
      _SpendingBreakdown;

  const SpendingBreakdown._();

  static const empty = SpendingBreakdown(shares: [], total: Money.zero);

  /// Most rows shown: beyond it, the first `maxRows - 1` stay and the rest become "Other".
  static const defaultMaxRows = 6;

  /// [spending] must be largest first (as the repository returns it).
  factory SpendingBreakdown.of(
    List<CategorySpending> spending, {
    int maxRows = defaultMaxRows,
  }) {
    final total = spending.fold(Money.zero, (sum, item) => sum + item.amount);
    if (total.minor <= 0) return empty;

    SpendingShare share(String? categoryId, Money amount, {int folded = 0}) => SpendingShare(
      categoryId: categoryId,
      amount: amount,
      percent: (amount.minor * 200 + total.minor) ~/ (total.minor * 2),
      fraction: amount.minor / total.minor,
      foldedCategories: folded,
    );

    final fold = spending.length > maxRows;
    final kept = fold ? spending.take(maxRows - 1) : spending;
    final rest = spending.skip(kept.length).fold(Money.zero, (sum, item) => sum + item.amount);
    return SpendingBreakdown(
      shares: [
        for (final item in kept) share(item.categoryId, item.amount),
        if (fold) share(null, rest, folded: spending.length - kept.length),
      ],
      total: total,
    );
  }

  bool get isEmpty => shares.isEmpty;
}
