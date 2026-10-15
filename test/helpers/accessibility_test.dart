import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'accessibility.dart';
import 'finders.dart';

/// The accessibility helpers really catch problems (so green screen tests mean something).
void main() {
  Future<void> pump(WidgetTester tester, Widget child) => tester.pumpWidget(
    MaterialApp(
      home: Scaffold(body: Center(child: child)),
    ),
  );

  testWidgets('a small unlabelled tap target fails', (tester) async {
    await pump(
      tester,
      GestureDetector(onTap: () {}, child: const SizedBox(width: 20, height: 20)),
    );

    expect(await accessibilityProblems(tester), isNotEmpty);
  });

  testWidgets('low-contrast text fails', (tester) async {
    await pump(
      tester,
      const ColoredBox(
        color: Color(0xFFFFFFFF),
        child: Text('Faint', style: TextStyle(color: Color(0xFFDDDDDD), fontSize: 14)),
      ),
    );

    expect(await accessibilityProblems(tester), isNotEmpty);
  });

  testWidgets('a labelled, large enough button passes', (tester) async {
    await pump(tester, IconButton(onPressed: () {}, tooltip: 'Add', icon: const Icon(Icons.add)));

    await expectAccessible(tester);
  });

  Widget row() => const SizedBox(
    width: 40,
    child: Row(children: [Text('Hi')]),
  );

  testWidgets('text that fits at normal size passes', (tester) async {
    await pump(tester, row());

    expect(tester.takeException(), isNull);
  });

  testWidgets('the same text at 2x is reported as overflowing', (tester) async {
    useTextScale(tester, 2);
    await pump(tester, row());

    expect(tester.takeException(), isFlutterError);
    final context = tester.element(findText('Hi'));
    expect(MediaQuery.textScalerOf(context).scale(10), 20);
  });

  testWidgets('scrollThrough reaches the end of a long list', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView(children: [for (var i = 0; i < 100; i++) Text('Row $i')]),
        ),
      ),
    );
    expect(findText('Row 99'), findsNothing);

    await scrollThrough(tester);

    expect(findText('Row 99'), findsOneWidget);
  });
}
