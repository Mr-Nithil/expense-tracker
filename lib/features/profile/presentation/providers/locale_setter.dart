import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/features/profile/data/profile_repository_provider.dart';
import 'package:expense_tracker/features/profile/domain/entities/profile.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'locale_setter.g.dart';

/// Saves the app language on the profile (synced to the user's other devices); `null` follows
/// the device. The profile feature's entry point for Settings (ARCHITECTURE §3). Kept alive
/// because it is used from callbacks.
@Riverpod(keepAlive: true)
class LocaleSetter extends _$LocaleSetter {
  @override
  void build() {}

  Future<Result<Profile>> setLocale(Locale? locale) =>
      ref.read(profileRepositoryProvider).setLocale(locale?.languageCode);
}
