import 'package:expense_tracker/core/db/database_provider.dart';
import 'package:expense_tracker/core/session/session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show ProviderListenableSelect;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_mode_controller.g.dart';

/// The app theme: the signed-in user's profile `theme_mode` (synced, so it follows the user to
/// other devices), or the system setting when signed out or before the profile exists.
///
/// Read-only: the theme is changed through the profile repository (the single write path).
@Riverpod(keepAlive: true)
class ThemeModeController extends _$ThemeModeController {
  @override
  Stream<ThemeMode> build() {
    final userId = ref.watch(sessionProvider.select((user) => user?.userId));
    if (userId == null) return Stream.value(ThemeMode.system);
    return ref
        .watch(databaseProvider)
        .profilesDao
        .watchProfile(userId)
        .map((row) => parse(row?.themeMode));
  }

  /// Unknown or missing values fall back to [ThemeMode.system].
  static ThemeMode parse(String? value) => ThemeMode.values.asNameMap()[value] ?? ThemeMode.system;
}
