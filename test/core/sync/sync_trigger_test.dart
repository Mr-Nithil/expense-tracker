import 'dart:async';

import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/sync/sync_service.dart';
import 'package:expense_tracker/core/sync/sync_trigger.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockSyncService extends Mock implements SyncService {}

void main() {
  const report = SyncReport(pushed: 1, pulled: 2);

  late _MockSyncService service;
  late DebouncedSyncTrigger trigger;

  setUp(() {
    service = _MockSyncService();
    when(() => service.run()).thenAnswer((_) async => const Result.success(report));
    trigger = DebouncedSyncTrigger(service: service);
  });

  // testWidgets runs on fake time, so the debounce can be stepped through.
  testWidgets('a burst of requests becomes one run after the debounce', (tester) async {
    trigger
      ..requestSync()
      ..requestSync();
    await tester.pump(const Duration(seconds: 1));
    trigger.requestSync();
    await tester.pump(const Duration(milliseconds: 1999));
    verifyNever(() => service.run());

    await tester.pump(const Duration(milliseconds: 1));
    verify(() => service.run()).called(1);
  });

  testWidgets('syncNow runs at once and drops the pending run', (tester) async {
    trigger.requestSync();

    final result = await trigger.syncNow();
    await tester.pump(DebouncedSyncTrigger.defaultDebounce * 2);

    expect(result.valueOrNull, report);
    verify(() => service.run()).called(1);
  });

  testWidgets('cancel prevents the pending run', (tester) async {
    trigger
      ..requestSync()
      ..cancel();
    await tester.pump(DebouncedSyncTrigger.defaultDebounce * 2);

    verifyNever(() => service.run());
  });

  group('retry with backoff', () {
    const offline = Result<SyncReport>.failure(NetworkFailure('offline'));

    testWidgets('repeated failures retry after 5 s, then 10 s, then 20 s', (tester) async {
      when(() => service.run()).thenAnswer((_) async => offline);

      await trigger.syncNow();
      verify(() => service.run()).called(1);

      for (final seconds in [5, 10, 20]) {
        await tester.pump(Duration(seconds: seconds) - const Duration(milliseconds: 1));
        verifyNever(() => service.run());
        await tester.pump(const Duration(milliseconds: 1));
        verify(() => service.run()).called(1);
      }
      trigger.cancel();
    });

    testWidgets('a success resets the backoff', (tester) async {
      when(() => service.run()).thenAnswer((_) async => offline);
      await trigger.syncNow();
      await tester.pump(const Duration(seconds: 5));
      when(() => service.run()).thenAnswer((_) async => const Result.success(report));
      await trigger.syncNow();
      clearInteractions(service);

      when(() => service.run()).thenAnswer((_) async => offline);
      await trigger.syncNow();
      await tester.pump(const Duration(seconds: 5));

      verify(() => service.run()).called(2);
      trigger.cancel();
    });

    test('the delay doubles up to the cap, without overflowing', () {
      expect(trigger.retryDelay(1), const Duration(seconds: 5));
      expect(trigger.retryDelay(4), const Duration(seconds: 40));
      expect(trigger.retryDelay(9), DebouncedSyncTrigger.defaultRetryMax);
      expect(trigger.retryDelay(1000), DebouncedSyncTrigger.defaultRetryMax);
    });

    testWidgets('no session: nothing to retry', (tester) async {
      when(
        () => service.run(),
      ).thenAnswer((_) async => const Result.failure(SyncService.noSessionFailure));

      await trigger.syncNow();
      await tester.pump(const Duration(minutes: 15));

      verify(() => service.run()).called(1);
    });

    testWidgets('a new request replaces a pending retry', (tester) async {
      when(() => service.run()).thenAnswer((_) async => offline);
      await trigger.syncNow();
      clearInteractions(service);

      trigger.requestSync();
      await tester.pump(const Duration(seconds: 5));

      // One run (the debounced request at 2 s), not two.
      verify(() => service.run()).called(1);
      trigger.cancel();
    });

    testWidgets('cancel stops retrying, even for a run that fails after it', (tester) async {
      final inFlight = Completer<Result<SyncReport>>();
      when(() => service.run()).thenAnswer((_) => inFlight.future);
      final running = trigger.syncNow();

      trigger.cancel();
      inFlight.complete(offline);
      await running;
      await tester.pump(const Duration(minutes: 15));

      verify(() => service.run()).called(1);
    });
  });
}
