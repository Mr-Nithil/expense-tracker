import 'package:expense_tracker/core/utils/money.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('arithmetic and comparison', () {
    test('adds, subtracts, negates and multiplies', () {
      expect(const Money(150) + const Money(250), const Money(400));
      expect(const Money(150) - const Money(250), const Money(-100));
      expect(-const Money(150), const Money(-150));
      expect(const Money(150) * 3, const Money(450));
      expect(const Money(-5).abs(), const Money(5));
    });

    test('compares by minor units', () {
      expect(const Money(1) < const Money(2), isTrue);
      expect(const Money(2) <= const Money(2), isTrue);
      expect(const Money(3) > const Money(2), isTrue);
      expect(const Money(2) >= const Money(3), isFalse);
      expect([const Money(3), const Money(1)]..sort(), [const Money(1), const Money(3)]);
    });

    test('sign helpers', () {
      expect(Money.zero.isZero, isTrue);
      expect(const Money(1).isPositive, isTrue);
      expect(const Money(-1).isNegative, isTrue);
    });

    test('equality and hashCode', () {
      expect(const Money(7), const Money(7));
      expect(const Money(7).hashCode, const Money(7).hashCode);
      expect(const Money(7), isNot(const Money(8)));
    });
  });

  test('fromMajor uses the currency decimal digits', () {
    expect(Money.fromMajor(1234, currencyCode: 'USD'), const Money(123400));
    expect(Money.fromMajor(1234, currencyCode: 'JPY'), const Money(1234));
    expect(Money.fromMajor(1, currencyCode: 'KWD'), const Money(1000));
  });

  group('decimalDigitsFor', () {
    test('uses the currency minor unit', () {
      expect(Money.decimalDigitsFor('USD'), 2);
      expect(Money.decimalDigitsFor('JPY'), 0);
      expect(Money.decimalDigitsFor('KWD'), 3);
    });
  });

  group('format', () {
    test('formats USD in en_US', () {
      expect(const Money(123450).format(locale: 'en_US', currencyCode: 'USD'), r'$1,234.50');
      expect(const Money(5).format(locale: 'en_US', currencyCode: 'USD'), r'$0.05');
    });

    test('formats negatives and an explicit sign', () {
      expect(const Money(-150).format(locale: 'en_US', currencyCode: 'USD'), r'-$1.50');
      expect(
        const Money(150).format(locale: 'en_US', currencyCode: 'USD', signed: true),
        r'+$1.50',
      );
      expect(Money.zero.format(locale: 'en_US', currencyCode: 'USD', signed: true), r'$0.00');
    });

    test('respects zero-decimal currencies', () {
      expect(const Money(1234).format(locale: 'en_US', currencyCode: 'JPY'), '¥1,234');
    });

    test('uses locale separators', () {
      final text = const Money(123456).format(locale: 'de_DE', currencyCode: 'EUR');
      expect(text, contains('1.234,56'));
      expect(text, contains('€'));
    });
  });

  group('toInputString', () {
    test('uses the currency decimals and no grouping', () {
      expect(const Money(123450).toInputString(locale: 'en_US', currencyCode: 'USD'), '1234.50');
      expect(const Money(1234).toInputString(locale: 'en_US', currencyCode: 'JPY'), '1234');
      expect(const Money(1005).toInputString(locale: 'en_US', currencyCode: 'KWD'), '1.005');
      expect(const Money(5).toInputString(locale: 'en_US', currencyCode: 'USD'), '0.05');
    });

    test('uses the locale decimal separator and round-trips', () {
      const amount = Money(123450);
      final text = amount.toInputString(locale: 'de_DE', currencyCode: 'EUR');
      expect(text, '1234,50');
      expect(Money.tryParse(text, locale: 'de_DE', currencyCode: 'EUR'), amount);
    });
  });

  group('tryParse', () {
    Money? parse(String input, {String locale = 'en_US', String currency = 'USD'}) =>
        Money.tryParse(input, locale: locale, currencyCode: currency);

    test('parses whole and fractional amounts without floating point', () {
      expect(parse('12'), const Money(1200));
      expect(parse('1,234.5'), const Money(123450));
      expect(parse('0.99'), const Money(99));
      expect(parse('.5'), const Money(50));
      expect(parse('7.'), const Money(700));
      expect(parse(' 1 000.10 '), const Money(100010));
      expect(parse('-3.10'), const Money(-310));
      // A float would give 0.1 + 0.2 = 0.30000000000000004.
      expect(parse('0.1')! + parse('0.2')!, parse('0.3'));
    });

    test('rejects invalid input', () {
      for (final input in ['', ' ', '-', '.', 'abc', '1.2.3', '1.234', '12a', r'$5', '1e3']) {
        expect(parse(input), isNull, reason: input);
      }
    });

    test('rejects absurdly large amounts', () {
      expect(parse('99999999999999'), isNull);
      expect(parse('9999999999999'), isNotNull);
    });

    test('follows the currency minor unit', () {
      expect(parse('1234', currency: 'JPY'), const Money(1234));
      expect(parse('12.5', currency: 'JPY'), isNull);
      expect(parse('1.234', currency: 'KWD'), const Money(1234));
    });

    test('follows locale separators', () {
      expect(parse('1.234,56', locale: 'de_DE', currency: 'EUR'), const Money(123456));
      expect(parse('0,5', locale: 'de_DE', currency: 'EUR'), const Money(50));
    });
  });

  group('formatCompact', () {
    String compact(int minor, {String currency = 'USD', bool signed = false}) =>
        Money(minor).formatCompact(locale: 'en_US', currencyCode: currency, signed: signed);

    test('shortens large amounts', () {
      expect(compact(4500), r'$45');
      expect(compact(123456), r'$1.23K');
      expect(compact(340000000), r'$3.4M');
    });

    test('keeps the sign; signed adds + to positive amounts', () {
      expect(compact(-123456), r'-$1.23K');
      expect(compact(4500, signed: true), r'+$45');
      expect(compact(-4500, signed: true), r'-$45');
      expect(compact(0, signed: true), r'$0');
    });

    test('under a thousand, rounds to whole units', () {
      expect(compact(4550), r'$46');
      expect(compact(99949), r'$999');
    });

    test('respects currencies without decimals', () {
      expect(compact(1500000, currency: 'JPY'), '¥1.5M');
    });
  });
}
