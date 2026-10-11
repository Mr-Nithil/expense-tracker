import 'package:intl/intl.dart';
import 'package:meta/meta.dart';

/// An amount of money in integer **minor units** (e.g. cents). Never use `double` for money.
///
/// The currency is not part of the value because each user has exactly one currency. Pass the
/// currency code when parsing or formatting.
@immutable
class Money implements Comparable<Money> {
  const Money(this.minor);

  static const zero = Money(0);

  /// Largest number of integer digits accepted by [tryParse] (keeps the value well inside `int`).
  static const _maxIntegerDigits = 13;

  final int minor;

  bool get isZero => minor == 0;
  bool get isPositive => minor > 0;
  bool get isNegative => minor < 0;

  Money abs() => Money(minor.abs());

  Money operator +(Money other) => Money(minor + other.minor);
  Money operator -(Money other) => Money(minor - other.minor);
  Money operator -() => Money(-minor);
  Money operator *(int factor) => Money(minor * factor);

  bool operator <(Money other) => minor < other.minor;
  bool operator <=(Money other) => minor <= other.minor;
  bool operator >(Money other) => minor > other.minor;
  bool operator >=(Money other) => minor >= other.minor;

  @override
  int compareTo(Money other) => minor.compareTo(other.minor);

  @override
  bool operator ==(Object other) => other is Money && other.minor == minor;

  @override
  int get hashCode => minor.hashCode;

  @override
  String toString() => 'Money($minor)';

  /// [major] whole units of [currencyCode], e.g. `fromMajor(12, currencyCode: 'USD')` is 1200.
  static Money fromMajor(int major, {required String currencyCode}) =>
      Money(major * _pow10(decimalDigitsFor(currencyCode)));

  /// Number of minor-unit digits for [currencyCode] (2 for USD, 0 for JPY, 3 for KWD).
  static int decimalDigitsFor(String currencyCode) =>
      NumberFormat.simpleCurrency(locale: 'en', name: currencyCode).decimalDigits ?? 2;

  /// Formats this amount for display, e.g. `$1,234.50` for `en_US`/`USD`.
  ///
  /// With [signed], positive amounts get a leading `+`.
  String format({required String locale, required String currencyCode, bool signed = false}) {
    final formatter = NumberFormat.simpleCurrency(locale: locale, name: currencyCode);
    final digits = formatter.decimalDigits ?? 2;
    // Display-only conversion. Exact to the minor unit for any realistic amount (< 2^53).
    final text = formatter.format(minor / _pow10(digits));
    return signed && minor > 0 ? '+$text' : text;
  }

  /// This amount as editable input: the locale's decimal separator, the currency's number of
  /// decimals, no grouping or symbol (e.g. `1234.50`, JPY `1234`). Round-trips with [tryParse].
  String toInputString({required String locale, required String currencyCode}) {
    final digits = decimalDigitsFor(currencyCode);
    final sign = minor < 0 ? '-' : '';
    final value = minor.abs();
    final factor = _pow10(digits);
    final whole = value ~/ factor;
    if (digits == 0) return '$sign$whole';
    final fraction = (value % factor).toString().padLeft(digits, '0');
    final separator = NumberFormat.decimalPattern(locale).symbols.DECIMAL_SEP;
    return '$sign$whole$separator$fraction';
  }

  /// Parses user input such as `1,234.5` into minor units without using floating point.
  ///
  /// Group and decimal separators follow [locale]. Returns `null` for invalid input or when the
  /// input has more decimals than [currencyCode] allows.
  static Money? tryParse(String input, {required String locale, required String currencyCode}) {
    final symbols = NumberFormat.decimalPattern(locale).symbols;
    var text = input.replaceAll(RegExp(r'\s'), '').replaceAll(symbols.GROUP_SEP, '');
    if (text.isEmpty) return null;

    final isNegative = text.startsWith('-');
    if (isNegative) text = text.substring(1);

    final parts = text.split(symbols.DECIMAL_SEP);
    if (parts.length > 2) return null;

    final integerPart = parts[0];
    final fractionPart = parts.length == 2 ? parts[1] : '';
    final digits = decimalDigitsFor(currencyCode);
    final onlyDigits = RegExp(r'^\d*$');

    if (integerPart.isEmpty && fractionPart.isEmpty) return null;
    if (!onlyDigits.hasMatch(integerPart) || !onlyDigits.hasMatch(fractionPart)) return null;
    if (integerPart.length > _maxIntegerDigits || fractionPart.length > digits) return null;

    final whole = integerPart.isEmpty ? 0 : int.parse(integerPart);
    final fraction = int.parse(fractionPart.padRight(digits, '0').padLeft(1, '0'));
    final minor = whole * _pow10(digits) + fraction;
    return Money(isNegative ? -minor : minor);
  }

  static int _pow10(int exponent) {
    var result = 1;
    for (var i = 0; i < exponent; i++) {
      result *= 10;
    }
    return result;
  }
}
