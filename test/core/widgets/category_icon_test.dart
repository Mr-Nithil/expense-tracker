import 'package:expense_tracker/core/theme/contrast.dart';
import 'package:expense_tracker/core/widgets/category_icon.dart';
import 'package:expense_tracker/features/categories/domain/services/category_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  const defaultKeys = [
    'food', 'transport', 'bills', 'shopping', 'health', 'entertainment', 'education', 'other', //
    'salary', 'freelance', 'gifts', 'investments', 'other_income',
  ];

  testWidgetsBothThemes('renders the icon for its key', (tester, brightness) async {
    await tester.pumpApp(
      const CategoryIcon(iconKey: 'food', color: 0xFF3949AB),
      brightness: brightness,
    );

    expect(tester.widget<Icon>(find.byType(Icon)).icon, Icons.restaurant_outlined);
  });

  testWidgets('a color readable as it is is drawn unchanged', (tester) async {
    await tester.pumpApp(const CategoryIcon(iconKey: 'food', color: 0xFF3949AB));

    expect(tester.widget<Icon>(find.byType(Icon)).color, const Color(0xFF3949AB));
  });

  testWidgets('a color too faint for the theme is darkened for display', (tester) async {
    await tester.pumpApp(const CategoryIcon(iconKey: 'food', color: 0xFFFDD835));

    final shown = tester.widget<Icon>(find.byType(Icon)).color!;
    expect(shown, isNot(const Color(0xFFFDD835)));
    expect(shown.computeLuminance(), lessThan(const Color(0xFFFDD835).computeLuminance()));
  });

  test('every default category key has its own icon', () {
    for (final key in defaultKeys) {
      expect(CategoryIcon.iconFor(key), isNot(CategoryIcon.fallback), reason: key);
      expect(CategoryIcon.keys, contains(key));
    }
  });

  test('unknown keys fall back instead of failing', () {
    expect(CategoryIcon.iconFor('from_a_newer_app'), CategoryIcon.fallback);
  });

  testWidgets('uses the given size and is decorative', (tester) async {
    await tester.pumpApp(const CategoryIcon(iconKey: 'bills', color: 0xFF8E24AA, size: 56));

    expect(tester.getSize(find.byType(CategoryIcon)), const Size(56, 56));
    expect(find.byType(ExcludeSemantics), findsWidgets);
  });

  testWidgetsBothThemes('every palette color stays visible (3:1) on every surface', (
    tester,
    brightness,
  ) async {
    await tester.pumpApp(
      Wrap(
        children: [
          for (final color in CategoryPalette.colors) CategoryIcon(iconKey: 'food', color: color),
        ],
      ),
      brightness: brightness,
    );
    final scheme = Theme.of(tester.element(find.byType(Wrap).first)).colorScheme;

    // Each glyph against its own tinted circle, on the lightest and darkest surface.
    final faint = [
      for (final (index, icon) in tester.widgetList<Icon>(find.byType(Icon)).indexed)
        for (final surface in [scheme.surface, scheme.surfaceContainerHighest])
          if (Contrast.ratio(
                icon.color!,
                Color.alphaBlend(
                  Color(CategoryPalette.colors[index]).withValues(alpha: 0.16),
                  surface,
                ),
              ) <
              3)
            Color(CategoryPalette.colors[index]),
    ];

    expect(faint, isEmpty);
  });
}
