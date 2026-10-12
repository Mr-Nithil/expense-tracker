import 'package:expense_tracker/core/l10n/generated/app_localizations.dart';
import 'package:expense_tracker/core/utils/date_utils.dart';
import 'package:expense_tracker/core/utils/money.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

/// M9.4: money, numbers and dates format correctly in every language the app ships.
void main() {
  setUpAll(initializeDateFormatting);

  final date = DateTime(2026, 10, 3, 14, 5);

  for (final locale in AppLocalizations.supportedLocales) {
    final tag = locale.toString();

    group('$tag:', () {
      test('intl has number and date data', () {
        expect(NumberFormat.localeExists(tag), isTrue);
        expect(DateFormat.localeExists(tag), isTrue);
      });

      for (final currency in ['USD', 'LKR', 'JPY']) {
        test('$currency amounts format and round-trip through the amount field', () {
          for (final minor in [0, 5, 4550, 123456789, -4550]) {
            final money = Money(minor);
            final symbol = NumberFormat.simpleCurrency(locale: tag, name: currency).currencySymbol;
            expect(money.format(locale: tag, currencyCode: currency), contains(symbol));
            expect(money.formatCompact(locale: tag, currencyCode: currency), contains(symbol));

            final input = money.toInputString(locale: tag, currencyCode: currency);
            expect(Money.tryParse(input, locale: tag, currencyCode: currency), money);
          }
          expect(
            const Money(4550).format(locale: tag, currencyCode: currency, signed: true),
            startsWith('+'),
          );
        });
      }

      test('every date format works', () {
        for (final text in [
          AppDateUtils.formatShortDate(date, tag),
          AppDateUtils.formatWeekdayDate(date, tag),
          AppDateUtils.formatLongDate(date, tag),
          AppDateUtils.formatMonthYear(date, tag),
          AppDateUtils.formatTime(date, tag),
        ]) {
          expect(text.trim(), isNotEmpty);
        }
        expect(AppDateUtils.formatMonthYear(date, tag), contains('2026'));
      });

      test('numbers inside messages use the locale grouping', () {
        final l10n = lookupAppLocalizations(locale);
        final grouped = NumberFormat.decimalPattern(tag).format(1234);

        expect(l10n.syncStatusPending(1234), contains(grouped));
        expect(l10n.syncStatusPending(1), isNot(contains(grouped)));
        expect(l10n.budgetPercentUsed(1234), contains(grouped));
        expect(l10n.reminderMonthly(31, '20:00'), contains('31'));
      });
    });
  }

  test('English messages read naturally with grouped numbers', () {
    final en = lookupAppLocalizations(AppLocalizations.supportedLocales.first);
    expect(en.syncStatusPending(1234), '1,234 changes waiting to sync');
    expect(en.syncStatusPending(1), '1 change waiting to sync');
  });
}
