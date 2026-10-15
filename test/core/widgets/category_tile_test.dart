import 'package:expense_tracker/core/widgets/category_tile.dart';
import 'package:expense_tracker/core/widgets/chunky_pressable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/accessibility.dart';
import '../../helpers/pump_app.dart';

void main() {
  Future<List<String>> pump(WidgetTester tester, {Brightness brightness = Brightness.light}) async {
    final taps = <String>[];
    await tester.pumpApp(
      Row(
        children: [
          CategoryTile(
            icon: Icons.restaurant_rounded,
            semanticLabel: 'Icon 1 of 2',
            selected: true,
            onTap: () => taps.add('1'),
          ),
          CategoryTile(
            icon: Icons.directions_bus_rounded,
            semanticLabel: 'Icon 2 of 2',
            selected: false,
            onTap: () => taps.add('2'),
          ),
        ],
      ),
      brightness: brightness,
    );
    return taps;
  }

  testWidgetsBothThemes('selected is primary; tiles are 50 px selectable buttons', (
    tester,
    brightness,
  ) async {
    final taps = await pump(tester, brightness: brightness);

    await tester.tap(find.bySemanticsLabel('Icon 2 of 2'));
    expect(taps, ['2']);
    expect(
      tester.getSemantics(find.bySemanticsLabel('Icon 1 of 2')),
      isSemantics(isButton: true, isSelected: true, hasSelectedState: true),
    );
    final scheme = Theme.of(tester.element(find.byType(Row))).colorScheme;
    final selected = tester.widget<Material>(
      find
          .ancestor(of: find.byIcon(Icons.restaurant_rounded), matching: find.byType(Material))
          .first,
    );
    expect(selected.color, scheme.primary);
    expect(tester.getSize(find.byType(InkWell).first), const Size.square(CategoryTile.size));
    expect(find.byType(ChunkyPressable), findsNWidgets(2));
  });

  group('accessibility (M9.5)', () {
    testWidgetsBothThemes('meets the guidelines', (tester, brightness) async {
      await pump(tester, brightness: brightness);
      await expectAccessible(tester);
    });
  });
}
