// Drift CHECK constraints reference their own column getter; drift_dev parses, never runs, it.
// ignore_for_file: recursive_getters

import 'package:drift/drift.dart';
import 'package:expense_tracker/core/db/tables/sync_columns.dart';

/// One row per user. `id` equals `user_id` (the Supabase auth user id).
@DataClassName('ProfileRow')
@TableIndex(name: 'profiles_sync_status_idx', columns: {#syncStatus})
class Profiles extends Table with SyncColumns {
  TextColumn get displayName => text().withLength(max: 100).nullable()();

  /// ISO 4217 code. Null until onboarding is complete. Read-only afterwards.
  TextColumn get currencyCode => text().withLength(min: 3, max: 3).nullable()();

  /// BCP 47 tag, or null to follow the device.
  TextColumn get locale => text().nullable()();

  TextColumn get themeMode => text()
      .check(themeMode.isIn(const ['system', 'light', 'dark']))
      .withDefault(const Constant('system'))();

  @override
  Set<Column> get primaryKey => {id};
}
