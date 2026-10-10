// Drift CHECK constraints reference their own column getter; drift_dev parses, never runs, it.
// ignore_for_file: recursive_getters

import 'package:drift/drift.dart';
import 'package:expense_tracker/core/db/tables/sync_columns.dart';

@DataClassName('ReminderRow')
@TableIndex(name: 'reminders_sync_status_idx', columns: {#syncStatus})
class Reminders extends Table with SyncColumns {
  TextColumn get title => text().withLength(min: 1, max: 100)();

  /// Local wall-clock time as `HH:mm`. Shape-checked here; the repository validates the range.
  TextColumn get timeOfDay => text().check(timeOfDay.like('__:__'))();

  TextColumn get repeatRule =>
      text().check(repeatRule.isIn(const ['daily', 'weekly', 'monthly']))();

  /// Bitmask of weekdays for `weekly` (bit 0 = Monday ... bit 6 = Sunday). Null otherwise.
  IntColumn get weekdays => integer().nullable()();

  BoolColumn get enabled => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}
