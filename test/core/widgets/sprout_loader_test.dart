import 'package:expense_tracker/core/widgets/sprout_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  SproutLoaderPainter painter(WidgetTester tester) => tester
      .widgetList<CustomPaint>(
        find.descendant(of: find.byType(SproutLoader), matching: find.byType(CustomPaint)),
      )
      .map((p) => p.painter)
      .whereType<SproutLoaderPainter>()
      .single;

  group('keyframes (1.8 s loop)', () {
    test('the stem grows to full length in the first 32 %', () {
      expect(SproutLoaderPainter.stemLength(0), 0);
      expect(SproutLoaderPainter.stemLength(0.16), inExclusiveRange(0, 18));
      expect(SproutLoaderPainter.stemLength(0.32), 18);
      expect(SproutLoaderPainter.stemLength(0.9), 18);
    });

    test('the left leaf pops at 28–56 %, the right one at 40–68 %', () {
      for (final (start, peak, settle) in [(0.28, 0.46, 0.56), (0.40, 0.58, 0.68)]) {
        expect(SproutLoaderPainter.leafScale(start - 0.1, start), 0);
        expect(SproutLoaderPainter.leafScale(start, start), 0);
        expect(SproutLoaderPainter.leafScale(peak, start), closeTo(1.2, 1e-3));
        expect(SproutLoaderPainter.leafScale(settle, start), closeTo(1, 1e-3));
        expect(SproutLoaderPainter.leafScale(0.9, start), 1);
      }
    });

    test('everything fades out between 80 % and 95 %', () {
      expect(SproutLoaderPainter.opacity(0.5), 1);
      expect(SproutLoaderPainter.opacity(0.8), 1);
      expect(SproutLoaderPainter.opacity(0.875), inExclusiveRange(0, 1));
      expect(SproutLoaderPainter.opacity(0.95), 0);
      expect(SproutLoaderPainter.opacity(1), 0);
    });

    test('still (reduce motion) is fully grown and visible', () {
      expect(SproutLoaderPainter.stemLength(null), 18);
      expect(SproutLoaderPainter.leafScale(null, 0.28), 1);
      expect(SproutLoaderPainter.opacity(null), 1);
    });
  });

  testWidgetsBothThemes('loops and paints in the primary color by default', (
    tester,
    brightness,
  ) async {
    await tester.pumpApp(const Center(child: SproutLoader()), brightness: brightness);
    final primary = Theme.of(tester.element(find.byType(SproutLoader))).colorScheme.primary;
    expect(painter(tester).color, primary);

    final first = painter(tester).t;
    await tester.pump(const Duration(milliseconds: 600));
    expect(painter(tester).t, isNot(first));
    expect(tester.hasRunningAnimations, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reduce motion: stands still, fully grown', (tester) async {
    await tester.pumpApp(
      const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: Center(child: SproutLoader()),
      ),
    );
    expect(tester.hasRunningAnimations, isFalse);
    expect(painter(tester).t, isNull);
  });

  testWidgets('has the requested size and color', (tester) async {
    await tester.pumpApp(const Center(child: SproutLoader(size: 34, color: Color(0xFF123456))));
    expect(tester.getSize(find.byType(SproutLoader)), const Size.square(34));
    expect(painter(tester).color, const Color(0xFF123456));
  });

  testWidgets('announced only when labelled', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpApp(const Center(child: SproutLoader(semanticsLabel: 'Loading')));
    expect(find.bySemanticsLabel('Loading'), findsOneWidget);

    await tester.pumpApp(const Center(child: SproutLoader()));
    expect(
      find.descendant(of: find.byType(SproutLoader), matching: find.byType(ExcludeSemantics)),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('Loading'), findsNothing);
    handle.dispose();
  });
}
