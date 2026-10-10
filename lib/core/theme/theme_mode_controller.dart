import 'package:expense_tracker/core/db/database_provider.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_mode_controller.g.dart';

/// The user's theme mode, persisted locally in `app_settings`.
///
/// Synced to the profile later (TASKS M3.10). Until the stored value loads, the app follows the
/// system setting.
@Riverpod(keepAlive: true)
class ThemeModeController extends _$ThemeModeController {
  static const settingsKey = 'theme_mode';

  @override
  Stream<ThemeMode> build() =>
      ref.watch(databaseProvider).appSettingsDao.watchValue(settingsKey).map(parse);

  Future<void> setThemeMode(ThemeMode mode) =>
      ref.read(databaseProvider).appSettingsDao.setValue(settingsKey, mode.name);

  /// Unknown or missing values fall back to [ThemeMode.system].
  static ThemeMode parse(String? value) => ThemeMode.values.asNameMap()[value] ?? ThemeMode.system;
}
