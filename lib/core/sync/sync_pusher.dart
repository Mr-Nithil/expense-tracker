import 'package:drift/drift.dart' show DataClass;
import 'package:expense_tracker/core/db/database_provider.dart';
import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/logging/app_logger.dart';
import 'package:expense_tracker/core/sync/row_sealer.dart';
import 'package:expense_tracker/core/sync/supabase_sync_gateway.dart';
import 'package:expense_tracker/core/sync/sync_gateway.dart';
import 'package:expense_tracker/core/sync/sync_registry.dart';
import 'package:expense_tracker/core/sync/syncable_table.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sync_pusher.g.dart';

/// Push: sends each table's pending rows to the server in dependency order, in batches, and
/// marks them synced (ARCHITECTURE §7).
///
/// Stops at the first failure: everything not yet pushed stays pending for the next run, and a
/// child table is never pushed after its parent failed. Never throws.
class SyncPusher {
  SyncPusher({required this.tables, required this.gateway, this.batchSize = defaultBatchSize});

  /// Rows per upsert request.
  static const defaultBatchSize = 200;

  final List<SyncableTable> tables;
  final SyncGateway gateway;
  final int batchSize;

  /// Pushes [userId]'s pending rows, private columns sealed by [sealer]. Returns how many were
  /// pushed and marked synced.
  Future<Result<int>> push(String userId, {required RowSealer sealer}) async {
    var pushed = 0;
    for (final table in tables) {
      final List<DataClass> rows;
      try {
        rows = await table.pendingRows(userId);
      } catch (error, stackTrace) {
        AppLogger.error('push ${table.name}: reading pending rows failed', error, stackTrace);
        return Result.failure(StorageFailure('push ${table.name}: $error'));
      }

      for (var start = 0; start < rows.length; start += batchSize) {
        final batch = rows.sublist(start, (start + batchSize).clamp(0, rows.length));
        final List<Map<String, Object?>> sealed;
        try {
          sealed = [for (final row in batch) await sealer.seal(table, table.toRemote(row))];
        } catch (error, stackTrace) {
          AppLogger.error('push ${table.name}: sealing failed', error, stackTrace);
          return Result.failure(UnexpectedFailure('push ${table.name}: sealing', cause: error));
        }
        final sent = await gateway.upsert(table.name, sealed);
        if (sent case Failure(:final failure)) return Result.failure(failure);

        try {
          pushed += await table.markSynced(batch);
        } catch (error, stackTrace) {
          // Already on the server; the next run pushes these rows again (an idempotent upsert).
          AppLogger.error('push ${table.name}: marking synced failed', error, stackTrace);
          return Result.failure(StorageFailure('push ${table.name}: $error'));
        }
      }
    }
    return Result.success(pushed);
  }
}

@Riverpod(keepAlive: true)
SyncPusher syncPusher(Ref ref) => SyncPusher(
  tables: syncableTables(ref.watch(databaseProvider)),
  gateway: ref.watch(syncGatewayProvider),
);
