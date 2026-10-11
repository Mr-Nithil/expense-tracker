import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/features/profile/data/profile_repository_provider.dart';
import 'package:expense_tracker/features/profile/domain/entities/profile.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_mode_setter.g.dart';

/// Saves the theme preference on the profile (synced to the user's other devices). The profile
/// feature's entry point for Settings (ARCHITECTURE §3). Kept alive because it is used from
/// callbacks.
@Riverpod(keepAlive: true)
class ThemeModeSetter extends _$ThemeModeSetter {
  @override
  void build() {}

  Future<Result<Profile>> setThemeMode(ThemeMode mode) =>
      ref.read(profileRepositoryProvider).setThemeMode(switch (mode) {
        ThemeMode.system => AppThemeMode.system,
        ThemeMode.light => AppThemeMode.light,
        ThemeMode.dark => AppThemeMode.dark,
      });
}
