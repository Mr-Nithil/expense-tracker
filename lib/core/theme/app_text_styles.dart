import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:flutter/painting.dart';

/// The design's big numbers (README §Typography), beyond the Material text theme. No color: apply
/// one from the theme, e.g. `AppTextStyles.balance.copyWith(color: context.colorScheme.onPrimary)`.
abstract final class AppTextStyles {
  /// Balance on the Home card.
  static const balance = TextStyle(
    fontFamily: AppTheme.fontFamily,
    fontSize: 40,
    fontWeight: FontWeight.w800,
    height: 1.1,
    letterSpacing: -0.4,
  );

  /// Stat tiles, Goal detail percent, Overall budget spent.
  static const stat = TextStyle(
    fontFamily: AppTheme.fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w800,
    height: 1.15,
  );

  /// "{n} day streak".
  static const streak = TextStyle(
    fontFamily: AppTheme.fontFamily,
    fontSize: 34,
    fontWeight: FontWeight.w800,
    height: 1.1,
  );
}
