import 'package:expense_tracker/core/utils/currencies.dart';
import 'package:expense_tracker/core/utils/money.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('supported codes are unique, sorted ISO 4217 codes known to intl', () {
    const codes = Currencies.supported;
    expect(codes.toSet(), hasLength(codes.length));
    expect([...codes]..sort(), codes);
    for (final code in codes) {
      expect(code, matches(RegExp(r'^[A-Z]{3}$')));
      expect(Currencies.symbolOf(code), isNotEmpty, reason: code);
      expect(Money.decimalDigitsFor(code), inInclusiveRange(0, 3), reason: code);
    }
    expect(Currencies.isSupported(Currencies.fallback), isTrue);
  });

  test('forLocale picks the local currency when supported', () {
    expect(Currencies.forLocale('en_US'), 'USD');
    expect(Currencies.forLocale('de_DE'), 'EUR');
    expect(Currencies.forLocale('ja_JP'), 'JPY');
    expect(Currencies.forLocale('en_IN'), 'INR');
  });

  test('forLocale falls back for unknown locales', () {
    expect(Currencies.forLocale('zz_ZZ'), Currencies.fallback);
  });

  test('isSupported rejects unknown or malformed codes', () {
    for (final code in ['XXX', 'usd', 'US', '']) {
      expect(Currencies.isSupported(code), isFalse, reason: code);
    }
  });
}
