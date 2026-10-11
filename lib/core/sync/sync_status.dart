import 'dart:async';

import 'package:expense_tracker/core/db/database_provider.dart';
import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/services/connectivity_service.dart';
import 'package:expense_tracker/core/sync/sync_service.dart';
import 'package:meta/meta.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sync_status.g.dart';

/// What the sync indicator shows. (Not the per-row `SyncStatus` of the database.)
enum SyncIndicator { synced, syncing, pending, offline, error }

@immutable
class SyncStatusInfo {
  const SyncStatusInfo(this.indicator, {this.pendingCount = 0});

  /// Priority: syncing → offline → error → pending → synced. A network failure counts as offline
  /// even when a link exists (the server is unreachable).
  factory SyncStatusInfo.derive({
    required SyncRunState run,
    required int pendingCount,
    required bool online,
  }) {
    final indicator = switch (run) {
      SyncRunState(isRunning: true) => SyncIndicator.syncing,
      _ when !online => SyncIndicator.offline,
      SyncRunState(lastFailure: NetworkFailure()) => SyncIndicator.offline,
      SyncRunState(lastFailure: _?) => SyncIndicator.error,
      _ when pendingCount > 0 => SyncIndicator.pending,
      _ => SyncIndicator.synced,
    };
    return SyncStatusInfo(indicator, pendingCount: pendingCount);
  }

  final SyncIndicator indicator;

  /// Local changes not on the server yet.
  final int pendingCount;

  @override
  bool operator ==(Object other) =>
      other is SyncStatusInfo && other.indicator == indicator && other.pendingCount == pendingCount;

  @override
  int get hashCode => Object.hash(indicator, pendingCount);

  @override
  String toString() => 'SyncStatusInfo($indicator, pending: $pendingCount)';
}

/// The sync state for the UI, from the sync runs, the pending-row count and connectivity.
@Riverpod(keepAlive: true)
Stream<SyncStatusInfo> syncStatus(Ref ref) {
  final service = ref.watch(syncServiceProvider);
  final db = ref.watch(databaseProvider);
  final connectivity = ref.watch(connectivityServiceProvider);
  final controller = StreamController<SyncStatusInfo>();

  var run = service.state;
  int? pending;
  var online = true;

  void emit() {
    final count = pending;
    if (count == null || controller.isClosed) return;
    controller.add(SyncStatusInfo.derive(run: run, pendingCount: count, online: online));
  }

  final subscriptions = <StreamSubscription<Object?>>[
    service.states.listen((state) {
      run = state;
      emit();
    }),
    db.watchPendingCount().listen((count) {
      pending = count;
      emit();
    }),
    connectivity.onlineChanges.listen((value) {
      online = value;
      emit();
    }),
  ];
  unawaited(
    connectivity.isOnline().then((value) {
      online = value;
      emit();
    }),
  );

  ref.onDispose(() {
    for (final subscription in subscriptions) {
      unawaited(subscription.cancel());
    }
    unawaited(controller.close());
  });
  return controller.stream.distinct();
}
