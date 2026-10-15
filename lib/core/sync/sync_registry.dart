import 'package:expense_tracker/core/db/app_database.dart';
import 'package:expense_tracker/core/sync/syncable_table.dart';

/// Every synced table in **dependency order**: parents before children, so a push never sends a
/// row whose parent the server doesn't have yet (ARCHITECTURE §7).
///
/// Adding a synced table: add it here in the right place. No other sync code changes. Private
/// columns are listed in `encryptedColumns` (ARCHITECTURE §13) and need the same columns in the
/// server's `0004_encryption.sql` list.
List<SyncableTable> syncableTables(AppDatabase db) => [
  SyncableTable(db, db.profiles),
  SyncableTable(db, db.categories, encryptedColumns: const {'name'}),
  SyncableTable(db, db.transactions, encryptedColumns: const {'amount_minor', 'note'}),
  SyncableTable(db, db.budgets, encryptedColumns: const {'limit_minor'}),
  SyncableTable(db, db.goals, encryptedColumns: const {'name', 'target_minor'}),
  SyncableTable(db, db.goalContributions, encryptedColumns: const {'amount_minor', 'note'}),
  SyncableTable(db, db.reminders, encryptedColumns: const {'title'}),
];
