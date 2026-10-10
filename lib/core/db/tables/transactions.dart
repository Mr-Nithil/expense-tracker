// Drift CHECK constraints reference their own column getter; drift_dev parses, never runs, it.
// ignore_for_file: recursive_getters

import 'package:drift/drift.dart';
import 'package:expense_tracker/core/db/converters/date_only_converter.dart';
import 'package:expense_tracker/core/db/tables/categories.dart';
import 'package:expense_tracker/core/db/tables/sync_columns.dart';

@DataClassName('TransactionRow')
@TableIndex(name: 'transactions_user_occurred_idx', columns: {#userId, #occurredOn})
@TableIndex(name: 'transactions_category_idx', columns: {#categoryId})
@TableIndex(name: 'transactions_sync_status_idx', columns: {#syncStatus})
class Transactions extends Table with SyncColumns {
  TextColumn get type => text().check(type.isIn(const ['expense', 'income']))();

  /// Always positive. [type] gives the direction.
  IntColumn get amountMinor => integer().check(amountMinor.isBiggerThanValue(0))();

  TextColumn get categoryId => text().references(Categories, #id)();

  TextColumn get occurredOn => text().map(const DateOnlyConverter())();

  TextColumn get note => text().withLength(max: 500).nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
