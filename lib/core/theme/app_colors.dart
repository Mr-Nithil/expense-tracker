import 'package:expense_tracker/core/theme/color_tokens.dart';
import 'package:flutter/material.dart';

/// Semantic colors not covered by [ColorScheme] (Meadow, M12.1). Access with `context.colors`.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.income,
    required this.expense,
    required this.warning,
    required this.success,
    required this.field,
    required this.line,
    required this.primaryDeep,
    required this.link,
    required this.soft,
    required this.accent,
    required this.accentInk,
    required this.accentSoft,
    required this.dangerSoft,
    required this.mascot,
    required this.mascotDeep,
    required this.leaf,
    required this.leafDeep,
    required this.cheek,
    required this.pipInk,
  });

  /// The extension for one [MeadowPalette].
  factory AppColors.of(MeadowPalette p) => AppColors(
    income: p.link,
    expense: p.danger,
    warning: p.accentInk,
    success: p.link,
    field: p.field,
    line: p.line,
    primaryDeep: p.primaryDeep,
    link: p.link,
    soft: p.soft,
    accent: p.accent,
    accentInk: p.accentInk,
    accentSoft: p.accentSoft,
    dangerSoft: p.dangerSoft,
    mascot: p.mascot,
    mascotDeep: p.mascotDeep,
    leaf: p.leaf,
    leafDeep: p.leafDeep,
    cheek: p.cheek,
    pipInk: p.pipInk,
  );

  static final light = AppColors.of(ColorTokens.light);

  static final dark = AppColors.of(ColorTokens.dark);

  /// Income amounts (= link).
  final Color income;

  /// Expense amounts, over budget (= danger).
  final Color expense;

  /// Warning **text** (= accentInk). Fills use [accent].
  final Color warning;

  /// Success / reached **text** (= link). Fills use [leaf].
  final Color success;

  /// Input fill, progress track, segmented track, empty heatmap day.
  final Color field;

  /// Borders, the solid "3D" card shadow, dividers.
  final Color line;

  /// The solid shadow under primary buttons, the FAB and the balance card.
  final Color primaryDeep;

  /// Text buttons, income amounts, active nav icon: green text.
  final Color link;

  /// Pip halos, tip cards, the active nav pill.
  final Color soft;

  /// Streak, warning (>= 80 %), reached badges: fills, icons, borders (not text).
  final Color accent;

  /// Amber **text** (streak numbers, warnings): [accent] darkened to 4.5:1 in light mode.
  final Color accentInk;

  /// Streak chip and Ask Pip backgrounds.
  final Color accentSoft;

  /// Error field and expense icon backgrounds.
  final Color dangerSoft;

  /// Pip body.
  final Color mascot;

  /// Pip hands.
  final Color mascotDeep;

  /// Pip leaves, goal rings, sprout tips.
  final Color leaf;

  /// Leaf stems.
  final Color leafDeep;

  /// Pip cheeks, bloom centre.
  final Color cheek;

  /// Pip's eyes and mouth (same in both themes).
  final Color pipInk;

  @override
  AppColors copyWith({
    Color? income,
    Color? expense,
    Color? warning,
    Color? success,
    Color? field,
    Color? line,
    Color? primaryDeep,
    Color? link,
    Color? soft,
    Color? accent,
    Color? accentInk,
    Color? accentSoft,
    Color? dangerSoft,
    Color? mascot,
    Color? mascotDeep,
    Color? leaf,
    Color? leafDeep,
    Color? cheek,
    Color? pipInk,
  }) => AppColors(
    income: income ?? this.income,
    expense: expense ?? this.expense,
    warning: warning ?? this.warning,
    success: success ?? this.success,
    field: field ?? this.field,
    line: line ?? this.line,
    primaryDeep: primaryDeep ?? this.primaryDeep,
    link: link ?? this.link,
    soft: soft ?? this.soft,
    accent: accent ?? this.accent,
    accentInk: accentInk ?? this.accentInk,
    accentSoft: accentSoft ?? this.accentSoft,
    dangerSoft: dangerSoft ?? this.dangerSoft,
    mascot: mascot ?? this.mascot,
    mascotDeep: mascotDeep ?? this.mascotDeep,
    leaf: leaf ?? this.leaf,
    leafDeep: leafDeep ?? this.leafDeep,
    cheek: cheek ?? this.cheek,
    pipInk: pipInk ?? this.pipInk,
  );

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      income: Color.lerp(income, other.income, t)!,
      expense: Color.lerp(expense, other.expense, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      success: Color.lerp(success, other.success, t)!,
      field: Color.lerp(field, other.field, t)!,
      line: Color.lerp(line, other.line, t)!,
      primaryDeep: Color.lerp(primaryDeep, other.primaryDeep, t)!,
      link: Color.lerp(link, other.link, t)!,
      soft: Color.lerp(soft, other.soft, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentInk: Color.lerp(accentInk, other.accentInk, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      dangerSoft: Color.lerp(dangerSoft, other.dangerSoft, t)!,
      mascot: Color.lerp(mascot, other.mascot, t)!,
      mascotDeep: Color.lerp(mascotDeep, other.mascotDeep, t)!,
      leaf: Color.lerp(leaf, other.leaf, t)!,
      leafDeep: Color.lerp(leafDeep, other.leafDeep, t)!,
      cheek: Color.lerp(cheek, other.cheek, t)!,
      pipInk: Color.lerp(pipInk, other.pipInk, t)!,
    );
  }
}
