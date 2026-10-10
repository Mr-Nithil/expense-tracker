// Drift CHECK constraints reference their own column getter; drift_dev parses, never runs, it.
// ignore_for_file: recursive_getters

import 'package:drift/drift.dart';
import 'package:expense_tracker/core/db/converters/date_only_converter.dart';
import 'package:expense_tracker/core/db/tables/sync_columns.dart';

@DataClassName('GoalRow')
@TableIndex(name: 'goals_sync_status_idx', columns: {#syncStatus})
class Goals extends Table with SyncColumns {
  TextColumn get name => text().withLength(min: 1, max: 100)();

  IntColumn get targetMinor => integer().check(targetMinor.isBiggerThanValue(0))();

  TextColumn get deadlineOn => text().map(const DateOnlyConverter()).nullable()();

  TextColumn get icon => text()();

  /// ARGB color value.
  IntColumn get color => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
