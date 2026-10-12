import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards localization (M9.1): all user-facing text comes from the ARB files, and the ARB has no
/// dead or undocumented keys. Runs with every test pass so it can't regress silently.
void main() {
  final arb =
      json.decode(File('lib/core/l10n/app_en.arb').readAsStringSync()) as Map<String, dynamic>;
  final keys = arb.keys.where((key) => !key.startsWith('@')).toList();

  final sources = {
    for (final file in Directory('lib').listSync(recursive: true).whereType<File>())
      if (file.path.endsWith('.dart') &&
          !file.path.endsWith('.g.dart') &&
          !file.path.endsWith('.freezed.dart') &&
          !file.path.contains('/generated/'))
        file.path: file.readAsLinesSync(),
  };

  /// `path:line: text` of every source line matching [pattern], minus comments.
  List<String> matches(RegExp pattern, {bool Function(String path)? where}) => [
    for (final MapEntry(key: path, value: lines) in sources.entries)
      if (where == null || where(path))
        for (final (index, line) in lines.indexed)
          if (!line.trimLeft().startsWith('//') && pattern.hasMatch(line))
            '$path:${index + 1}: ${line.trim()}',
  ];

  test('every ARB key is used in lib/', () {
    final code = sources.values.expand((lines) => lines).join('\n');
    final unused = [
      for (final key in keys)
        if (!RegExp('\\b$key\\b').hasMatch(code)) key,
    ];

    expect(unused, isEmpty, reason: 'remove unused keys from app_en.arb');
  });

  test('every key has a description for translators', () {
    final missing = [
      for (final key in keys)
        if ((arb['@$key'] as Map<String, dynamic>?)?['description'] == null) key,
    ];

    expect(missing, isEmpty);
  });

  test('no literal text is passed to user-facing parameters', () {
    final literal = RegExp(
      r'''(\bText\(|\b(tooltip|label|title|message|semanticsLabel|hintText|labelText|helperText|actionLabel|confirmLabel):\s*)['"][^'"]*[A-Za-z]''',
    );

    expect(matches(literal), isEmpty, reason: 'use context.l10n');
  });

  test('numbers in messages are formatted for the locale', () {
    final unformatted = [
      for (final MapEntry(:key, :value) in arb.entries)
        if (key.startsWith('@') && value is Map<String, dynamic>)
          for (final MapEntry(key: name, value: placeholder)
              in ((value['placeholders'] as Map<String, dynamic>?) ?? const {}).entries)
            if ((placeholder as Map<String, dynamic>)['type'] case 'int' || 'num' || 'double')
              if (placeholder['format'] == null) '$key.$name',
    ];

    expect(unformatted, isEmpty, reason: 'add "format": "decimalPattern" (M9.4)');
  });

  test('widgets do not show raw toString() numbers', () {
    // Whole files, so `Text(` and the value may be on different lines.
    final raw = RegExp(r'\bText\(\s*[\w.]+\.toString\(\)');
    final found = [
      for (final MapEntry(key: path, value: lines) in sources.entries)
        for (final match in raw.allMatches(lines.join('\n'))) '$path: ${match.group(0)}',
    ];

    expect(found, isEmpty, reason: 'use context.formatNumber (M9.4)');
  });

  test('presentation code does not join text with hard-coded separators', () {
    final join = RegExp(r'''\.join\(\s*['"][^'"]*[,;·•/-][^'"]*['"]\s*\)''');

    expect(
      matches(join, where: (path) => path.contains('/presentation/') || path.contains('/widgets/')),
      isEmpty,
      reason: 'use a localized separator (e.g. commonListSeparator)',
    );
  });
}
