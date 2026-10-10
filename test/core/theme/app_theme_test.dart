import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('light and dark themes use Material 3 with the right brightness', () {
    expect(AppTheme.light().useMaterial3, isTrue);
    expect(AppTheme.light().colorScheme.brightness, Brightness.light);
    expect(AppTheme.dark().colorScheme.brightness, Brightness.dark);
  });

  test('both themes register AppColors', () {
    expect(AppTheme.light().extension<AppColors>(), AppColors.light);
    expect(AppTheme.dark().extension<AppColors>(), AppColors.dark);
  });

  test('AppColors lerp and copyWith', () {
    expect(AppColors.light.lerp(AppColors.dark, 1).income, AppColors.dark.income);
    expect(AppColors.light.lerp(null, 0.5), AppColors.light);
    expect(AppColors.light.copyWith(income: AppColors.dark.income).income, AppColors.dark.income);
  });
}
