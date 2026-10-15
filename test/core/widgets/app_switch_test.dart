import 'package:expense_tracker/core/widgets/app_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/accessibility.dart';
import '../../helpers/pump_app.dart';

void main() {
  testWidgetsBothThemes('toggles; one labelled toggle node; 52x48 tap area', (
    tester,
    brightness,
  ) async {
    final values = <bool>[];
    await tester.pumpApp(
      Center(
        child: AppSwitch(value: false, onChanged: values.add, semanticsLabel: 'Budget alerts'),
      ),
      brightness: brightness,
    );

    await tester.tap(find.byType(AppSwitch));
    expect(values, [true]);
    expect(
      tester.getSemantics(find.byType(AppSwitch)),
      isSemantics(
        label: 'Budget alerts',
        isToggled: false,
        hasToggledState: true,
        hasTapAction: true,
      ),
    );
    expect(tester.getSize(find.byType(AppSwitch)), const Size(52, 48));
  });

  testWidgets('the track is primary when on and line when off', (tester) async {
    Future<Color?> trackOf(bool value) async {
      await tester.pumpApp(
        Center(
          child: AppSwitch(value: value, onChanged: (_) {}),
        ),
      );
      await tester.pumpAndSettle();
      final container = tester.widget<AnimatedContainer>(find.byType(AnimatedContainer));
      return (container.decoration! as BoxDecoration).color;
    }

    final on = await trackOf(true);
    final scheme = Theme.of(tester.element(find.byType(AppSwitch))).colorScheme;
    expect(on, scheme.primary);
    expect(await trackOf(false), isNot(scheme.primary));
  });

  testWidgets('disabled: no change and announced as disabled', (tester) async {
    await tester.pumpApp(const Center(child: AppSwitch(value: true, onChanged: null)));

    await tester.tap(find.byType(AppSwitch));
    expect(
      tester.getSemantics(find.byType(AppSwitch)),
      isSemantics(hasEnabledState: true, isEnabled: false, isToggled: true),
    );
  });

  testWidgets('reduce motion: the knob jumps instead of springing', (tester) async {
    await tester.pumpApp(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: Center(child: AppSwitch(value: true, onChanged: (_) {})),
      ),
    );
    expect(tester.widget<AnimatedAlign>(find.byType(AnimatedAlign)).duration, Duration.zero);
  });

  testWidgets('the tile toggles from anywhere on the row and reads as one toggle', (tester) async {
    final values = <bool>[];
    await tester.pumpApp(
      AppSwitchTile(
        title: const Text('App lock'),
        subtitle: const Text('Ask for a PIN'),
        secondary: const Icon(Icons.lock_outline),
        value: false,
        onChanged: values.add,
      ),
    );

    await tester.tap(find.text('Ask for a PIN'));
    expect(values, [true]);
    expect(find.bySemanticsLabel(RegExp('App lock')), findsOneWidget);
  });

  group('accessibility (M9.5)', () {
    testWidgetsBothThemes('meets the guidelines', (tester, brightness) async {
      await tester.pumpApp(
        Column(
          children: [
            AppSwitch(value: true, onChanged: (_) {}, semanticsLabel: 'Alerts'),
            AppSwitchTile(title: const Text('App lock'), value: false, onChanged: (_) {}),
          ],
        ),
        brightness: brightness,
      );
      await expectAccessible(tester);
    });
  });
}
