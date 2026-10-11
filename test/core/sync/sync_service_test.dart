import 'dart:async';

import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/session/session.dart';
import 'package:expense_tracker/core/sync/sync_puller.dart';
import 'package:expense_tracker/core/sync/sync_pusher.dart';
import 'package:expense_tracker/core/sync/sync_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockPusher extends Mock implements SyncPusher {}

class _MockPuller extends Mock implements SyncPuller {}

void main() {
  const user = 'user-1';

  late _MockPusher pusher;
  late _MockPuller puller;
  late Session session;
  late SyncService service;

  setUp(() {
    pusher = _MockPusher();
    puller = _MockPuller();
    final container = ProviderContainer();
    addTearDown(container.dispose);
    session = container.read(sessionProvider.notifier)..set(const SessionUser(userId: user));
    service = SyncService(pusher: pusher, puller: puller, session: session);
    when(() => pusher.push(any())).thenAnswer((_) async => const Result.success(2));
    when(() => puller.pull(any())).thenAnswer((_) async => const Result.success(3));
  });

  test('pushes, then pulls, for the signed-in user', () async {
    final result = await service.run();

    expect(result.valueOrNull, const SyncReport(pushed: 2, pulled: 3));
    verifyInOrder([() => pusher.push(user), () => puller.pull(user)]);
  });

  test('a push failure stops the run before pulling', () async {
    when(
      () => pusher.push(any()),
    ).thenAnswer((_) async => const Result.failure(NetworkFailure('offline')));

    final result = await service.run();

    expect(result.failureOrNull, isA<NetworkFailure>());
    verifyNever(() => puller.pull(any()));
  });

  test('without a session nothing runs', () async {
    session.set(null);

    final result = await service.run();

    expect(result.failureOrNull, same(SyncService.noSessionFailure));
    verifyNever(() => pusher.push(any()));
  });

  test('overlapping calls share one run and add exactly one more pass', () async {
    final firstPush = Completer<Result<int>>();
    var pushes = 0;
    when(() => pusher.push(any())).thenAnswer((_) {
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
    when(() => pusher.push(any())).thenAnswer((_) {
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
    when(() => puller.pull(any())).thenThrow(StateError('boom'));

    final result = await service.run();

    expect(result.failureOrNull, isA<UnexpectedFailure>());
  });

  test('a new run can start once the previous one finished', () async {
    await service.run();
    await service.run();

    verify(() => pusher.push(user)).called(2);
  });

  test('whenIdle waits for the run in flight', () async {
    final push = Completer<Result<int>>();
    when(() => pusher.push(any())).thenAnswer((_) => push.future);
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
      when(() => pusher.push(any())).thenAnswer((_) => push.future);
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

      when(() => pusher.push(any())).thenAnswer((_) async => const Result.success(0));
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
