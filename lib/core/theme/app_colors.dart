import 'package:expense_tracker/core/theme/color_tokens.dart';
import 'package:flutter/material.dart';

/// Semantic colors not covered by [ColorScheme]. Access with `context.colors`.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.income,
    required this.expense,
    required this.warning,
    required this.success,
  });

  static const light = AppColors(
    income: ColorTokens.incomeLight,
    expense: ColorTokens.expenseLight,
    warning: ColorTokens.warningLight,
    success: ColorTokens.successLight,
  );

  static const dark = AppColors(
    income: ColorTokens.incomeDark,
    expense: ColorTokens.expenseDark,
    warning: ColorTokens.warningDark,
    success: ColorTokens.successDark,
  );

  final Color income;
  final Color expense;
  final Color warning;
  final Color success;

  @override
  AppColors copyWith({Color? income, Color? expense, Color? warning, Color? success}) => AppColors(
    income: income ?? this.income,
    expense: expense ?? this.expense,
    warning: warning ?? this.warning,
    success: success ?? this.success,
  );

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      income: Color.lerp(income, other.income, t)!,
      expense: Color.lerp(expense, other.expense, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      success: Color.lerp(success, other.success, t)!,
    );
  }
}
