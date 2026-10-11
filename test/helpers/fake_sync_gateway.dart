import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/sync/supabase_sync_gateway.dart';
import 'package:expense_tracker/core/sync/sync_gateway.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

/// A server that is never reachable: every call fails with [NetworkFailure]. Keeps whole-app
/// tests away from `Supabase.instance`.
class FakeSyncGateway implements SyncGateway {
  static const _offline = NetworkFailure('fake gateway: offline');

  @override
  Future<Result<void>> upsert(String table, List<Map<String, Object?>> rows) async =>
      const Result.failure(_offline);

  @override
  Future<Result<List<Map<String, Object?>>>> fetchChanges(
    String table, {
    DateTime? after,
    String? afterId,
    required int limit,
  }) async => const Result.failure(_offline);

  Override get providerOverride => syncGatewayProvider.overrideWithValue(this);
}
