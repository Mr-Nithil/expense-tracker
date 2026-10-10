import 'package:flutter/material.dart';

/// Raw color values. **The only place in the app with color literals.**
///
/// Widgets never use these directly. They read `context.colorScheme` or `context.colors`.
abstract final class ColorTokens {
  static const seed = Color(0xFF00897B);

  static const incomeLight = Color(0xFF2E7D32);
  static const incomeDark = Color(0xFF81C784);
  static const expenseLight = Color(0xFFC62828);
  static const expenseDark = Color(0xFFE57373);
  static const warningLight = Color(0xFFB26A00);
  static const warningDark = Color(0xFFFFB74D);
  static const successLight = Color(0xFF00796B);
  static const successDark = Color(0xFF4DB6AC);
}
