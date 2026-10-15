import 'dart:async';

import 'package:expense_tracker/core/crypto/data_key_service.dart';
import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/session/session.dart';
import 'package:expense_tracker/core/sync/row_resealer.dart';
import 'package:expense_tracker/core/sync/row_sealer.dart';
import 'package:expense_tracker/core/sync/sync_puller.dart';
import 'package:expense_tracker/core/sync/sync_pusher.dart';
import 'package:expense_tracker/core/sync/sync_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fake_data_key_gateway.dart';
import '../../helpers/fake_secure_storage.dart';

class _MockPusher extends Mock implements SyncPusher {}

class _MockPuller extends Mock implements SyncPuller {}

class _MockResealer extends Mock implements RowResealer {}

void main() {
  const user = 'user-1';

  late _MockPusher pusher;
  late _MockPuller puller;
  late Session session;
  late SyncService service;
  late FakeKeyServer keys;
  late _MockResealer resealer;

  setUpAll(() => registerFallbackValue(RowSealer.none));

  setUp(() {
    pusher = _MockPusher();
    puller = _MockPuller();
    final container = ProviderContainer();
    addTearDown(container.dispose);
    session = container.read(sessionProvider.notifier)..set(const SessionUser(userId: user));
    keys = FakeKeyServer();
    resealer = _MockResealer();
    service = SyncService(
      pusher: pusher,
      puller: puller,
      session: session,
      dataKeys: DataKeyService(storage: FakeSecureStorage(), gateway: keys.gatewayFor(() => user)),
      resealer: resealer,
    );
    when(() => resealer.ensureSealed(any())).thenAnswer((_) async => 0);
    when(() => puller.lastResealed).thenReturn(0);
    when(
      () => pusher.push(any(), sealer: any(named: 'sealer')),
    ).thenAnswer((_) async => const Result.success(2));
    when(
      () => puller.pull(any(), sealer: any(named: 'sealer')),
    ).thenAnswer((_) async => const Result.success(3));
  });

  test('without the data key nothing is pushed or pulled, and the run says why', () async {
    keys.failure = const Result.failure(NetworkFailure('offline'));

    final result = await service.run();

    expect(result.failureOrNull, isA<NetworkFailure>());
    verifyNever(() => pusher.push(any(), sealer: any(named: 'sealer')));
    verifyNever(() => puller.pull(any(), sealer: any(named: 'sealer')));
  });

  test('push and pull get a sealer with the user\'s key', () async {
    await service.run();

    final sealer =
        verify(() => pusher.push(user, sealer: captureAny(named: 'sealer'))).captured.single
            as RowSealer;
    expect(identical(sealer, RowSealer.none), isFalse);
  });

  test('existing rows are marked for sealing before the push', () async {
    await service.run();

    verifyInOrder([
      () => resealer.ensureSealed(user),
      () => pusher.push(user, sealer: any(named: 'sealer')),
    ]);
  });

  test('plain rows found by the pull are pushed sealed in one more pass', () async {
    var pulls = 0;
    when(() => puller.lastResealed).thenAnswer((_) => pulls == 1 ? 4 : 0);
    when(() => puller.pull(any(), sealer: any(named: 'sealer'))).thenAnswer((_) async {
      pulls++;
      return const Result.success(3);
    });

    await service.run();

    verify(() => pusher.push(user, sealer: any(named: 'sealer'))).called(2);
  });

  test('pushes, then pulls, for the signed-in user', () async {
    final result = await service.run();

    expect(result.valueOrNull, const SyncReport(pushed: 2, pulled: 3));
    verifyInOrder([
      () => pusher.push(user, sealer: any(named: 'sealer')),
      () => puller.pull(user, sealer: any(named: 'sealer')),
    ]);
  });

  test('a push failure stops the run before pulling', () async {
    when(
      () => pusher.push(any(), sealer: any(named: 'sealer')),
    ).thenAnswer((_) async => const Result.failure(NetworkFailure('offline')));

    final result = await service.run();

    expect(result.failureOrNull, isA<NetworkFailure>());
    verifyNever(() => puller.pull(any(), sealer: any(named: 'sealer')));
  });

  test('without a session nothing runs', () async {
    session.set(null);

    final result = await service.run();

    expect(result.failureOrNull, same(SyncService.noSessionFailure));
    verifyNever(() => pusher.push(any(), sealer: any(named: 'sealer')));
  });

  test('overlapping calls share one run and add exactly one more pass', () async {
    final firstPush = Completer<Result<int>>();
    var pushes = 0;
    when(() => pusher.push(any(), sealer: any(named: 'sealer'))).thenAnswer((_) {
      pushes++;
      return pushes == 1 ? firstPush.future : Future.value(const Result.success(0));
    });

    final first = service.run();
    final second = service.run();
    final third = service.run();
    expect(identical(first, second), isTrue);
    expect(identical(first, third), isTrue);

    firstPush.complete(const Result.success(1));
    final result = await first;

    expect(result.isSuccess, isTrue);
    expect(pushes, 2);
  });

  test('no extra pass after a failed run', () async {
    final firstPush = Completer<Result<int>>();
    var pushes = 0;
    when(() => pusher.push(any(), sealer: any(named: 'sealer'))).thenAnswer((_) {
      pushes++;
      return firstPush.future;
    });

    final first = service.run();
    unawaited(service.run());
    firstPush.complete(const Result.failure(NetworkFailure('offline')));
    await first;

    expect(pushes, 1);
  });

  test('an unexpected exception becomes a failure, not a crash', () async {
    when(() => puller.pull(any(), sealer: any(named: 'sealer'))).thenThrow(StateError('boom'));

    final result = await service.run();

    expect(result.failureOrNull, isA<UnexpectedFailure>());
  });

  test('a new run can start once the previous one finished', () async {
    await service.run();
    await service.run();

    verify(() => pusher.push(user, sealer: any(named: 'sealer'))).called(2);
  });

  test('whenIdle waits for the run in flight', () async {
    final push = Completer<Result<int>>();
    when(() => pusher.push(any(), sealer: any(named: 'sealer'))).thenAnswer((_) => push.future);
    unawaited(service.run());
    var idle = false;
    unawaited(service.whenIdle().then((_) => idle = true));

    await pumpEventQueue();
    expect(idle, isFalse);

    push.complete(const Result.success(0));
    await pumpEventQueue();
    expect(idle, isTrue);
  });

  group('run state', () {
    test('is running during a run and records how it ended', () async {
      final push = Completer<Result<int>>();
      when(() => pusher.push(any(), sealer: any(named: 'sealer'))).thenAnswer((_) => push.future);
      final states = <SyncRunState>[];
      final subscription = service.states.listen(states.add);
      addTearDown(subscription.cancel);

      final run = service.run();
      expect(service.state.isRunning, isTrue);
      push.complete(const Result.failure(NetworkFailure('offline')));
      await run;
      await pumpEventQueue();

      expect(service.state.isRunning, isFalse);
      expect(service.state.lastFailure, isA<NetworkFailure>());

      when(
        () => pusher.push(any(), sealer: any(named: 'sealer')),
      ).thenAnswer((_) async => const Result.success(0));
      await service.run();
      await pumpEventQueue();

      expect(service.state, const SyncRunState());
      expect(states.map((s) => s.isRunning), [true, false, true, false]);
    });

    test('a signed-out run is not recorded as a failure', () async {
      session.set(null);

      await service.run();

      expect(service.state.lastFailure, isNull);
    });
  });
}
