import 'package:intl/intl.dart';

/// Currencies a user can pick at onboarding (one per user, ISO 4217).
abstract final class Currencies {
  static const fallback = 'USD';

  /// Alphabetical. Every code must be known to `intl` (symbol, decimal digits).
  static const supported = [
    'AED', 'AUD', 'BDT', 'BRL', 'CAD', 'CHF', 'CNY', 'DKK', 'EUR', 'GBP', //
    'HKD', 'IDR', 'INR', 'JPY', 'KES', 'KRW', 'LKR', 'MXN', 'MYR', 'NGN', //
    'NOK', 'NPR', 'NZD', 'PHP', 'PKR', 'SAR', 'SEK', 'SGD', 'THB', 'TRY', //
    'USD', 'ZAR',
  ];

  static bool isSupported(String code) => supported.contains(code);

  /// The usual currency of [localeTag] (e.g. `de_DE` → `EUR`), or [fallback] when it is unknown
  /// or not supported. Pass the **device** locale, not the app's UI locale.
  static String forLocale(String localeTag) {
    try {
      final code = NumberFormat.simpleCurrency(locale: localeTag).currencyName;
      if (code != null && isSupported(code)) return code;
    } on Object catch (_) {
      // Unknown locale: use the fallback.
    }
    return fallback;
  }

  /// Display symbol, e.g. `$`, `€`, `Rs`.
  static String symbolOf(String code) =>
      NumberFormat.simpleCurrency(locale: 'en', name: code).currencySymbol;
}
