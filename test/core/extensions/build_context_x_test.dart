import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/l10n/generated/app_localizations_en.dart';
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
    expect(findText('first'), findsOneWidget);

    context.showSnack('second');
    await tester.pumpAndSettle();
    expect(findText('first'), findsNothing);
    expect(findText('second'), findsOneWidget);
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
    await tester.tap(findText('Resend'));
    await tester.pumpAndSettle();

    expect(tapped, 1);
  });

  testWidgets('showUndoSnack offers Undo', (tester) async {
    late BuildContext context;
    var undone = 0;
    await tester.pumpApp(
      Builder(
        builder: (c) {
          context = c;
          return const SizedBox();
        },
      ),
    );

    context.showUndoSnack('Deleted', onUndo: () => undone++);
    await tester.pumpAndSettle();
    await tester.tap(findText(AppLocalizationsEn().commonUndo));
    await tester.pumpAndSettle();

    expect(undone, 1);
  });

  for (final locale in const [Locale('en', 'US'), Locale('si')]) {
    testWidgets('formatNumber uses the locale grouping ($locale)', (tester) async {
      late BuildContext context;
      await tester.pumpApp(
        Builder(
          builder: (c) {
            context = c;
            return const SizedBox();
          },
        ),
        locale: locale,
      );

      expect(context.formatNumber(1234567), '1,234,567');
      expect(context.formatNumber(7), '7');
    });
  }

  testWidgets('toasts last 3 s with a decorative leading icon', (tester) async {
    late BuildContext context;
    await tester.pumpApp(
      Builder(
        builder: (c) {
          context = c;
          return const SizedBox();
        },
      ),
    );

    context.showSnack('Saved');
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    expect(tester.widget<SnackBar>(find.byType(SnackBar)).duration, const Duration(seconds: 3));
    expect(find.bySemanticsLabel('Saved'), findsOneWidget);

    context.showUndoSnack('Deleted', onUndo: () {});
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.undo_rounded), findsOneWidget);
  });
}
