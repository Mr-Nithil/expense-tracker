import 'package:expense_tracker/core/widgets/leaf_confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  Duration seconds(double s) => Duration(microseconds: (s * 1e6).round());

  group('leafAt', () {
    test('spreads the leaves across the width and staggers their start', () {
      expect(LeafConfettiPainter.leafAt(0, Duration.zero, 780)!.x, 0.07);
      expect(LeafConfettiPainter.leafAt(1, seconds(0.3), 780)!.x, 0.60);
      expect(LeafConfettiPainter.leafAt(1, seconds(0.29), 780), isNull);
      expect(LeafConfettiPainter.leafAt(6, seconds(1.79), 780), isNull);
      expect(LeafConfettiPainter.leafAt(7, Duration.zero, 780), isNotNull, reason: 'delay 0 again');
    });

    test('falls from above the top to the bottom, turning 620°, then loops', () {
      final start = LeafConfettiPainter.leafAt(0, Duration.zero, 780)!;
      expect(start.y, -30);
      expect(start.degrees, 0);
      expect(start.opacity, 0);

      // Leaf 0 lasts 2.6 s; leaf 1 lasts 3.05 s.
      final almostDown = LeafConfettiPainter.leafAt(0, seconds(2.599), 780)!;
      expect(almostDown.y, closeTo(780, 2));
      expect(almostDown.degrees, closeTo(620, 2));
      expect(almostDown.opacity, closeTo(0.9, 0.01));

      final again = LeafConfettiPainter.leafAt(0, seconds(2.6), 780)!;
      expect(again.y, closeTo(-30, 1e-6));

      final slower = LeafConfettiPainter.leafAt(1, seconds(0.3 + 2.6), 780)!;
      expect(slower.y, lessThan(780));
    });

    test('fades in over the first 10 %', () {
      final early = LeafConfettiPainter.leafAt(0, seconds(0.13), 780)!;
      expect(early.opacity, inExclusiveRange(0, 1));
      expect(LeafConfettiPainter.leafAt(0, seconds(0.26), 780)!.opacity, closeTo(1, 1e-6));
    });
  });

  testWidgetsBothThemes('animates over its area and ignores touches', (tester, brightness) async {
    var taps = 0;
    await tester.pumpApp(
      Stack(
        children: [
          Positioned.fill(
            child: TextButton(onPressed: () => taps++, child: const Text('Under')),
          ),
          const Positioned.fill(child: LeafConfetti()),
        ],
      ),
      brightness: brightness,
    );
    await tester.pump(const Duration(seconds: 1));
    expect(tester.hasRunningAnimations, isTrue);
    expect(tester.takeException(), isNull);

    await tester.tap(findText('Under'));
    expect(taps, 1);
  });

  testWidgets('reduce motion: draws nothing and runs nothing', (tester) async {
    await tester.pumpApp(
      const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: LeafConfetti(),
      ),
    );
    expect(tester.hasRunningAnimations, isFalse);
    expect(
      find.descendant(of: find.byType(LeafConfetti), matching: find.byType(CustomPaint)),
      findsNothing,
    );
  });
}
