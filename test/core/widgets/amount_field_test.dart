import 'package:expense_tracker/core/l10n/generated/app_localizations_en.dart';
import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/core/widgets/amount_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  final l10n = AppLocalizationsEn();

  group('AmountInputFormatter', () {
    String apply(String oldText, String newText, {int digits = 2}) => AmountInputFormatter(
      decimalSeparator: '.',
      decimalDigits: digits,
    ).formatEditUpdate(TextEditingValue(text: oldText), TextEditingValue(text: newText)).text;

    test('accepts digits and up to the currency decimals', () {
      expect(apply('12', '12.'), '12.');
      expect(apply('12.3', '12.34'), '12.34');
      expect(apply('', '.5'), '.5');
    });

    test('rejects extra decimals, a second separator and letters', () {
      expect(apply('12.34', '12.345'), '12.34');
      expect(apply('12.3', '12.3.'), '12.3');
      expect(apply('12', '12a'), '12');
      expect(apply('12', '-12'), '12');
    });

    test('a currency without decimals accepts no separator', () {
      expect(apply('12', '12.', digits: 0), '12');
      expect(apply('12', '123', digits: 0), '123');
    });

    test('limits the integer digits', () {
      final max = '9' * AmountInputFormatter.maxIntegerDigits;
      expect(apply(max, '${max}9'), max);
    });
  });

  group('AmountField', () {
    Future<Money?> Function() pumpField(
      WidgetTester tester, {
      String currency = 'USD',
      Money? initial,
      Brightness brightness = Brightness.light,
      GlobalKey<FormState>? formKey,
    }) {
      Money? latest;
      final pumped = tester.pumpApp(
        Form(
          key: formKey,
          child: AmountField(
            label: 'Amount',
            currencyCode: currency,
            initialValue: initial,
            onChanged: (value) => latest = value,
          ),
        ),
        brightness: brightness,
      );
      return () async {
        await pumped;
        return latest;
      };
    }

    testWidgetsBothThemes('shows the currency symbol and reports Money', (
      tester,
      brightness,
    ) async {
      final latest = pumpField(tester, brightness: brightness);
      await latest();

      await tester.enterText(find.byType(TextFormField), '12.5');
      await tester.pump();

      expect(findText(r'$ '), findsOneWidget);
      expect(await latest(), const Money(1250));
    });

    testWidgets('reports null for empty input', (tester) async {
      final latest = pumpField(tester);
      await latest();
      await tester.enterText(find.byType(TextFormField), '3');
      await tester.enterText(find.byType(TextFormField), '');
      expect(await latest(), isNull);
    });

    testWidgets('JPY takes whole amounts only', (tester) async {
      final latest = pumpField(tester, currency: 'JPY');
      await latest();

      await tester.enterText(find.byType(TextFormField), '1200');
      expect(await latest(), const Money(1200));
    });

    testWidgets('shows the initial value', (tester) async {
      final latest = pumpField(tester, initial: const Money(123450));
      await latest();
      expect(findText('1234.50'), findsOneWidget);
    });

    testWidgets('validates required and greater than zero', (tester) async {
      final formKey = GlobalKey<FormState>();
      final latest = pumpField(tester, formKey: formKey);
      await latest();

      formKey.currentState!.validate();
      await tester.pump();
      expect(findText(l10n.errorFieldRequired), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), '0');
      formKey.currentState!.validate();
      await tester.pump();
      expect(findText(l10n.errorAmountInvalid), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), '0.01');
      expect(formKey.currentState!.validate(), isTrue);
    });
  });
}
