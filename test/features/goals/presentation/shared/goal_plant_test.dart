import 'package:expense_tracker/features/goals/domain/entities/goal_stage.dart';
import 'package:expense_tracker/features/goals/presentation/shared/goal_plant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  GoalPlantPainter painter(WidgetTester tester) => tester
      .widgetList<CustomPaint>(
        find.descendant(of: find.byType(GoalPlant), matching: find.byType(CustomPaint)),
      )
      .map((p) => p.painter)
      .whereType<GoalPlantPainter>()
      .single;

  double scale(WidgetTester tester) => tester
      .widget<Transform>(
        find.descendant(of: find.byType(GoalPlant), matching: find.byType(Transform)),
      )
      .transform
      .storage[0];

  Widget host(ValueNotifier<GoalStage> stage, {bool reduceMotion = false}) => MediaQuery(
    data: MediaQueryData(disableAnimations: reduceMotion),
    child: Center(
      child: ValueListenableBuilder(
        valueListenable: stage,
        builder: (_, s, _) => GoalPlant(stage: s),
      ),
    ),
  );

  test('the stem grows with each stage', () {
    expect(GoalStage.values.map(GoalPlantPainter.heightOf), [0, 18, 34, 48, 58]);
  });

  testWidgetsBothThemes('every stage paints', (tester, brightness) async {
    for (final stage in GoalStage.values) {
      await tester.pumpApp(
        Center(child: GoalPlant(stage: stage)),
        brightness: brightness,
      );
      await tester.pump(const Duration(milliseconds: 700));
      expect(tester.takeException(), isNull, reason: stage.name);
      expect(painter(tester).stage, stage);
    }
  });

  testWidgets('has the requested size', (tester) async {
    await tester.pumpApp(const Center(child: GoalPlant(stage: GoalStage.seedling, size: 120)));
    expect(tester.getSize(find.byType(CustomPaint).last), const Size.square(120));
  });

  testWidgets('sways, and pops in again on a new stage', (tester) async {
    final stage = ValueNotifier(GoalStage.sprout);
    addTearDown(stage.dispose);
    await tester.pumpApp(host(stage));
    await tester.pump(const Duration(milliseconds: 50));
    expect(scale(tester), lessThan(1), reason: 'pops in when first shown');
    await tester.pump(const Duration(seconds: 1));
    expect(scale(tester), 1);
    expect(painter(tester).swayDegrees, isNot(0));

    stage.value = GoalStage.seedling;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(scale(tester), lessThan(1));
    await tester.pump(const Duration(milliseconds: 600));
    expect(scale(tester), 1);
    expect(painter(tester).stage, GoalStage.seedling);
  });

  testWidgets('reduce motion: no sway, no pop', (tester) async {
    final stage = ValueNotifier(GoalStage.sprout);
    addTearDown(stage.dispose);
    await tester.pumpApp(host(stage, reduceMotion: true));
    expect(tester.hasRunningAnimations, isFalse);
    expect(scale(tester), 1);
    expect(painter(tester).swayDegrees, 0);

    stage.value = GoalStage.bloom;
    await tester.pump();
    expect(tester.hasRunningAnimations, isFalse);
    expect(scale(tester), 1);
    expect(painter(tester).stage, GoalStage.bloom);
  });

  testWidgets('decorative unless labelled', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpApp(const Center(child: GoalPlant(stage: GoalStage.bloom)));
    expect(find.bySemanticsLabel('Bike plant'), findsNothing);

    await tester.pumpApp(
      const Center(
        child: GoalPlant(stage: GoalStage.bloom, semanticsLabel: 'Bike plant'),
      ),
    );
    expect(find.bySemanticsLabel('Bike plant'), findsOneWidget);
    handle.dispose();
  });
}
