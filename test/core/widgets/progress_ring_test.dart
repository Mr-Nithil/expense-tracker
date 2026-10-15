import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/core/widgets/progress_bar.dart';
import 'package:expense_tracker/core/widgets/progress_ring.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  CircularProgressIndicator indicator(WidgetTester tester) =>
      tester.widget(find.byType(CircularProgressIndicator));

  ThemeData theme(WidgetTester tester) =>
      Theme.of(tester.element(find.byType(CircularProgressIndicator)));

  testWidgetsBothThemes('colors each level from the theme', (tester, brightness) async {
    for (final level in ProgressLevel.values) {
      await tester.pumpApp(ProgressRing(value: 0.5, level: level), brightness: brightness);
      final colors = theme(tester).extension<AppColors>()!;
      final expected = switch (level) {
        ProgressLevel.normal => theme(tester).colorScheme.primary,
        ProgressLevel.warning => colors.warning,
        ProgressLevel.exceeded => colors.expense,
        ProgressLevel.complete => colors.success,
      };
      expect(indicator(tester).color, expected, reason: level.name);
    }
  });

  testWidgets('clamps the value and shows its label in the middle', (tester) async {
    await tester.pumpApp(const Center(child: ProgressRing(value: 1.4, child: Text('140%'))));

    expect(indicator(tester).value, 1.0);
    expect(findText('140%'), findsOneWidget);
    expect(
      tester.getCenter(findText('140%')),
      tester.getCenter(find.byType(CircularProgressIndicator)),
    );
  });

  testWidgets('has the requested size', (tester) async {
    await tester.pumpApp(const Center(child: ProgressRing(value: 0.2, size: 64)));

    expect(tester.getSize(find.byType(ProgressRing)), const Size.square(64));
  });

  testWidgets('announces its label', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpApp(const ProgressRing(value: 0.3, semanticsLabel: 'Laptop'));

    expect(find.bySemanticsLabel('Laptop'), findsOneWidget);
    handle.dispose();
  });
}
