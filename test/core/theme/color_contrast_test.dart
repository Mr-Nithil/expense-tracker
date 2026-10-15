import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// M9.5: colored text stays readable (WCAG AA, 4.5:1 for normal text) on every surface it can sit
/// on, in both themes.
void main() {
  double contrast(Color a, Color b) {
    final (la, lb) = (a.computeLuminance(), b.computeLuminance());
    final (light, dark) = la > lb ? (la, lb) : (lb, la);
    return (light + 0.05) / (dark + 0.05);
  }

  for (final (name, theme) in [('light', AppTheme.light()), ('dark', AppTheme.dark())]) {
    test('$name: text colors reach 4.5:1 on every surface', () {
      final scheme = theme.colorScheme;
      final colors = theme.extension<AppColors>()!;
      final surfaces = {
        'surface': scheme.surface,
        'surfaceContainerLowest': scheme.surfaceContainerLowest,
        'surfaceContainerLow': scheme.surfaceContainerLow,
        'surfaceContainer': scheme.surfaceContainer,
        'surfaceContainerHigh': scheme.surfaceContainerHigh,
        'surfaceContainerHighest': scheme.surfaceContainerHighest,
      };
      final texts = {
        'income': colors.income,
        'expense': colors.expense,
        'warning': colors.warning,
        'success': colors.success,
        'onSurfaceVariant': scheme.onSurfaceVariant,
        'primary': scheme.primary,
        'error': scheme.error,
        'onSurface': scheme.onSurface,
        'link': colors.link,
        'accentInk': colors.accentInk,
      };

      final failing = [
        for (final MapEntry(key: text, value: fg) in texts.entries)
          for (final MapEntry(key: surface, value: bg) in surfaces.entries)
            if (contrast(fg, bg) < 4.5) '$text on $surface: ${contrast(fg, bg).toStringAsFixed(2)}',
      ];

      expect(failing, isEmpty);
    });

    test('$name: text on primary and on the tinted cards reaches 4.5:1', () {
      final scheme = theme.colorScheme;
      final colors = theme.extension<AppColors>()!;
      final pairs = {
        'onPrimary on primary': (scheme.onPrimary, scheme.primary),
        for (final (tint, bg) in [
          ('soft', colors.soft),
          ('accentSoft', colors.accentSoft),
          ('dangerSoft', colors.dangerSoft),
        ])
          for (final (text, fg) in [
            ('ink', scheme.onSurface),
            ('ink2', scheme.onSurfaceVariant),
            ('link', colors.link),
            ('accentInk', colors.accentInk),
          ])
            '$text on $tint': (fg, bg),
      };

      final failing = [
        for (final MapEntry(key: name, value: (fg, bg)) in pairs.entries)
          if (contrast(fg, bg) < 4.5) '$name: ${contrast(fg, bg).toStringAsFixed(2)}',
      ];

      expect(failing, isEmpty);
    });
  }
}
