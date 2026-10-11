import 'package:expense_tracker/core/l10n/generated/app_localizations_en.dart';
import 'package:expense_tracker/core/widgets/swipe_to_delete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  final l10n = AppLocalizationsEn();

  Future<List<String>> pumpItem(WidgetTester tester, {Brightness? brightness}) async {
    final deleted = <String>[];
    var visible = true;
    await tester.pumpApp(
      StatefulBuilder(
        builder: (context, setState) => visible
            ? SwipeToDelete(
                itemKey: const ValueKey('row'),
                onDelete: () {
                  deleted.add('row');
                  // Callers remove the item at once.
                  setState(() => visible = false);
                },
                child: const ListTile(title: Text('Row')),
              )
            : const SizedBox(),
      ),
      brightness: brightness ?? Brightness.light,
    );
    return deleted;
  }

  testWidgetsBothThemes('swiping left deletes, showing the delete background', (
    tester,
    brightness,
  ) async {
    final deleted = await pumpItem(tester, brightness: brightness);

    final gesture = await tester.startGesture(tester.getCenter(find.text('Row')));
    await gesture.moveBy(const Offset(-120, 0));
    await tester.pump();
    expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    await gesture.up();
    await tester.pumpAndSettle();

    await tester.fling(find.text('Row'), const Offset(-600, 0), 1000);
    await tester.pumpAndSettle();

    expect(deleted, ['row']);
    expect(find.text('Row'), findsNothing);
  });

  testWidgets('swiping right does nothing', (tester) async {
    final deleted = await pumpItem(tester);

    await tester.fling(find.text('Row'), const Offset(600, 0), 1000);
    await tester.pumpAndSettle();

    expect(deleted, isEmpty);
    expect(find.text('Row'), findsOneWidget);
  });

  testWidgets('screen readers get a Delete action', (tester) async {
    final deleted = await pumpItem(tester);

    final semantics = tester.widget<Semantics>(
      find.byWidgetPredicate(
        (widget) => widget is Semantics && widget.properties.customSemanticsActions != null,
      ),
    );
    final actions = semantics.properties.customSemanticsActions!;
    expect(actions.keys.single.label, l10n.commonDelete);

    actions.values.single();
    await tester.pumpAndSettle();

    expect(deleted, ['row']);
  });
}
