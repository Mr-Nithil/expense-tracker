import 'package:expense_tracker/core/widgets/app_button.dart';
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
      await tester.tap(find.text(label));
    }
    expect(taps, 4);
  });

  testWidgets('danger uses the error color', (tester) async {
    await tester.pumpApp(AppButton.danger(label: 'Delete', onPressed: () {}));
    final context = tester.element(find.text('Delete'));
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
    await tester.tap(find.text('Save'));
    expect(taps, 0);
  });

  testWidgets('expanded fills the width', (tester) async {
    await tester.pumpApp(AppButton.primary(label: 'Wide', onPressed: () {}, isExpanded: true));
    final screenWidth = tester.view.physicalSize.width / tester.view.devicePixelRatio;
    expect(tester.getSize(find.byType(FilledButton)).width, screenWidth);
  });
}
