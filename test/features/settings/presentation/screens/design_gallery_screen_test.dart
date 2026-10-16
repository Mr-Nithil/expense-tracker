import 'package:expense_tracker/core/widgets/leaf_confetti.dart';
import 'package:expense_tracker/core/widgets/pip.dart';
import 'package:expense_tracker/features/goals/domain/entities/goal_stage.dart';
import 'package:expense_tracker/features/goals/presentation/shared/goal_plant.dart';
import 'package:expense_tracker/features/settings/presentation/screens/design_gallery_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  testWidgetsBothThemes('previews every mood, stage and component', (tester, brightness) async {
    await tester.pumpApp(const DesignGalleryScreen(), brightness: brightness);
    await tester.pump(const Duration(milliseconds: 700));

    for (final mood in PipMood.values) {
      expect(findText(mood.name), findsOneWidget);
    }
    for (final stage in GoalStage.values) {
      await tester.scrollUntilVisible(findText(stage.name), 200);
      expect(findText(stage.name), findsOneWidget);
    }
    await tester.scrollUntilVisible(find.byType(LeafConfetti), 200);
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('the slider drives the shared bar, ring and plant', (tester) async {
    await tester.pumpApp(const DesignGalleryScreen());
    await tester.scrollUntilVisible(find.byType(Slider), 200);
    await tester.pump(const Duration(milliseconds: 700));
    final plant = find.byWidgetPredicate((w) => w is GoalPlant && w.size == 120);
    expect(tester.widget<GoalPlant>(plant).stage, GoalStage.seedling);

    await tester.drag(find.byType(Slider), const Offset(1000, 0));
    await tester.pump(const Duration(milliseconds: 700));
    expect(tester.widget<GoalPlant>(plant).stage, GoalStage.bloom);
  });

  testWidgets('reduce motion: the whole gallery stands still', (tester) async {
    await tester.pumpApp(
      const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: DesignGalleryScreen(),
      ),
    );
    await tester.pump();
    expect(tester.hasRunningAnimations, isFalse);
  });
}
