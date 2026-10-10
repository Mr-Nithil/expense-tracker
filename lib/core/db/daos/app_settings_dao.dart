import 'package:drift/drift.dart';
import 'package:expense_tracker/core/db/app_database.dart';
import 'package:expense_tracker/core/db/tables/app_settings.dart';

part 'app_settings_dao.g.dart';

/// Key/value device settings (local only, never synced).
@DriftAccessor(tables: [AppSettings])
class AppSettingsDao extends DatabaseAccessor<AppDatabase> with _$AppSettingsDaoMixin {
  AppSettingsDao(super.attachedDatabase);

  Future<String?> getValue(String key) async {
    final row = await (select(appSettings)..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Stream<String?> watchValue(String key) => (select(
    appSettings,
  )..where((t) => t.key.equals(key))).watchSingleOrNull().map((row) => row?.value);

  Future<void> setValue(String key, String value) =>
      into(appSettings).insertOnConflictUpdate(AppSettingsCompanion.insert(key: key, value: value));

  Future<void> removeValue(String key) =>
      (delete(appSettings)..where((t) => t.key.equals(key))).go();
}
