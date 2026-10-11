import 'dart:async';

import 'package:expense_tracker/core/db/app_database.dart';
import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/router/auth_status.dart';
import 'package:expense_tracker/core/sync/initial_sync.dart';
import 'package:expense_tracker/core/sync/sync_registry.dart';
import 'package:expense_tracker/core/sync/sync_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fake_sync_gateway.dart';
import '../../helpers/test_database.dart';

class _MockSyncService extends Mock implements SyncService {}

void main() {
  const done = Result<SyncReport>.success(SyncReport(pushed: 0, pulled: 5));

  late AppDatabase db;
  late _MockSyncService service;
  late ProviderContainer container;

  setUp(() {
    db = createTestDatabase();
    service = _MockSyncService();
    when(() => service.run()).thenAnswer((_) async => done);
    container = createTestContainer(
      db: db,
      overrides: [
        syncServiceProvider.overrideWithValue(service),
        FakeSyncGateway().providerOverride,
      ],
    );
    container.listen(initialSyncProvider, (_, _) {});
  });

  InitialSyncStatus status() => container.read(initialSyncProvider);

  void signIn() => container.read(authStatusControllerProvider.notifier).set(AuthStatus.signedIn);

  Future<void> markPulledBefore() async {
    for (final table in syncableTables(db)) {
      await db.into(db.syncState).insert(SyncStateCompanion.insert(syncTable: table.name));
    }
  }

  test('idle while signed out', () {
    expect(status(), InitialSyncStatus.idle);
  });

  test('a device that pulled before is done without syncing', () async {
    await markPulledBefore();

    signIn();
    expect(status(), InitialSyncStatus.checking);
    await pumpEventQueue();

    expect(status(), InitialSyncStatus.done);
    verifyNever(() => service.run());
  });

  test('a first sign-in runs the initial pull, then is done', () async {
    final run = Completer<Result<SyncReport>>();
    when(() => service.run()).thenAnswer((_) => run.future);

    signIn();
    await pumpEventQueue();
    expect(status(), InitialSyncStatus.running);

    run.complete(done);
    await pumpEventQueue();
    expect(status(), InitialSyncStatus.done);
  });

  test('a failed initial pull lets the app move on', () async {
    when(
      () => service.run(),
    ).thenAnswer((_) async => const Result.failure(NetworkFailure('offline')));

    signIn();
    await pumpEventQueue();

    expect(status(), InitialSyncStatus.failed);
  });

  test('a hanging initial pull gives up after the timeout', () async {
    when(() => service.run()).thenAnswer((_) => Completer<Result<SyncReport>>().future);
    final timed = createTestContainer(
      overrides: [
        syncServiceProvider.overrideWithValue(service),
        FakeSyncGateway().providerOverride,
        initialSyncTimeoutProvider.overrideWithValue(const Duration(milliseconds: 50)),
      ],
    )..listen(initialSyncProvider, (_, _) {});

    timed.read(authStatusControllerProvider.notifier).set(AuthStatus.signedIn);
    await pumpEventQueue();
    expect(timed.read(initialSyncProvider), InitialSyncStatus.running);

    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(timed.read(initialSyncProvider), InitialSyncStatus.failed);
  });

  test('signing out goes back to idle', () async {
    signIn();
    await pumpEventQueue();

    container.read(authStatusControllerProvider.notifier).set(AuthStatus.signedOut);

    expect(status(), InitialSyncStatus.idle);
  });
}
