import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/core/widgets/progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  LinearProgressIndicator indicator(WidgetTester tester) =>
      tester.widget(find.byType(LinearProgressIndicator));

  ThemeData theme(WidgetTester tester) =>
      Theme.of(tester.element(find.byType(LinearProgressIndicator)));

  testWidgetsBothThemes('colors each level from the theme', (tester, brightness) async {
    for (final level in ProgressLevel.values) {
      await tester.pumpApp(ProgressBar(value: 0.5, level: level), brightness: brightness);
      final colors = theme(tester).extension<AppColors>()!;
      final expected = switch (level) {
        ProgressLevel.normal => theme(tester).colorScheme.primary,
        ProgressLevel.warning => colors.warning,
        ProgressLevel.exceeded => colors.expense,
      };
      expect(indicator(tester).color, expected, reason: level.name);
    }
  });

  testWidgets('clamps the value to 0..1', (tester) async {
    await tester.pumpApp(const ProgressBar(value: 1.7));
    expect(indicator(tester).value, 1.0);

    await tester.pumpApp(const ProgressBar(value: -0.2));
    expect(indicator(tester).value, 0.0);
  });

  testWidgets('announces its label and value', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpApp(const ProgressBar(value: 0.42, semanticsLabel: 'Food'));

    expect(find.bySemanticsLabel('Food'), findsOneWidget);
    expect(tester.getSemantics(find.bySemanticsLabel('Food')).value, '42');
    handle.dispose();
  });
}
