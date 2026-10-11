import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:expense_tracker/core/db/converters/date_only_converter.dart';
import 'package:expense_tracker/core/db/daos/app_settings_dao.dart';
import 'package:expense_tracker/core/db/daos/budgets_dao.dart';
import 'package:expense_tracker/core/db/daos/categories_dao.dart';
import 'package:expense_tracker/core/db/daos/profiles_dao.dart';
import 'package:expense_tracker/core/db/daos/transactions_dao.dart';
import 'package:expense_tracker/core/db/tables/app_settings.dart';
import 'package:expense_tracker/core/db/tables/budgets.dart';
import 'package:expense_tracker/core/db/tables/categories.dart';
import 'package:expense_tracker/core/db/tables/goal_contributions.dart';
import 'package:expense_tracker/core/db/tables/goals.dart';
import 'package:expense_tracker/core/db/tables/profiles.dart';
import 'package:expense_tracker/core/db/tables/reminders.dart';
import 'package:expense_tracker/core/db/tables/sync_columns.dart';
import 'package:expense_tracker/core/db/tables/sync_state.dart';
import 'package:expense_tracker/core/db/tables/transactions.dart';

part 'app_database.g.dart';

/// The local SQLite database: the single source of truth for the UI.
///
/// Schema changes: bump [schemaVersion], add a step in [migration], run
/// `dart run drift_dev make-migrations`, and extend the migration test (ARCHITECTURE §6.1).
@DriftDatabase(
  tables: [
    Profiles,
    Categories,
    Transactions,
    Budgets,
    Goals,
    GoalContributions,
    Reminders,
    SyncState,
    AppSettings,
  ],
  daos: [AppSettingsDao, BudgetsDao, CategoriesDao, ProfilesDao, TransactionsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  static const databaseName = 'expense_tracker';

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      // Add steps here as the schema evolves, e.g. `if (from < 2) await m.addColumn(...)`.
      // Prefer the generated `stepByStep` helper from `make-migrations` once v2 exists.
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  /// Number of local changes not pushed yet (`sync_status = pending`) across all synced tables,
  /// including pending soft deletes. Used to warn before logout.
  Future<int> countPendingRows() => _pendingCountQuery().map(_readCount).getSingle();

  /// [countPendingRows], re-emitted whenever any synced table changes (sync status indicator).
  Stream<int> watchPendingCount() => _pendingCountQuery().map(_readCount).watchSingle();

  /// One query summing the pending rows of every table with a `sync_status` column.
  Selectable<QueryRow> _pendingCountQuery() {
    final synced = [
      for (final table in allTables)
        if (table.$columns.any((column) => column.name == 'sync_status')) table,
    ];
    final parts = [
      for (final table in synced)
        '(SELECT COUNT(*) FROM "${table.actualTableName}" WHERE sync_status = ?)',
    ];
    return customSelect(
      'SELECT ${parts.join(' + ')} AS c',
      variables: [for (final _ in synced) Variable.withInt(SyncStatus.pending.index)],
      readsFrom: synced.toSet(),
    );
  }

  static int _readCount(QueryRow row) => row.read<int>('c');

  /// Deletes every row in every table (logout). Children first because of foreign keys.
  Future<void> clearAllData() => transaction(() async {
    for (final table in allTables.toList().reversed) {
      await delete(table).go();
    }
  });

  static QueryExecutor _openConnection() => driftDatabase(name: databaseName);
}
