import 'package:drift/drift.dart';

/// Local only. The pull cursor for each synced table.
@DataClassName('SyncStateRow')
class SyncState extends Table {
  /// Remote table name, e.g. `transactions`.
  TextColumn get syncTable => text().named('table_name')();

  /// Highest `server_updated_at` pulled so far. Null before the first pull.
  DateTimeColumn get lastPulledAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {syncTable};
}
