// Drift CHECK constraints reference their own column getter; drift_dev parses, never runs, it.
// ignore_for_file: recursive_getters

import 'package:drift/drift.dart';
import 'package:expense_tracker/core/db/converters/date_only_converter.dart';
import 'package:expense_tracker/core/db/tables/goals.dart';
import 'package:expense_tracker/core/db/tables/sync_columns.dart';

@DataClassName('GoalContributionRow')
@TableIndex(name: 'goal_contributions_goal_idx', columns: {#goalId})
@TableIndex(name: 'goal_contributions_sync_status_idx', columns: {#syncStatus})
class GoalContributions extends Table with SyncColumns {
  TextColumn get goalId => text().references(Goals, #id)();

  IntColumn get amountMinor => integer().check(amountMinor.isBiggerThanValue(0))();

  TextColumn get contributedOn => text().map(const DateOnlyConverter())();

  TextColumn get note => text().withLength(max: 500).nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
