import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/core/theme/app_radius.dart';
import 'package:expense_tracker/core/theme/app_sizes.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/theme/color_tokens.dart';
import 'package:flutter/material.dart';

/// Material 3 light and dark themes built from [ColorTokens].
abstract final class AppTheme {
  static ThemeData light() => _build(Brightness.light, ColorTokens.light, AppColors.light);

  static ThemeData dark() => _build(Brightness.dark, ColorTokens.dark, AppColors.dark);

  /// The Meadow palette mapped onto Material roles (`SPROUT_IMPLEMENTATION_PLAN.md` §2.1).
  static ColorScheme schemeOf(Brightness brightness, MeadowPalette p) => ColorScheme(
    brightness: brightness,
    primary: p.primary,
    onPrimary: p.onPrimary,
    primaryContainer: p.soft,
    onPrimaryContainer: p.ink,
    secondary: p.link,
    onSecondary: p.onPrimary,
    secondaryContainer: p.soft,
    onSecondaryContainer: p.ink,
    tertiary: p.accent,
    onTertiary: p.pipInk,
    tertiaryContainer: p.accentSoft,
    onTertiaryContainer: p.ink,
    error: p.danger,
    onError: p.onPrimary,
    errorContainer: p.dangerSoft,
    onErrorContainer: p.ink,
    surface: p.bg,
    onSurface: p.ink,
    onSurfaceVariant: p.ink2,
    surfaceContainerLowest: p.surface,
    surfaceContainerLow: p.surface,
    surfaceContainer: p.surface,
    surfaceContainerHigh: Color.lerp(p.surface, p.field, 0.5),
    surfaceContainerHighest: p.field,
    outline: p.ink2,
    outlineVariant: p.line,
    shadow: ColorTokens.black,
    scrim: ColorTokens.black,
    inverseSurface: p.ink,
    onInverseSurface: p.bg,
    inversePrimary: p.mascot,
    surfaceTint: ColorTokens.transparent,
  );

  /// The bundled design font (M12.1).
  static const fontFamily = 'Nunito';

  /// README §Typography. Colors come from the theme; buttons uppercase their own labels.
  static const _textTheme = TextTheme(
    displayLarge: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.5),
    displayMedium: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.4),
    displaySmall: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.36),
    headlineLarge: TextStyle(
      fontSize: 30,
      fontWeight: FontWeight.w800,
      height: 1.12,
      letterSpacing: -0.3,
    ),
    headlineMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w800,
      height: 1.15,
      letterSpacing: -0.28,
    ),
    headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, height: 1.2),
    titleLarge: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, height: 1.25),
    titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, height: 1.3),
    titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, height: 1.3),
    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.5),
    bodyMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, height: 1.45),
    bodySmall: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, height: 1.4),
    labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 0.96),
    labelMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
    labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
  );

  static ThemeData _build(Brightness brightness, MeadowPalette palette, AppColors appColors) {
    final scheme = schemeOf(brightness, palette);
    final rounded = RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md));
    const buttonSize = Size(AppSizes.minTapTarget, AppSizes.buttonHeight);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: fontFamily,
      textTheme: _textTheme,
      scaffoldBackgroundColor: scheme.surface,
      extensions: [appColors],
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        centerTitle: false,
        scrolledUnderElevation: 1,
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainer,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: rounded,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(minimumSize: buttonSize, shape: rounded),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(minimumSize: buttonSize, shape: rounded),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(minimumSize: buttonSize, shape: rounded),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
      ),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainer,
        indicatorColor: appColors.soft,
      ),
    );
  }
}
