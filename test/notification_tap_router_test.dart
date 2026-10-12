import 'dart:async';

import 'package:expense_tracker/core/router/app_router.dart';
import 'package:expense_tracker/core/router/auth_status.dart';
import 'package:expense_tracker/core/router/onboarding_status.dart';
import 'package:expense_tracker/core/router/routes.dart';
import 'package:expense_tracker/core/session/session.dart';
import 'package:expense_tracker/core/utils/clock.dart';
import 'package:expense_tracker/features/budget/presentation/providers/budget_providers.dart';
import 'package:expense_tracker/notification_tap_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'helpers/fake_notification_service.dart';
import 'helpers/test_database.dart';

class _MockGoRouter extends Mock implements GoRouter {}

void main() {
  late _MockGoRouter router;
  late FakeNotificationService notifications;
  late StreamController<OnboardingStatus> onboarding;
  late ProviderContainer container;

  void start({String? launchedWith, bool ready = true}) {
    router = _MockGoRouter();
    notifications = FakeNotificationService()..launchedWith = launchedWith;
    onboarding = StreamController<OnboardingStatus>.broadcast();
    addTearDown(onboarding.close);
    container = createTestContainer(
      overrides: [
        clockProvider.overrideWithValue(FixedClock(DateTime(2026, 10, 11, 9))),
        notifications.providerOverride,
        routerProvider.overrideWithValue(router),
        onboardingStatusProvider.overrideWith((ref) => onboarding.stream),
      ],
    );
    container.read(sessionProvider.notifier).set(const SessionUser(userId: 'u1'));
    if (ready) container.read(authStatusControllerProvider.notifier).set(AuthStatus.signedIn);
    container
      ..listen(budgetMonthControllerProvider, (_, _) {})
      ..listen(notificationTapRouterProvider, (_, _) {});
    if (ready) onboarding.add(OnboardingStatus.complete);
  }

  Future<void> settle() => pumpEventQueue();

  test('a tapped reminder opens Settings → Reminders', () async {
    start();
    await settle();

    notifications.tap('reminder:r1');
    await settle();

    verify(() => router.goNamed(Routes.reminders)).called(1);
  });

  test('a tapped budget alert opens the Budget tab on the alert\'s month', () async {
    start();
    await settle();

    notifications.tap('budget:2026-09');
    await settle();

    expect(container.read(budgetMonthControllerProvider), DateTime(2026, 9));
    verify(() => router.goNamed(Routes.budget)).called(1);
  });

  test('a tap that launched the app is opened', () async {
    start(launchedWith: 'reminder:r1');
    await settle();

    verify(() => router.goNamed(Routes.reminders)).called(1);
  });

  test('a launch tap waits until the user is signed in and onboarded', () async {
    start(launchedWith: 'budget:2026-08', ready: false);
    await settle();
    verifyNever(() => router.goNamed(any()));

    container.read(authStatusControllerProvider.notifier).set(AuthStatus.signedIn);
    onboarding.add(OnboardingStatus.required);
    await settle();
    verifyNever(() => router.goNamed(any()));

    onboarding.add(OnboardingStatus.complete);
    await settle();

    verify(() => router.goNamed(Routes.budget)).called(1);
    expect(container.read(budgetMonthControllerProvider), DateTime(2026, 8));
  });

  test('unknown payloads are ignored', () async {
    start();
    await settle();

    notifications.tap('goal:abc');
    notifications.tap('budget:nonsense');
    await settle();

    verifyNever(() => router.goNamed(any()));
  });

  test('only the latest of several waiting taps is opened', () async {
    start(ready: false);
    await settle();
    notifications
      ..tap('reminder:r1')
      ..tap('budget:2026-07');
    await settle();

    container.read(authStatusControllerProvider.notifier).set(AuthStatus.signedIn);
    onboarding.add(OnboardingStatus.complete);
    await settle();

    verify(() => router.goNamed(Routes.budget)).called(1);
    verifyNever(() => router.goNamed(Routes.reminders));
  });
}
