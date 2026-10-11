import 'package:expense_tracker/core/error/result.dart';

/// The remote side of sync. Keeps Supabase out of the sync logic, so it can be tested with a fake.
///
/// Methods never throw: failures come back as `NetworkFailure` (no connection), `AuthFailure`
/// (session expired, or the server refused access) or `UnexpectedFailure` (rejected data).
abstract interface class SyncGateway {
  /// Inserts or updates [rows] (JSON from `SyncableTable.toRemote`) in [table] by primary key.
  Future<Result<void>> upsert(String table, List<Map<String, Object?>> rows);

  /// Rows of [table] changed on the server, ordered by `server_updated_at`, then `id`, at most
  /// [limit]. With only [after]: changed after it. With [after] and [afterId]: the keyset page
  /// that follows the row (`after`, `afterId`). With neither: from the beginning.
  Future<Result<List<Map<String, Object?>>>> fetchChanges(
    String table, {
    DateTime? after,
    String? afterId,
    required int limit,
  });
}
