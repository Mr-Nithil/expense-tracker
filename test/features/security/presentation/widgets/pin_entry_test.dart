import 'package:expense_tracker/core/l10n/generated/app_localizations_en.dart';
import 'package:expense_tracker/features/security/presentation/widgets/pin_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  final l10n = AppLocalizationsEn();

  /// Pumps a [PinEntry] that keeps its own value; returns the submitted PINs.
  Future<List<String>> pump(WidgetTester tester, {int length = 4}) async {
    final submitted = <String>[];
    var value = '';
    await tester.pumpApp(
      StatefulBuilder(
        builder: (context, setState) => SingleChildScrollView(
          child: PinEntry(
            value: value,
            length: length,
            onChanged: (v) => setState(() => value = v),
            onSubmit: submitted.add,
          ),
        ),
      ),
    );
    return submitted;
  }

  Future<void> type(WidgetTester tester, String digits) async {
    for (final d in digits.split('')) {
      await tester.tap(findText(d));
      await tester.pump();
    }
  }

  testWidgetsBothThemes('with a length, submits as soon as it is full', (tester, brightness) async {
    final submitted = await pump(tester, length: 4);

    await type(tester, '123');
    expect(submitted, isEmpty);
    expect(find.bySemanticsLabel(l10n.pinProgress(3, 4)), findsOneWidget);

    await type(tester, '4');
    expect(submitted, ['1234']);
  });

  testWidgets('backspace removes the last digit', (tester) async {
    final submitted = await pump(tester, length: 4);

    await type(tester, '12');
    await tester.tap(find.byTooltip(l10n.pinDeleteDigit));
    await tester.pump();
    await type(tester, '345');

    expect(submitted, ['1345']);
  });

  testWidgets('ignores digits beyond its length', (tester) async {
    final submitted = await pump(tester, length: 6);

    await type(tester, '1234567');

    expect(submitted, ['123456']);
    expect(find.bySemanticsLabel(l10n.pinProgress(6, 6)), findsOneWidget);
  });
}
