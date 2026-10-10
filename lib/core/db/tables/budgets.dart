// Drift CHECK constraints reference their own column getter; drift_dev parses, never runs, it.
// ignore_for_file: recursive_getters

import 'package:drift/drift.dart';
import 'package:expense_tracker/core/db/converters/date_only_converter.dart';
import 'package:expense_tracker/core/db/tables/categories.dart';
import 'package:expense_tracker/core/db/tables/sync_columns.dart';

/// Monthly limits. A null [categoryId] is the overall budget for the month.
///
/// One budget per (user, month, category) is enforced by a deterministic id
/// (`IdGenerator.deterministic`), not a unique index, so offline creation on two devices
/// converges on the same row instead of breaking sync.
@DataClassName('BudgetRow')
@TableIndex(name: 'budgets_user_month_idx', columns: {#userId, #month})
@TableIndex(name: 'budgets_sync_status_idx', columns: {#syncStatus})
class Budgets extends Table with SyncColumns {
  /// First day of the month (`yyyy-MM-01`).
  TextColumn get month => text().map(const DateOnlyConverter())();

  TextColumn get categoryId => text().references(Categories, #id).nullable()();

  IntColumn get limitMinor => integer().check(limitMinor.isBiggerThanValue(0))();

  @override
  Set<Column> get primaryKey => {id};
}
