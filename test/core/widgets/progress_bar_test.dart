import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/core/widgets/progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  ProgressBarPainter painter(WidgetTester tester) => tester
      .widgetList<CustomPaint>(
        find.descendant(of: find.byType(ProgressBar), matching: find.byType(CustomPaint)),
      )
      .map((p) => p.painter)
      .whereType<ProgressBarPainter>()
      .single;

  ThemeData theme(WidgetTester tester) => Theme.of(tester.element(find.byType(ProgressBar)));

  testWidgetsBothThemes('colors each level from the theme; the sprout droops when exceeded', (
    tester,
    brightness,
  ) async {
    for (final level in ProgressLevel.values) {
      await tester.pumpApp(ProgressBar(value: 0.5, level: level), brightness: brightness);
      final scheme = theme(tester).colorScheme;
      final colors = theme(tester).extension<AppColors>()!;
      final expected = switch (level) {
        ProgressLevel.normal => scheme.primary,
        ProgressLevel.warning => colors.accent,
        ProgressLevel.exceeded => scheme.error,
        ProgressLevel.complete => colors.leaf,
      };
      final bar = painter(tester);
      expect(bar.fill, expected, reason: level.name);
      expect(bar.track, colors.field);
      expect(bar.stem, colors.leafDeep);
      final exceeded = level == ProgressLevel.exceeded;
      expect(bar.droop, exceeded, reason: level.name);
      expect(bar.leaves, exceeded ? scheme.error : colors.leaf, reason: level.name);
    }
  });

  testWidgets('clamps the value to 0..1', (tester) async {
    await tester.pumpApp(const ProgressBar(value: 1.7));
    expect(painter(tester).fraction, 1.0);

    await tester.pumpApp(const ProgressBar(value: -0.2));
    await tester.pumpAndSettle();
    expect(painter(tester).fraction, 0.0);
  });

  test('the fill is at least as long as the bar is thick, at most the whole bar', () {
    const size = Size(200, 8);
    expect(ProgressBarPainter.fillWidth(size, 0), 8);
    expect(ProgressBarPainter.fillWidth(size, 0.5), 100);
    expect(ProgressBarPainter.fillWidth(size, 1.08), 200);
  });

  testWidgets('has the requested height', (tester) async {
    await tester.pumpApp(const ProgressBar(value: 0.3, height: 14));
    expect(tester.getSize(find.byType(ProgressBar)).height, 14);
  });

  testWidgets('springs to a new value (overshoots, then settles)', (tester) async {
    final value = ValueNotifier(0.2);
    addTearDown(value.dispose);
    await tester.pumpApp(
      ValueListenableBuilder(
        valueListenable: value,
        builder: (_, v, _) => ProgressBar(value: v),
      ),
    );
    expect(painter(tester).fraction, 0.2);

    value.value = 0.6;
    await tester.pump();
    var peak = 0.0;
    for (var i = 0; i < 25; i++) {
      await tester.pump(const Duration(milliseconds: 20));
      if (painter(tester).fraction > peak) peak = painter(tester).fraction;
    }
    expect(peak, greaterThan(0.6));
    expect(painter(tester).fraction, closeTo(0.6, 1e-9));
  });

  testWidgets('reduce motion: a new value shows at once', (tester) async {
    final value = ValueNotifier(0.2);
    addTearDown(value.dispose);
    await tester.pumpApp(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: ValueListenableBuilder(
          valueListenable: value,
          builder: (_, v, _) => ProgressBar(value: v),
        ),
      ),
    );
    value.value = 0.6;
    await tester.pump();
    expect(painter(tester).fraction, 0.6);
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('announces its label and value', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpApp(const ProgressBar(value: 0.42, semanticsLabel: 'Food'));

    expect(find.bySemanticsLabel('Food'), findsOneWidget);
    expect(tester.getSemantics(find.bySemanticsLabel('Food')).value, '42');
    handle.dispose();
  });
}
