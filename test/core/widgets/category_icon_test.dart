import 'package:expense_tracker/core/widgets/category_icon.dart';
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
      const CategoryIcon(iconKey: 'food', color: 0xFFEF6C00),
      brightness: brightness,
    );

    final icon = tester.widget<Icon>(find.byType(Icon));
    expect(icon.icon, Icons.restaurant_outlined);
    expect(icon.color, const Color(0xFFEF6C00));
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
}
