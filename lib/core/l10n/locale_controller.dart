import 'package:expense_tracker/core/db/database_provider.dart';
import 'package:expense_tracker/core/l10n/generated/app_localizations.dart';
import 'package:expense_tracker/core/session/session.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show ProviderListenableSelect;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'locale_controller.g.dart';

/// The app language: the signed-in user's profile `locale` (synced, so it follows the user to
/// other devices), or `null` to follow the device (signed out, not chosen, or not supported).
///
/// Read-only: the language is changed through the profile repository (the single write path).
@Riverpod(keepAlive: true)
class LocaleController extends _$LocaleController {
  @override
  Stream<Locale?> build() {
    final userId = ref.watch(sessionProvider.select((user) => user?.userId));
    if (userId == null) return Stream.value(null);
    return ref
        .watch(databaseProvider)
        .profilesDao
        .watchProfile(userId)
        .map((row) => parse(row?.locale))
        .distinct();
  }

  /// The supported locale with language [value], or `null` (device language).
  static Locale? parse(String? value) =>
      AppLocalizations.supportedLocales.where((locale) => locale.languageCode == value).firstOrNull;
}
