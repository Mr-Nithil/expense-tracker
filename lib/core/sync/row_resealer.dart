import 'package:expense_tracker/core/db/app_database.dart';
import 'package:expense_tracker/core/sync/syncable_table.dart';

/// Re-uploads this phone's existing rows sealed, once per user (M11.7, ARCHITECTURE §13).
///
/// Marks every synced row of the user in tables with private columns pending again,
/// `updated_at` unchanged, so the next push sends them sealed and the server
/// (`keep_newer_row` applies equal timestamps) replaces its plain copies. The flag lives in
/// `app_settings`, so logout (which clears it) starts over for the next user.
class RowResealer {
  RowResealer({required this.db, required this.tables});

  static const flagKey = 'rows_sealed_for';

  final AppDatabase db;
  final List<SyncableTable> tables;

  /// Returns how many rows were marked (0 when already done for [userId]).
  Future<int> ensureSealed(String userId) => db.transaction(() async {
    if (await db.appSettingsDao.getValue(flagKey) == userId) return 0;
    var marked = 0;
    for (final table in tables) {
      if (table.encryptedColumns.isNotEmpty) marked += await table.markAllSyncedPending(userId);
    }
    await db.appSettingsDao.setValue(flagKey, userId);
    return marked;
  });
}
