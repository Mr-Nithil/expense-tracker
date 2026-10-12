import 'dart:convert';
import 'dart:io';

import 'package:expense_tracker/core/l10n/generated/app_localizations.dart';
import 'package:expense_tracker/core/l10n/l10n_lookup.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards translations (M9.2): every ARB besides the English template is complete and keeps the
/// template's placeholders and plural structure, so no screen shows a missing key or loses a value.
void main() {
  const dir = 'lib/core/l10n';
  Map<String, dynamic> read(String path) =>
      json.decode(File(path).readAsStringSync()) as Map<String, dynamic>;
  Map<String, String> messages(Map<String, dynamic> arb) => {
    for (final MapEntry(:key, :value) in arb.entries)
      if (!key.startsWith('@')) key: value as String,
  };

  final template = messages(read('$dir/app_en.arb'));
  final translations = {
    for (final file in Directory(dir).listSync().whereType<File>())
      if (RegExp(r'app_(\w+)\.arb$').firstMatch(file.path)?.group(1) case final String locale
          when locale != 'en')
        locale: read(file.path),
  };

  /// The placeholder names a message uses, e.g. `{amount}` or the `count` of `{count, plural, …}`.
  Set<String> placeholders(String message) => {
    for (final match in RegExp(r'\{(\w+)\s*[,}]').allMatches(message)) match.group(1)!,
  };

  /// The `{name, plural|select,` selectors of a message.
  List<String> selectors(String message) => [
    for (final match in RegExp(r'\{\s*(\w+)\s*,\s*(plural|select)\s*,').allMatches(message))
      '${match.group(1)} ${match.group(2)}',
  ];

  test('there is at least one translation', () {
    expect(translations.keys, contains('si'));
  });

  for (final MapEntry(key: locale, value: arb) in translations.entries) {
    group('app_$locale.arb', () {
      final translated = messages(arb);

      test('declares its locale', () {
        expect(arb['@@locale'], locale);
      });

      test('has exactly the template keys', () {
        expect(translated.keys.toSet().difference(template.keys.toSet()), isEmpty, reason: 'extra');
        expect(
          template.keys.toSet().difference(translated.keys.toSet()),
          isEmpty,
          reason: 'missing',
        );
      });

      test('has no empty message', () {
        expect([
          for (final MapEntry(:key, :value) in translated.entries)
            if (value.trim().isEmpty) key,
        ], isEmpty);
      });

      test('keeps the placeholders and plural structure of every message', () {
        final broken = [
          for (final MapEntry(:key, value: english) in template.entries)
            if (translated[key] case final message?)
              if (!setEquals(placeholders(message), placeholders(english)) ||
                  !listEquals(selectors(message), selectors(english)) ||
                  (selectors(english).isNotEmpty && !message.contains('other{')))
                key,
        ];

        expect(broken, isEmpty);
      });
    });
  }

  test('Sinhala is supported and looked up', () {
    expect(AppLocalizations.supportedLocales, contains(const Locale('si')));
    expect(lookupAppLocalizations(const Locale('si')).localeName, 'si');
    expect(appLocalizationsFor(null, device: const Locale('si', 'LK')).localeName, 'si');
    expect(appLocalizationsFor(const Locale('si')).categoryDefaultFood, 'ආහාර');
  });
}
