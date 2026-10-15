import 'package:expense_tracker/core/widgets/app_filter_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/accessibility.dart';
import '../../helpers/pump_app.dart';

void main() {
  Future<List<bool>> pump(WidgetTester tester, {Brightness brightness = Brightness.light}) async {
    final changes = <bool>[];
    await tester.pumpApp(
      Wrap(
        children: [
          AppFilterChip(label: 'Mon', selected: true, onSelected: changes.add),
          AppFilterChip(label: 'Tue', selected: false, onSelected: changes.add),
        ],
      ),
      brightness: brightness,
    );
    return changes;
  }

  testWidgetsBothThemes('reports taps; the selected label is light on the ink pill', (
    tester,
    brightness,
  ) async {
    final changes = await pump(tester, brightness: brightness);

    await tester.tap(find.text('Tue'));
    expect(changes, [true]);
    final scheme = Theme.of(tester.element(find.byType(Wrap))).colorScheme;
    final selected = tester.widget<FilterChip>(find.widgetWithText(FilterChip, 'Mon'));
    expect(selected.labelStyle?.color, scheme.surface);
    expect(selected.showCheckmark, isFalse);
  });

  group('accessibility (M9.5)', () {
    testWidgetsBothThemes('meets the guidelines (incl. contrast on the selection)', (
      tester,
      brightness,
    ) async {
      await pump(tester, brightness: brightness);
      await expectAccessible(tester);
    });
  });
}
