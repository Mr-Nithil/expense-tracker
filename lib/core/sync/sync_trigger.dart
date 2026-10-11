import 'dart:async';

import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/logging/app_logger.dart';
import 'package:expense_tracker/core/sync/sync_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sync_trigger.g.dart';

/// Asks for a sync. Repositories call [requestSync] after every write; screens call [syncNow]
/// for pull-to-refresh (ARCHITECTURE §7).
abstract interface class SyncTrigger {
  /// Syncs soon: calls within the debounce window collapse into one run.
  void requestSync();

  /// Syncs right away (dropping a pending debounced run) and returns its result.
  Future<Result<SyncReport>> syncNow();

  /// Drops a pending debounced run (e.g. on sign-out).
  void cancel();
}

/// [SyncTrigger] that debounces [requestSync] (a burst of edits = one sync) and retries failed
/// runs with exponential backoff: [retryBase], doubling, capped at [retryMax]. A success resets the
/// backoff; any new request replaces a pending retry; [cancel] (sign-out) stops retrying.
class DebouncedSyncTrigger implements SyncTrigger {
  DebouncedSyncTrigger({
    required this.service,
    this.debounce = defaultDebounce,
    this.retryBase = defaultRetryBase,
    this.retryMax = defaultRetryMax,
  });

  static const defaultDebounce = Duration(seconds: 2);
  static const defaultRetryBase = Duration(seconds: 5);
  static const defaultRetryMax = Duration(minutes: 10);

  final SyncService service;
  final Duration debounce;
  final Duration retryBase;
  final Duration retryMax;

  /// The next scheduled run (debounced request or retry). At most one.
  Timer? _timer;
  var _failures = 0;

  /// Bumped by [cancel], so a run that finishes after sign-out doesn't schedule a retry.
  var _generation = 0;

  @override
  void requestSync() => _schedule(debounce);

  @override
  Future<Result<SyncReport>> syncNow() {
    _timer?.cancel();
    _timer = null;
    return _run();
  }

  @override
  void cancel() {
    _timer?.cancel();
    _timer = null;
    _failures = 0;
    _generation++;
  }

  /// Delay before the retry after [failures] consecutive failed runs.
  Duration retryDelay(int failures) {
    var delay = retryBase;
    for (var i = 1; i < failures && delay < retryMax; i++) {
      delay *= 2;
    }
    return delay > retryMax ? retryMax : delay;
  }

  void _schedule(Duration delay) {
    _timer?.cancel();
    _timer = Timer(delay, () {
      _timer = null;
      unawaited(_run());
    });
  }

  Future<Result<SyncReport>> _run() async {
    final generation = _generation;
    final result = await service.run();
    if (generation != _generation) return result;

    switch (result) {
      case Success():
        _failures = 0;
      case Failure(:final failure) when identical(failure, SyncService.noSessionFailure):
        _failures = 0;
      case Failure():
        _failures++;
        // A newer request already scheduled a run: that one is the retry.
        if (_timer == null) {
          final delay = retryDelay(_failures);
          AppLogger.info('sync retry in ${delay.inSeconds}s (failure $_failures)');
          _schedule(delay);
        }
    }
    return result;
  }
}

@Riverpod(keepAlive: true)
SyncTrigger syncTrigger(Ref ref) {
  final trigger = DebouncedSyncTrigger(service: ref.watch(syncServiceProvider));
  ref.onDispose(trigger.cancel);
  return trigger;
}
