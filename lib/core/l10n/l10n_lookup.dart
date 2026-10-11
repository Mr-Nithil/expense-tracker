import 'package:expense_tracker/core/l10n/generated/app_localizations.dart';
import 'package:flutter/widgets.dart';

/// Localizations without a `BuildContext` (e.g. text stored as data at seed time).
///
/// Uses the language of [preferred] (the app setting), then [device], when supported; otherwise
/// the first supported locale. Never throws, unlike `lookupAppLocalizations`.
AppLocalizations appLocalizationsFor(Locale? preferred, {Locale? device}) {
  const supported = AppLocalizations.supportedLocales;
  for (final candidate in [preferred, device]) {
    if (candidate == null) continue;
    final match = supported.where((l) => l.languageCode == candidate.languageCode);
    if (match.isNotEmpty) return lookupAppLocalizations(match.first);
  }
  return lookupAppLocalizations(supported.first);
}
