import 'package:expense_tracker/core/db/app_database.dart';
import 'package:expense_tracker/core/sync/syncable_table.dart';

/// Every synced table in **dependency order**: parents before children, so a push never sends a
/// row whose parent the server doesn't have yet (ARCHITECTURE §7).
///
/// Adding a synced table: add it here in the right place. No other sync code changes.
List<SyncableTable> syncableTables(AppDatabase db) => [
  SyncableTable(db, db.profiles),
  SyncableTable(db, db.categories),
  SyncableTable(db, db.transactions),
  SyncableTable(db, db.budgets),
  SyncableTable(db, db.goals),
  SyncableTable(db, db.goalContributions),
  SyncableTable(db, db.reminders),
];
