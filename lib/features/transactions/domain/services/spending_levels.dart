import 'package:expense_tracker/core/utils/money.dart';

/// Shades of a spending heatmap: how a day's spending compares to the period's biggest day.
abstract final class SpendingLevels {
  /// Levels above 0 (0 = no spending).
  static const count = 4;

  /// 0 without spending; otherwise 1..[count], rounded up so any spending shows and the biggest
  /// day ([max]) is always [count]. Integer maths, so it is exact for any amount.
  static int of(Money spent, Money max) {
    if (!spent.isPositive || !max.isPositive) return 0;
    final level = (spent.minor * count + max.minor - 1) ~/ max.minor;
    return level.clamp(1, count);
  }
}
