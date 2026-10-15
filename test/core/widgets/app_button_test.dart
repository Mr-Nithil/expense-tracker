import 'package:expense_tracker/core/widgets/app_button.dart';
import 'package:expense_tracker/core/widgets/chunky_pressable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgetsBothThemes('each variant renders and fires onPressed', (tester, brightness) async {
    var taps = 0;
    void onTap() => taps++;
    await tester.pumpApp(
      Column(
        children: [
          AppButton.primary(label: 'Primary', onPressed: onTap),
          AppButton.secondary(label: 'Secondary', onPressed: onTap, icon: Icons.add),
          AppButton.text(label: 'Text', onPressed: onTap),
          AppButton.danger(label: 'Danger', onPressed: onTap),
        ],
      ),
      brightness: brightness,
    );

    for (final label in ['Primary', 'Secondary', 'Text', 'Danger']) {
      await tester.tap(findText(label));
    }
    expect(taps, 4);
  });

  testWidgets('danger uses the error color', (tester) async {
    await tester.pumpApp(AppButton.danger(label: 'Delete', onPressed: () {}));
    final context = tester.element(findText('Delete'));
    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(
      button.style?.backgroundColor?.resolve({}),
      Theme.of(context).colorScheme.error,
    );
  });

  testWidgets('loading shows a spinner and ignores taps', (tester) async {
    var taps = 0;
    await tester.pumpApp(
      AppButton.primary(label: 'Save', onPressed: () => taps++, isLoading: true),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(findText('Save'));
    expect(taps, 0);
  });

  testWidgets('expanded fills the width', (tester) async {
    await tester.pumpApp(AppButton.primary(label: 'Wide', onPressed: () {}, isExpanded: true));
    final screenWidth = tester.view.physicalSize.width / tester.view.devicePixelRatio;
    expect(tester.getSize(find.byType(FilledButton)).width, screenWidth);
  });

  testWidgets('chunky variants show capitals but are announced normally', (tester) async {
    await tester.pumpApp(
      Column(
        children: [
          AppButton.primary(label: 'Save', onPressed: () {}),
          AppButton.secondary(label: 'Cancel', onPressed: () {}),
          AppButton.danger(label: 'Delete', onPressed: () {}),
          AppButton.text(label: 'Forgot PIN?', onPressed: () {}),
        ],
      ),
    );

    for (final label in ['Save', 'Cancel', 'Delete']) {
      expect(find.text(label.toUpperCase()), findsOneWidget);
      expect(find.bySemanticsLabel(label), findsOneWidget);
    }
    expect(find.text('Forgot PIN?'), findsOneWidget, reason: 'text links keep their case');
  });

  testWidgets('chunky variants have a solid shadow; text and disabled ones have none', (
    tester,
  ) async {
    await tester.pumpApp(
      Column(
        children: [
          AppButton.primary(label: 'On', onPressed: () {}),
          const AppButton.primary(label: 'Off', onPressed: null),
          AppButton.text(label: 'Link', onPressed: () {}),
        ],
      ),
    );

    final pressables = tester.widgetList<ChunkyPressable>(find.byType(ChunkyPressable)).toList();
    expect(pressables, hasLength(2), reason: 'the text button is flat');
    expect(pressables.map((p) => p.enabled), [true, false]);
  });
}
