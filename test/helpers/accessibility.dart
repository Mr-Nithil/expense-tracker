import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Flutter's accessibility guidelines checked by [expectAccessible] (M9.5): tap targets of at
/// least 48x48 (Android) and 44x44 (iOS), a label on everything tappable, and text contrast of at
/// least 4.5:1 (3:1 for large text).
final accessibilityGuidelines = <AccessibilityGuideline>[
  androidTapTargetGuideline,
  iOSTapTargetGuideline,
  labeledTapTargetGuideline,
  textContrastGuideline,
];

/// Why what is on screen breaks [accessibilityGuidelines]; empty when it doesn't.
Future<List<String>> accessibilityProblems(WidgetTester tester) async {
  final handle = tester.ensureSemantics();
  await tester.pump();
  final problems = <String>[];
  for (final guideline in accessibilityGuidelines) {
    final evaluation = await guideline.evaluate(tester);
    if (!evaluation.passed) problems.add('${guideline.description}: ${evaluation.reason}');
  }
  handle.dispose();
  return problems;
}

/// Fails the test, listing every problem, when what is on screen breaks a guideline.
Future<void> expectAccessible(WidgetTester tester) async {
  expect(await accessibilityProblems(tester), isEmpty);
}

/// Sets the system text size (as in the phone's accessibility settings) for this test.
/// Call before pumping. Android allows up to 2x.
void useTextScale(WidgetTester tester, double factor) {
  tester.platformDispatcher.textScaleFactorTestValue = factor;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}

/// Scrolls the main (first) scrollable to its end, so every item is built and laid out (an
/// overflow anywhere fails the test). Does nothing when nothing scrolls.
Future<void> scrollThrough(WidgetTester tester) async {
  final scrollable = find.byType(Scrollable);
  if (scrollable.evaluate().isEmpty) return;
  final state = tester.state<ScrollableState>(scrollable.first);
  for (var i = 0; i < 50 && state.position.extentAfter > 0; i++) {
    await tester.drag(scrollable.first, const Offset(0, -300), warnIfMissed: false);
    await tester.pumpAndSettle();
  }
}
