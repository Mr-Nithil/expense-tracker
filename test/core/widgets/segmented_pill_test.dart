import 'package:expense_tracker/core/widgets/segmented_pill.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/accessibility.dart';
import '../../helpers/pump_app.dart';

void main() {
  Future<List<String>> pump(
    WidgetTester tester, {
    String selected = 'b',
    bool enabled = true,
    Brightness brightness = Brightness.light,
  }) async {
    final changes = <String>[];
    await tester.pumpApp(
      Padding(
        padding: const EdgeInsets.all(16),
        child: SegmentedPill<String>(
          options: const [
            SegmentedPillOption(value: 'a', label: 'Expense'),
            SegmentedPillOption(value: 'b', label: 'Income', icon: Icons.add),
            SegmentedPillOption(value: 'c', label: 'All'),
          ],
          selected: selected,
          onChanged: enabled ? changes.add : null,
        ),
      ),
      brightness: brightness,
    );
    return changes;
  }

  testWidgetsBothThemes('tapping another segment reports it; the selected one does nothing', (
    tester,
    brightness,
  ) async {
    final changes = await pump(tester, brightness: brightness);

    await tester.tap(find.text('Expense'));
    await tester.tap(find.text('Income'));
    expect(changes, ['a']);
  });

  testWidgets('segments are buttons with a selected state in one group', (tester) async {
    await pump(tester);

    expect(
      tester.getSemantics(find.text('Income')),
      isSemantics(isButton: true, isInMutuallyExclusiveGroup: true, isSelected: true),
    );
    expect(
      tester.getSemantics(find.text('All')),
      isSemantics(isButton: true, isInMutuallyExclusiveGroup: true, isSelected: false),
    );
  });

  testWidgets('disabled: nothing reported', (tester) async {
    final changes = await pump(tester, enabled: false);
    await tester.tap(find.text('Expense'), warnIfMissed: false);
    expect(changes, isEmpty);
  });

  testWidgets('every segment is at least 48 px tall', (tester) async {
    await pump(tester);
    for (final label in ['Expense', 'Income', 'All']) {
      final cell = find.ancestor(of: find.text(label), matching: find.byType(InkWell));
      expect(tester.getSize(cell).height, greaterThanOrEqualTo(48));
    }
  });

  group('accessibility (M9.5)', () {
    testWidgetsBothThemes('meets the guidelines', (tester, brightness) async {
      await pump(tester, brightness: brightness);
      await expectAccessible(tester);
    });

    testWidgets('large text (2x) fits', (tester) async {
      useTextScale(tester, 2);
      await pump(tester);
      expect(tester.takeException(), isNull);
    });
  });
}
