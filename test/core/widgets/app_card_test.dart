import 'package:expense_tracker/core/widgets/app_card.dart';
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
    await tester.tap(find.text('Card'));
    expect(taps, 1);
  });
}
