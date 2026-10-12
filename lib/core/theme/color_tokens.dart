import 'package:flutter/material.dart';

/// Raw color values. **The only place in the app with color literals.**
///
/// Widgets never use these directly. They read `context.colorScheme` or `context.colors`.
/// Semantic text colors reach WCAG AA (4.5:1) on every surface of their theme
/// (`test/core/theme/color_contrast_test.dart`, M9.5).
abstract final class ColorTokens {
  static const seed = Color(0xFF00897B);

  static const incomeLight = Color(0xFF29702D);
  static const incomeDark = Color(0xFF81C784);
  static const expenseLight = Color(0xFFBE2626);
  static const expenseDark = Color(0xFFE88282);
  static const warningLight = Color(0xFF8E5500);
  static const warningDark = Color(0xFFFFB74D);
  static const successLight = Color(0xFF006F62);
  static const successDark = Color(0xFF4DB6AC);
}
