import 'package:drift/drift.dart' show InsertMode, Value;
import 'package:expense_tracker/core/db/app_database.dart';
import 'package:expense_tracker/core/db/database_provider.dart';
import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/logging/app_logger.dart';
import 'package:expense_tracker/core/sync/supabase_sync_gateway.dart';
import 'package:expense_tracker/core/sync/sync_gateway.dart';
import 'package:expense_tracker/core/sync/sync_registry.dart';
import 'package:expense_tracker/core/sync/syncable_table.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sync_puller.g.dart';

/// Pull: fetches rows changed on the server since each table's cursor and merges them
/// (last-write-wins), in dependency order (ARCHITECTURE §7).
///
/// - Starts at `cursor - overlap`: `server_updated_at` is set before commit, so a row can become
///   visible after the cursor passed it. Re-fetched rows merge idempotently.
/// - Pages by keyset (`server_updated_at`, `id`), so rows sharing a timestamp are never skipped.
/// - Each page and its cursor move are one DB transaction. A failure stops the run; merged pages
///   stay merged, and the next run resumes from the cursor. Never throws.
class SyncPuller {
  SyncPuller({
    required this.db,
    required this.tables,
    required this.gateway,
    this.pageSize = defaultPageSize,
    this.overlap = defaultOverlap,
  });

  static const defaultPageSize = 500;
  static const defaultOverlap = Duration(seconds: 5);

  final AppDatabase db;
  final List<SyncableTable> tables;
  final SyncGateway gateway;
  final int pageSize;
  final Duration overlap;

  /// Pulls [userId]'s changes. Returns how many rows were inserted or updated locally.
  Future<Result<int>> pull(String userId) async {
    var merged = 0;
    for (final table in tables) {
      DateTime? cursor;
      try {
        cursor = await _readCursor(table.name);
      } catch (error, stackTrace) {
        AppLogger.error('pull ${table.name}: reading cursor failed', error, stackTrace);
        return Result.failure(StorageFailure('pull ${table.name}: $error'));
      }

      var after = cursor?.subtract(overlap);
      String? afterId;
      while (true) {
        final page = await gateway.fetchChanges(
          table.name,
          after: after,
          afterId: afterId,
          limit: pageSize,
        );
        final List<Map<String, Object?>> rows;
        switch (page) {
          case Failure(:final failure):
            return Result.failure(failure);
          case Success(:final value):
            rows = value;
        }
        if (rows.isEmpty) break;

        try {
          final (changed, newest) = await _mergePage(table, rows, userId, cursor);
          merged += changed;
          cursor = newest;
        } catch (error, stackTrace) {
          AppLogger.error('pull ${table.name}: merging a page failed', error, stackTrace);
          return Result.failure(StorageFailure('pull ${table.name}: $error'));
        }

        if (rows.length < pageSize) break;
        // Keyset: continue right after the last row of this page.
        after = DateTime.parse(rows.last[SyncableTable.serverUpdatedAtColumn]! as String).toUtc();
        afterId = rows.last['id']! as String;
      }

      // Mark the table as pulled even when the server had nothing (a new account), so the
      // first-pull check (M3.8) doesn't block every start.
      try {
        await _ensureCursorRow(table.name);
      } catch (error, stackTrace) {
        AppLogger.error('pull ${table.name}: marking pulled failed', error, stackTrace);
        return Result.failure(StorageFailure('pull ${table.name}: $error'));
      }
    }
    return Result.success(merged);
  }

  /// Merges one page and moves the cursor forward, atomically. Returns the number of rows
  /// inserted or updated, and the new cursor.
  Future<(int, DateTime?)> _mergePage(
    SyncableTable table,
    List<Map<String, Object?>> rows,
    String userId,
    DateTime? cursor,
  ) => db.transaction(() async {
    var changed = 0;
    var newest = cursor;
    for (final json in rows) {
      final outcome = await table.merge(await table.fromRemote(json), userId: userId);
      if (outcome == MergeOutcome.inserted || outcome == MergeOutcome.updated) changed++;
      final stamp = DateTime.parse(json[SyncableTable.serverUpdatedAtColumn]! as String).toUtc();
      // The overlap re-fetches older rows: the cursor only moves forward.
      if (newest == null || stamp.isAfter(newest)) newest = stamp;
    }
    if (newest != null && newest != cursor) await _writeCursor(table.name, newest);
    return (changed, newest);
  });

  /// Whether every table has been pulled successfully at least once on this device for the
  /// current local data (logout and user switch clear it).
  Future<bool> hasCompletedFirstPull() async {
    final names = {for (final table in tables) table.name};
    final rows = await db.select(db.syncState).get();
    return names.difference({for (final row in rows) row.syncTable}).isEmpty;
  }

  Future<void> _ensureCursorRow(String table) => db
      .into(db.syncState)
      .insert(SyncStateCompanion.insert(syncTable: table), mode: InsertMode.insertOrIgnore);

  Future<DateTime?> _readCursor(String table) async {
    final row = await (db.select(
      db.syncState,
    )..where((s) => s.syncTable.equals(table))).getSingleOrNull();
    return row?.lastPulledAt;
  }

  Future<void> _writeCursor(String table, DateTime at) => db
      .into(db.syncState)
      .insertOnConflictUpdate(SyncStateCompanion.insert(syncTable: table, lastPulledAt: Value(at)));
}

@Riverpod(keepAlive: true)
SyncPuller syncPuller(Ref ref) {
  final db = ref.watch(databaseProvider);
  return SyncPuller(db: db, tables: syncableTables(db), gateway: ref.watch(syncGatewayProvider));
}
