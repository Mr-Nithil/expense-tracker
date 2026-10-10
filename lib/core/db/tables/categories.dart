// Drift CHECK constraints reference their own column getter; drift_dev parses, never runs, it.
// ignore_for_file: recursive_getters

import 'package:drift/drift.dart';
import 'package:expense_tracker/core/db/tables/sync_columns.dart';

@DataClassName('CategoryRow')
@TableIndex(name: 'categories_user_type_idx', columns: {#userId, #type})
@TableIndex(name: 'categories_sync_status_idx', columns: {#syncStatus})
class Categories extends Table with SyncColumns {
  TextColumn get name => text().withLength(min: 1, max: 50)();

  /// Icon key resolved by the UI (not a code point, so icon fonts can change).
  TextColumn get icon => text()();

  /// ARGB color value.
  IntColumn get color => integer()();

  TextColumn get type => text().check(type.isIn(const ['expense', 'income']))();

  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();

  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}
