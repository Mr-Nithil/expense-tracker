import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/core/widgets/progress_bar.dart';
import 'package:expense_tracker/core/widgets/progress_ring.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  ProgressRingPainter painter(WidgetTester tester) => tester
      .widgetList<CustomPaint>(
        find.descendant(of: find.byType(ProgressRing), matching: find.byType(CustomPaint)),
      )
      .map((p) => p.painter)
      .whereType<ProgressRingPainter>()
      .single;

  ThemeData theme(WidgetTester tester) => Theme.of(tester.element(find.byType(ProgressRing)));

  testWidgetsBothThemes('a leaf ring on field; warning and exceeded keep their colors', (
    tester,
    brightness,
  ) async {
    for (final level in ProgressLevel.values) {
      await tester.pumpApp(ProgressRing(value: 0.5, level: level), brightness: brightness);
      final colors = theme(tester).extension<AppColors>()!;
      final expected = switch (level) {
        ProgressLevel.normal || ProgressLevel.complete => colors.leaf,
        ProgressLevel.warning => colors.accent,
        ProgressLevel.exceeded => theme(tester).colorScheme.error,
      };
      expect(painter(tester).arc, expected, reason: level.name);
      expect(painter(tester).track, colors.field);
    }
  });

  testWidgets('clamps the value and shows its label in the middle', (tester) async {
    await tester.pumpApp(const Center(child: ProgressRing(value: 1.4, child: Text('140%'))));

    expect(painter(tester).fraction, 1.0);
    expect(findText('140%'), findsOneWidget);
    expect(tester.getCenter(findText('140%')), tester.getCenter(find.byType(ProgressRing)));
  });

  testWidgets('has the requested size; the ring is an eighth of it', (tester) async {
    await tester.pumpApp(const Center(child: ProgressRing(value: 0.2, size: 64)));

    expect(tester.getSize(find.byType(ProgressRing)), const Size.square(64));
    expect(ProgressRingPainter.thicknessOf(64), 8);
  });

  testWidgets('announces its label and value', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpApp(const ProgressRing(value: 0.3, semanticsLabel: 'Laptop'));

    expect(find.bySemanticsLabel('Laptop'), findsOneWidget);
    expect(tester.getSemantics(find.bySemanticsLabel('Laptop')).value, '30');
    handle.dispose();
  });
}
