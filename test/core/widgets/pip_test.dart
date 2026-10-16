import 'package:expense_tracker/core/widgets/pip.dart';
import 'package:expense_tracker/core/widgets/pip_speech_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  PipPainter painter(WidgetTester tester) => tester
      .widgetList<CustomPaint>(
        find.descendant(of: find.byType(Pip), matching: find.byType(CustomPaint)),
      )
      .map((p) => p.painter)
      .whereType<PipPainter>()
      .single;

  Future<void> pump(WidgetTester tester, Pip pip, {bool reduceMotion = false}) => tester.pumpApp(
    MediaQuery(
      data: MediaQueryData(disableAnimations: reduceMotion),
      child: Center(child: pip),
    ),
  );

  testWidgetsBothThemes('every mood paints, with covered eyes and waving too', (
    tester,
    brightness,
  ) async {
    for (final mood in PipMood.values) {
      for (final (cover, wave) in [(false, false), (true, false), (false, true)]) {
        await tester.pumpApp(
          Center(
            child: Pip(mood: mood, coverEyes: cover, wave: wave, size: 120),
          ),
          brightness: brightness,
        );
        await tester.pump(const Duration(milliseconds: 500));
        expect(tester.takeException(), isNull, reason: '$mood cover=$cover wave=$wave');
        expect(painter(tester).mood, mood);
      }
    }
  });

  testWidgets('covering the eyes animates the hands up (380 ms)', (tester) async {
    await pump(tester, const Pip(idle: PipIdle.none));
    expect(painter(tester).cover, 0);

    await pump(tester, const Pip(idle: PipIdle.none, coverEyes: true));
    await tester.pump(const Duration(milliseconds: 100));
    expect(painter(tester).cover, inExclusiveRange(0, 1.2));
    await tester.pump(const Duration(milliseconds: 400));
    expect(painter(tester).cover, closeTo(1, 0.001));
  });

  testWidgets('waving swings the right hand; not waving leaves it down', (tester) async {
    await pump(tester, const Pip(wave: true));
    await tester.pump(const Duration(milliseconds: 350));
    expect(painter(tester).waveDegrees, isNot(-25));

    await pump(tester, const Pip());
    expect(painter(tester).waveDegrees, isNull);
  });

  testWidgets('idle bob and leaf sway keep moving', (tester) async {
    await pump(tester, const Pip());
    await tester.pump(const Duration(milliseconds: 700));
    final sway = painter(tester).swayDegrees;
    await tester.pump(const Duration(milliseconds: 700));
    expect(painter(tester).swayDegrees, isNot(sway));
    expect(tester.hasRunningAnimations, isTrue);
  });

  testWidgets('reduce motion: nothing loops; covering the eyes is instant', (tester) async {
    final cover = ValueNotifier(false);
    addTearDown(cover.dispose);
    await tester.pumpApp(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: Center(
          child: ValueListenableBuilder(
            valueListenable: cover,
            builder: (_, covered, _) => Pip(wave: true, coverEyes: covered, idle: PipIdle.jump),
          ),
        ),
      ),
    );
    expect(tester.hasRunningAnimations, isFalse);
    expect(painter(tester).swayDegrees, 0);

    cover.value = true;
    await tester.pump();
    expect(painter(tester).cover, 1);
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('a new shake trigger shakes once', (tester) async {
    await pump(tester, const Pip(idle: PipIdle.none));
    await pump(tester, const Pip(idle: PipIdle.none, shakeTrigger: 1));
    await tester.pump(const Duration(milliseconds: 100));
    final offset = tester.widget<Transform>(
      find.descendant(of: find.byType(Pip), matching: find.byType(Transform)).first,
    );
    expect(offset.transform.getTranslation().x, isNot(0));
    await tester.pump(const Duration(milliseconds: 500));
    expect(
      tester
          .widget<Transform>(
            find.descendant(of: find.byType(Pip), matching: find.byType(Transform)).first,
          )
          .transform
          .getTranslation()
          .x,
      0,
    );
  });

  testWidgets('decorative unless labelled', (tester) async {
    await pump(tester, const Pip(idle: PipIdle.none));
    expect(find.bySemanticsLabel('Pip'), findsNothing);

    await pump(tester, const Pip(idle: PipIdle.none, semanticsLabel: 'Pip'));
    expect(find.bySemanticsLabel('Pip'), findsOneWidget);
  });

  group('PipSpeechBubble', () {
    testWidgetsBothThemes('shows and announces its text', (tester, brightness) async {
      await tester.pumpApp(
        const Center(child: PipSpeechBubble(text: 'Welcome back!')),
        brightness: brightness,
      );
      await tester.pumpAndSettle();
      expect(find.text('Welcome back!'), findsOneWidget);
      expect(
        tester.getSemantics(find.text('Welcome back!')),
        isSemantics(label: 'Welcome back!', isLiveRegion: true),
      );
    });

    testWidgets('pops in (springy) unless reduce motion is on', (tester) async {
      await pump(tester, const Pip(idle: PipIdle.none));
      await tester.pumpApp(const Center(child: PipSpeechBubble(text: 'Hi')));
      await tester.pump(const Duration(milliseconds: 50));
      final scale = tester.widget<Transform>(
        find.ancestor(of: find.text('Hi'), matching: find.byType(Transform)).first,
      );
      expect(scale.transform.storage[0], lessThan(1));

      await tester.pumpApp(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: Center(child: PipSpeechBubble(text: 'Hello')),
        ),
      );
      await tester.pump();
      final still = tester.widget<Transform>(
        find.ancestor(of: find.text('Hello'), matching: find.byType(Transform)).first,
      );
      expect(still.transform.storage[0], 1);
    });
  });
}
