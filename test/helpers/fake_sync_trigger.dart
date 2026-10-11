import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/sync/sync_service.dart';
import 'package:expense_tracker/core/sync/sync_trigger.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

/// Records sync requests; never starts timers or syncs.
class FakeSyncTrigger implements SyncTrigger {
  var requests = 0;
  var immediate = 0;
  var cancels = 0;
  Result<SyncReport> nowResult = const Result.success(SyncReport(pushed: 0, pulled: 0));

  @override
  void requestSync() => requests++;

  @override
  Future<Result<SyncReport>> syncNow() async {
    immediate++;
    return nowResult;
  }

  @override
  void cancel() => cancels++;

  Override get providerOverride => syncTriggerProvider.overrideWithValue(this);
}
