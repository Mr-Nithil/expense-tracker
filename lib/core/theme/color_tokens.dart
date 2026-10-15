import 'package:flutter/material.dart';

/// One theme's Meadow palette (Sprout design, M12.1; `docs/Design/README.md` §Colors).
///
/// Widgets never read these directly: `AppTheme` maps them into `ColorScheme` and [AppColors]
/// (`context.colorScheme`, `context.colors`).
@immutable
class MeadowPalette {
  const MeadowPalette({
    required this.bg,
    required this.surface,
    required this.field,
    required this.line,
    required this.ink,
    required this.ink2,
    required this.primary,
    required this.primaryDeep,
    required this.onPrimary,
    required this.link,
    required this.soft,
    required this.accent,
    required this.accentInk,
    required this.accentSoft,
    required this.danger,
    required this.dangerSoft,
    required this.mascot,
    required this.mascotDeep,
    required this.leaf,
    required this.leafDeep,
    required this.cheek,
    required this.pipInk,
  });

  /// Scaffold background.
  final Color bg;

  /// Cards, sheets, nav bar.
  final Color surface;

  /// Input fill, progress track, segmented track, empty heatmap day.
  final Color field;

  /// Borders, the solid "3D" card shadow, dividers.
  final Color line;

  /// Primary text.
  final Color ink;

  /// Secondary text, inactive icons.
  final Color ink2;

  /// Primary buttons, active states, bars (fills; green **text** uses [link]).
  final Color primary;

  /// The solid shadow under primary buttons, the FAB and the balance card.
  final Color primaryDeep;

  /// Text and icons on [primary].
  final Color onPrimary;

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

  /// Errors, expense amounts, over budget.
  final Color danger;

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
}

/// Raw color values. **The only place in the app with color literals.**
///
/// Text colors reach WCAG AA (4.5:1) on every surface of their theme
/// (`test/core/theme/color_contrast_test.dart`): in light mode `primary` is the design's #2F8247
/// darkened to #2C7942, and amber text uses `accentInk` instead of `accent`.
abstract final class ColorTokens {
  static const light = MeadowPalette(
    bg: Color(0xFFF7F8EE),
    surface: Color(0xFFFDFEFA),
    field: Color(0xFFEDF2E7),
    line: Color(0xFFD9E1D2),
    ink: Color(0xFF1E2D21),
    ink2: Color(0xFF4F6052),
    primary: Color(0xFF2C7942),
    primaryDeep: Color(0xFF206133),
    onPrimary: Color(0xFFFDFEFA),
    link: Color(0xFF206B38),
    soft: Color(0xFFD9F0D3),
    accent: Color(0xFFE9A03E),
    accentInk: Color(0xFF915A10),
    accentSoft: Color(0xFFFFECCD),
    danger: Color(0xFFC5372F),
    dangerSoft: Color(0xFFFFEEEA),
    mascot: Color(0xFFABDEA0),
    mascotDeep: Color(0xFF7DBA7A),
    leaf: Color(0xFF55A144),
    leafDeep: Color(0xFF3E7232),
    cheek: Color(0xFFF8A49D),
    pipInk: Color(0xFF162C20),
  );

  static const dark = MeadowPalette(
    bg: Color(0xFF101812),
    surface: Color(0xFF1A231B),
    field: Color(0xFF1F2A21),
    line: Color(0xFF313E34),
    ink: Color(0xFFEDF0E7),
    ink2: Color(0xFFACB8A9),
    primary: Color(0xFF67C377),
    primaryDeep: Color(0xFF36884D),
    onPrimary: Color(0xFF0C1A0F),
    link: Color(0xFF86D489),
    soft: Color(0xFF1D3120),
    accent: Color(0xFFF5AE4B),
    accentInk: Color(0xFFF5AE4B),
    accentSoft: Color(0xFF432E14),
    danger: Color(0xFFFB8274),
    dangerSoft: Color(0xFF41211D),
    mascot: Color(0xFFA2D496),
    mascotDeep: Color(0xFF679C63),
    leaf: Color(0xFF68B457),
    leafDeep: Color(0xFF4C8141),
    cheek: Color(0xFFE3928B),
    pipInk: Color(0xFF162C20),
  );

  /// Fully transparent: no Material 3 tint on raised surfaces.
  static const transparent = Color(0x00000000);

  /// Shadows and scrims.
  static const black = Color(0xFF000000);
}
