import 'dart:async';

import 'package:expense_tracker/core/router/app_router.dart';
import 'package:expense_tracker/core/router/auth_status.dart';
import 'package:expense_tracker/core/router/onboarding_status.dart';
import 'package:expense_tracker/core/router/routes.dart';
import 'package:expense_tracker/core/services/local_notification_service.dart';
import 'package:expense_tracker/core/services/notification_payload.dart';
import 'package:expense_tracker/features/budget/presentation/providers/budget_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notification_tap_router.g.dart';

/// Opens what a tapped notification is about (watched by `App`): a reminder opens Settings →
/// Reminders; a budget alert opens the Budget tab on the alert's month.
///
/// Composition root (like `app.dart`), because it needs both the router and a feature's
/// controller. A tap that launched the app is held until the user is signed in and onboarded,
/// so the redirect to splash/login/onboarding doesn't swallow it. Only the latest tap is kept.
@Riverpod(keepAlive: true)
class NotificationTapRouter extends _$NotificationTapRouter {
  NotificationPayload? _pending;

  @override
  void build() {
    final notifications = ref.read(notificationServiceProvider);
    final taps = notifications.taps.listen(_receive);
    ref.onDispose(taps.cancel);
    ref
      ..listen(authStatusControllerProvider, (_, _) => _open())
      ..listen(onboardingStatusProvider, (_, _) => _open());
    unawaited(_receiveLaunch());
  }

  Future<void> _receiveLaunch() async {
    await ref.read(notificationSetupProvider.future);
    _receive(await ref.read(notificationServiceProvider).launchPayload());
  }

  void _receive(String? payload) {
    final parsed = NotificationPayload.parse(payload);
    if (parsed == null) return;
    _pending = parsed;
    _open();
  }

  bool get _ready =>
      ref.read(authStatusControllerProvider) == AuthStatus.signedIn &&
      ref.read(onboardingStatusProvider).value == OnboardingStatus.complete;

  void _open() {
    final payload = _pending;
    if (payload == null || !_ready) return;
    _pending = null;
    final router = ref.read(routerProvider);
    switch (payload) {
      case ReminderPayload():
        router.goNamed(Routes.reminders);
      case BudgetPayload(:final month):
        ref.read(budgetMonthControllerProvider.notifier).setMonth(month);
        router.goNamed(Routes.budget);
    }
  }
}
