import 'dart:async';

import 'package:expense_tracker/core/crypto/data_key_service.dart';
import 'package:expense_tracker/core/crypto/row_cipher.dart';
import 'package:expense_tracker/core/db/database_provider.dart';
import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/logging/app_logger.dart';
import 'package:expense_tracker/core/session/session.dart';
import 'package:expense_tracker/core/sync/row_resealer.dart';
import 'package:expense_tracker/core/sync/row_sealer.dart';
import 'package:expense_tracker/core/sync/supabase_data_key_gateway.dart';
import 'package:expense_tracker/core/sync/sync_puller.dart';
import 'package:expense_tracker/core/sync/sync_pusher.dart';
import 'package:expense_tracker/core/sync/sync_registry.dart';
import 'package:meta/meta.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sync_service.g.dart';

/// What one sync run did.
@immutable
class SyncReport {
  const SyncReport({required this.pushed, required this.pulled});

  final int pushed;
  final int pulled;

  @override
  bool operator ==(Object other) =>
      other is SyncReport && other.pushed == pushed && other.pulled == pulled;

  @override
  int get hashCode => Object.hash(pushed, pulled);

  @override
  String toString() => 'SyncReport(pushed: $pushed, pulled: $pulled)';
}

/// Whether a sync is running and how the last one ended, for the status indicator (M3.9).
@immutable
class SyncRunState {
  const SyncRunState({this.isRunning = false, this.lastFailure});

  final bool isRunning;

  /// Why the last finished run failed; `null` after a success (or before any failure).
  final AppFailure? lastFailure;

  @override
  bool operator ==(Object other) =>
      other is SyncRunState && other.isRunning == isRunning && other.lastFailure == lastFailure;

  @override
  int get hashCode => Object.hash(isRunning, lastFailure);
}

/// Runs sync for the signed-in user: push, then pull (ARCHITECTURE §7).
///
/// Only one run at a time: calling [run] while one is in flight returns that run's result and
/// schedules one more pass right after it (if it succeeded), so changes made meanwhile are not
/// left waiting. Never throws.
class SyncService {
  SyncService({
    required this.pusher,
    required this.puller,
    required this.session,
    required this.dataKeys,
    required this.resealer,
  });

  /// Returned when nobody is signed in: nothing to sync, and nothing to retry.
  static const noSessionFailure = AuthFailure('sync: no session');

  final SyncPusher pusher;
  final SyncPuller puller;
  final Session session;

  /// The user's data key: every run seals and opens private columns with it (M11.6).
  final DataKeyService dataKeys;

  /// Re-uploads this phone's existing rows sealed, once per user (M11.7).
  final RowResealer resealer;

  Future<Result<SyncReport>>? _running;
  var _runAgain = false;

  final _states = StreamController<SyncRunState>.broadcast();
  var _state = const SyncRunState();

  /// The current run state; [states] reports every change.
  SyncRunState get state => _state;

  Stream<SyncRunState> get states => _states.stream;

  void _setState(SyncRunState next) {
    if (next == _state) return;
    _state = next;
    if (!_states.isClosed) _states.add(next);
  }

  /// Closes [states] (when the provider is disposed).
  void dispose() => unawaited(_states.close());

  Future<Result<SyncReport>> run() {
    final running = _running;
    if (running != null) {
      _runAgain = true;
      return running;
    }
    return _running = _loop();
  }

  /// Completes when no run is in flight (e.g. before clearing local data).
  Future<void> whenIdle() async {
    for (var running = _running; running != null; running = _running) {
      await running;
    }
  }

  Future<Result<SyncReport>> _loop() async {
    _setState(SyncRunState(isRunning: true, lastFailure: _state.lastFailure));
    Result<SyncReport>? result;
    try {
      do {
        _runAgain = false;
        result = await _runOnce();
        _log(result);
        // After a failure (e.g. offline), don't loop: the trigger retries with backoff.
      } while (_runAgain && result.isSuccess);
      return result;
    } finally {
      _running = null;
      _setState(
        SyncRunState(
          lastFailure: switch (result) {
            Failure(:final failure) when !identical(failure, noSessionFailure) => failure,
            _ => null,
          },
        ),
      );
    }
  }

  /// One line per run. Failure messages hold table names and error codes, never row data.
  static void _log(Result<SyncReport> result) => switch (result) {
    Success(:final value) => AppLogger.info(
      'sync done: pushed ${value.pushed}, pulled ${value.pulled}',
    ),
    Failure(:final failure) when identical(failure, noSessionFailure) => null,
    Failure(:final failure) => AppLogger.warning(
      'sync failed: ${failure.runtimeType} ${failure.message}',
    ),
  };

  Future<Result<SyncReport>> _runOnce() async {
    final userId = session.currentUser?.userId;
    if (userId == null) return const Result.failure(noSessionFailure);
    try {
      // No key, no sync: nothing private ever leaves or is read without it.
      final sealer = switch (await dataKeys.keyFor(userId)) {
        Failure(:final failure) => throw _Stop(failure),
        Success(:final value) => RowSealer(RowCipher(value)),
      };
      try {
        await resealer.ensureSealed(userId);
      } catch (error, stackTrace) {
        AppLogger.error('sync: marking rows for sealing failed', error, stackTrace);
        throw _Stop(StorageFailure('reseal: $error'));
      }
      final pushedCount = switch (await pusher.push(userId, sealer: sealer)) {
        Failure(:final failure) => throw _Stop(failure),
        Success(:final value) => value,
      };
      final pulled = await puller.pull(userId, sealer: sealer);
      // Plain rows from the server were marked pending: push them sealed right away.
      if (pulled.isSuccess && puller.lastResealed > 0) _runAgain = true;
      return switch (pulled) {
        Failure(:final failure) => Result.failure(failure),
        Success(:final value) => Result.success(SyncReport(pushed: pushedCount, pulled: value)),
      };
    } on _Stop catch (stop) {
      return Result.failure(stop.failure);
    } catch (error, stackTrace) {
      AppLogger.error('sync run failed unexpectedly', error, stackTrace);
      return Result.failure(UnexpectedFailure('sync run', cause: error));
    }
  }
}

/// Ends a run early with [failure] (no key, or push failed, so pull is skipped).
class _Stop implements Exception {
  const _Stop(this.failure);

  final AppFailure failure;
}

@Riverpod(keepAlive: true)
SyncService syncService(Ref ref) {
  final db = ref.watch(databaseProvider);
  final service = SyncService(
    pusher: ref.watch(syncPusherProvider),
    puller: ref.watch(syncPullerProvider),
    session: ref.watch(sessionProvider.notifier),
    dataKeys: ref.watch(dataKeyServiceProvider),
    resealer: RowResealer(db: db, tables: syncableTables(db)),
  );
  ref.onDispose(service.dispose);
  return service;
}
