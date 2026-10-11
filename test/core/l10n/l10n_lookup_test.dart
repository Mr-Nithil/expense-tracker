import 'package:expense_tracker/core/l10n/l10n_lookup.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('uses a supported preferred or device language', () {
    expect(appLocalizationsFor(const Locale('en', 'GB')).localeName, 'en');
    expect(appLocalizationsFor(null, device: const Locale('en', 'LK')).localeName, 'en');
  });

  test('falls back to the first supported locale', () {
    expect(appLocalizationsFor(const Locale('xx')).localeName, 'en');
    expect(appLocalizationsFor(null).localeName, 'en');
  });

  test('provides the default category names', () {
    expect(appLocalizationsFor(null).categoryDefaultFood, 'Food');
  });
}
