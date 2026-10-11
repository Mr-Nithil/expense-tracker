import 'dart:async';

import 'package:expense_tracker/core/db/app_database.dart';
import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/sync/sync_service.dart';
import 'package:expense_tracker/core/sync/sync_status.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fake_connectivity_service.dart';
import '../../helpers/test_database.dart';

class _MockSyncService extends Mock implements SyncService {}

void main() {
  group('derive', () {
    SyncIndicator of({
      bool running = false,
      AppFailure? failure,
      int pending = 0,
      bool online = true,
    }) => SyncStatusInfo.derive(
      run: SyncRunState(isRunning: running, lastFailure: failure),
      pendingCount: pending,
      online: online,
    ).indicator;

    test('follows the priority syncing, offline, error, pending, synced', () {
      expect(of(), SyncIndicator.synced);
      expect(of(pending: 2), SyncIndicator.pending);
      expect(of(failure: const UnexpectedFailure('x'), pending: 2), SyncIndicator.error);
      expect(of(failure: const UnexpectedFailure('x'), online: false), SyncIndicator.offline);
      expect(of(running: true, online: false), SyncIndicator.syncing);
    });

    test('a network failure means offline even when a link exists', () {
      expect(of(failure: const NetworkFailure('unreachable')), SyncIndicator.offline);
    });

    test('an auth failure is an error', () {
      expect(of(failure: const AuthFailure('expired')), SyncIndicator.error);
    });

    test('keeps the pending count', () {
      final info = SyncStatusInfo.derive(
        run: const SyncRunState(),
        pendingCount: 3,
        online: true,
      );
      expect(info, const SyncStatusInfo(SyncIndicator.pending, pendingCount: 3));
    });
  });

  test('the provider follows pending rows, connectivity and runs', () async {
    final db = createTestDatabase();
    final connectivity = FakeConnectivityService();
    final service = _MockSyncService();
    final runs = StreamController<SyncRunState>.broadcast();
    addTearDown(runs.close);
    when(() => service.state).thenReturn(const SyncRunState());
    when(() => service.states).thenAnswer((_) => runs.stream);
    final container = createTestContainer(
      db: db,
      overrides: [
        connectivity.providerOverride,
        syncServiceProvider.overrideWithValue(service),
      ],
    );
    final seen = <SyncIndicator>[];
    container.listen(
      syncStatusProvider,
      (_, next) => next.whenData((info) => seen.add(info.indicator)),
      fireImmediately: true,
    );
    await pumpEventQueue();

    final now = DateTime.utc(2026, 10, 12);
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            id: 'c',
            userId: 'u',
            createdAt: now,
            updatedAt: now,
            name: 'Food',
            icon: 'food',
            color: 0,
            type: 'expense',
          ),
        );
    await pumpEventQueue();
    connectivity.emit(online: false);
    await pumpEventQueue();
    connectivity.emit(online: true);
    await pumpEventQueue();
    runs.add(const SyncRunState(isRunning: true));
    await pumpEventQueue();

    expect(seen, [
      SyncIndicator.synced,
      SyncIndicator.pending,
      SyncIndicator.offline,
      SyncIndicator.pending,
      SyncIndicator.syncing,
    ]);
  });
}
