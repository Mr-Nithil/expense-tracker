import 'package:expense_tracker/core/widgets/app_card.dart';
import 'package:expense_tracker/core/widgets/chunky_pressable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgetsBothThemes('renders its child and fires onTap', (tester, brightness) async {
    var taps = 0;
    await tester.pumpApp(
      AppCard(onTap: () => taps++, child: const Text('Card')),
      brightness: brightness,
    );
    await tester.tap(findText('Card'));
    expect(taps, 1);
  });

  testWidgets('a bordered surface with a solid shadow; only tappable cards sink', (tester) async {
    await tester.pumpApp(
      Column(
        children: [
          const AppCard(child: Text('Static')),
          AppCard(onTap: () {}, child: const Text('Tappable')),
        ],
      ),
    );

    final material = tester.widget<Material>(
      find.ancestor(of: find.text('Static'), matching: find.byType(Material)).first,
    );
    expect(((material.shape! as RoundedRectangleBorder).side).width, 2);
    expect(
      find.ancestor(of: find.text('Static'), matching: find.byType(ChunkyPressable)),
      findsNothing,
    );
    expect(
      find.ancestor(of: find.text('Tappable'), matching: find.byType(ChunkyPressable)),
      findsOneWidget,
    );
    final shadow = tester
        .widgetList<DecoratedBox>(
          find.ancestor(of: find.text('Static'), matching: find.byType(DecoratedBox)),
        )
        .map((b) => b.decoration)
        .whereType<BoxDecoration>()
        .expand((d) => d.boxShadow ?? const <BoxShadow>[])
        .single;
    expect(shadow.blurRadius, 0);
    expect(shadow.offset.dy, 4);
  });
}
