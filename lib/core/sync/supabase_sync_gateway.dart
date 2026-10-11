import 'dart:async';
import 'dart:io';

import 'package:expense_tracker/core/config/supabase_providers.dart';
import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/logging/app_logger.dart';
import 'package:expense_tracker/core/sync/sync_gateway.dart';
import 'package:http/http.dart' show ClientException;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'supabase_sync_gateway.g.dart';

/// [SyncGateway] over Supabase's REST API. The only sync code that talks to Supabase.
///
/// Logs table names and error codes only, never row data.
class SupabaseSyncGateway implements SyncGateway {
  SupabaseSyncGateway(this._client);

  final SupabaseClient _client;

  /// PostgREST "JWT expired / invalid" and Postgres "insufficient privilege" (RLS).
  static const _authCodes = {'PGRST301', '42501'};

  @override
  Future<Result<void>> upsert(String table, List<Map<String, Object?>> rows) async {
    if (rows.isEmpty) return Result.ok;
    return _guard('upsert $table', () async {
      // One request per call; merges on the primary key (`Prefer: resolution=merge-duplicates`).
      await _client.from(table).upsert(rows);
    });
  }

  @override
  Future<Result<List<Map<String, Object?>>>> fetchChanges(
    String table, {
    DateTime? after,
    String? afterId,
    required int limit,
  }) => _guard('fetch $table', () async {
    const column = 'server_updated_at';
    var query = _client.from(table).select();
    if (after != null) {
      // UTC `…Z`: no `+` in the filter value that could be mis-encoded.
      final since = after.toUtc().toIso8601String();
      query = afterId == null
          ? query.gt(column, since)
          : query.or('$column.gt.$since,and($column.eq.$since,id.gt.$afterId)');
    }
    final rows = await query
        .order(column, ascending: true)
        .order('id', ascending: true)
        .limit(limit);
    return [for (final row in rows) Map<String, Object?>.from(row)];
  });

  /// Runs [body] and maps every error to a failure. Logs codes only, never row data.
  Future<Result<T>> _guard<T>(String operation, Future<T> Function() body) async {
    try {
      return Result.success(await body());
    } on PostgrestException catch (error) {
      final status = int.tryParse(error.code ?? '') ?? 0;
      if (_authCodes.contains(error.code) || status == 401 || status == 403) {
        AppLogger.info('sync $operation refused: code=${error.code}');
        return Result.failure(AuthFailure('sync $operation: ${error.code}'));
      }
      AppLogger.warning('sync $operation rejected: code=${error.code}');
      return Result.failure(UnexpectedFailure('sync $operation: ${error.code}', cause: error));
    } on SocketException catch (_) {
      return Result.failure(NetworkFailure('sync $operation: socket'));
    } on TimeoutException catch (_) {
      return Result.failure(NetworkFailure('sync $operation: timeout'));
    } on ClientException catch (_) {
      return Result.failure(NetworkFailure('sync $operation: client'));
    } catch (error, stackTrace) {
      AppLogger.error('sync $operation failed', error, stackTrace);
      return Result.failure(UnexpectedFailure('sync $operation', cause: error));
    }
  }
}

@Riverpod(keepAlive: true)
SyncGateway syncGateway(Ref ref) => SupabaseSyncGateway(ref.watch(supabaseClientProvider));
