import 'package:expense_tracker/core/db/app_database.dart';
import 'package:expense_tracker/features/profile/domain/entities/profile.dart';

/// `profiles.theme_mode` values (CHECK constraint). Explicit so renaming the enum can't break
/// the DB.
extension AppThemeModeDb on AppThemeMode {
  String get dbValue => switch (this) {
    AppThemeMode.system => 'system',
    AppThemeMode.light => 'light',
    AppThemeMode.dark => 'dark',
  };

  /// Unknown values (e.g. from a newer app version) fall back to [AppThemeMode.system].
  static AppThemeMode fromDb(String? value) => switch (value) {
    'light' => AppThemeMode.light,
    'dark' => AppThemeMode.dark,
    _ => AppThemeMode.system,
  };
}

extension ProfileRowMapper on ProfileRow {
  Profile toEntity() => Profile(
    id: id,
    displayName: displayName,
    currencyCode: currencyCode,
    themeMode: AppThemeModeDb.fromDb(themeMode),
  );
}
