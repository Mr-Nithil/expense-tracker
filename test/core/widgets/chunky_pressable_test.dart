import 'package:expense_tracker/core/widgets/chunky_pressable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  const depth = 4.0;

  Future<void> pump(WidgetTester tester, {bool enabled = true, bool reduceMotion = false}) =>
      tester.pumpApp(
        MediaQuery(
          data: MediaQueryData(disableAnimations: reduceMotion),
          child: Center(
            child: ChunkyPressable(
              shadowColor: Colors.green,
              radius: BorderRadius.circular(18),
              enabled: enabled,
              child: const SizedBox(width: 100, height: 50, child: Text('tap')),
            ),
          ),
        ),
      );

  AnimatedContainer box(WidgetTester tester) =>
      tester.widget<AnimatedContainer>(find.byType(AnimatedContainer));
  double offsetY(WidgetTester tester) => box(tester).transform!.getTranslation().y;
  bool hasShadow(WidgetTester tester) =>
      ((box(tester).decoration! as BoxDecoration).boxShadow ?? const []).isNotEmpty;

  testWidgets('lifted with a solid shadow; pressing sinks it, releasing lifts it', (tester) async {
    await pump(tester);
    expect(hasShadow(tester), isTrue);
    expect((box(tester).decoration! as BoxDecoration).boxShadow!.single.blurRadius, 0);
    expect(offsetY(tester), 0);

    final gesture = await tester.startGesture(tester.getCenter(find.text('tap')));
    await tester.pump();
    expect(offsetY(tester), depth);
    expect(hasShadow(tester), isFalse);

    await gesture.up();
    await tester.pump();
    expect(offsetY(tester), 0);
    expect(hasShadow(tester), isTrue);
  });

  testWidgets('disabled: flat and never moves', (tester) async {
    await pump(tester, enabled: false);
    expect(hasShadow(tester), isFalse);

    final gesture = await tester.startGesture(tester.getCenter(find.text('tap')));
    await tester.pump();
    expect(offsetY(tester), 0);
    await gesture.up();
  });

  testWidgets('reduce motion: the press is instant', (tester) async {
    await pump(tester, reduceMotion: true);
    expect(box(tester).duration, Duration.zero);
  });

  testWidgets('keeps room for its shadow below', (tester) async {
    await pump(tester);
    expect(tester.getSize(find.byType(ChunkyPressable)).height, 50 + depth);
  });
}
