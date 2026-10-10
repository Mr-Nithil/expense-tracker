import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('showSnack shows the message and replaces the current snackbar', (tester) async {
    late BuildContext context;
    await tester.pumpApp(
      Builder(
        builder: (c) {
          context = c;
          return const SizedBox();
        },
      ),
    );

    context.showSnack('first');
    await tester.pumpAndSettle();
    expect(find.text('first'), findsOneWidget);

    context.showSnack('second');
    await tester.pumpAndSettle();
    expect(find.text('first'), findsNothing);
    expect(find.text('second'), findsOneWidget);
  });

  testWidgets('showSnack can offer one action', (tester) async {
    late BuildContext context;
    var tapped = 0;
    await tester.pumpApp(
      Builder(
        builder: (c) {
          context = c;
          return const SizedBox();
        },
      ),
    );

    context.showSnack('Not confirmed', actionLabel: 'Resend', onAction: () => tapped++);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Resend'));
    await tester.pumpAndSettle();

    expect(tapped, 1);
  });
}
