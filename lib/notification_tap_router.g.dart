// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_tap_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Opens what a tapped notification is about (watched by `App`): a reminder opens Settings →
/// Reminders; a budget alert opens the Budget tab on the alert's month.
///
/// Composition root (like `app.dart`), because it needs both the router and a feature's
/// controller. A tap that launched the app is held until the user is signed in and onboarded,
/// so the redirect to splash/login/onboarding doesn't swallow it. Only the latest tap is kept.

@ProviderFor(NotificationTapRouter)
final notificationTapRouterProvider = NotificationTapRouterProvider._();

/// Opens what a tapped notification is about (watched by `App`): a reminder opens Settings →
/// Reminders; a budget alert opens the Budget tab on the alert's month.
///
/// Composition root (like `app.dart`), because it needs both the router and a feature's
/// controller. A tap that launched the app is held until the user is signed in and onboarded,
/// so the redirect to splash/login/onboarding doesn't swallow it. Only the latest tap is kept.
final class NotificationTapRouterProvider extends $NotifierProvider<NotificationTapRouter, void> {
  /// Opens what a tapped notification is about (watched by `App`): a reminder opens Settings →
  /// Reminders; a budget alert opens the Budget tab on the alert's month.
  ///
  /// Composition root (like `app.dart`), because it needs both the router and a feature's
  /// controller. A tap that launched the app is held until the user is signed in and onboarded,
  /// so the redirect to splash/login/onboarding doesn't swallow it. Only the latest tap is kept.
  NotificationTapRouterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationTapRouterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationTapRouterHash();

  @$internal
  @override
  NotificationTapRouter create() => NotificationTapRouter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$notificationTapRouterHash() => r'6eba5af8679e18cd3c528a517de6d307584f471f';

/// Opens what a tapped notification is about (watched by `App`): a reminder opens Settings →
/// Reminders; a budget alert opens the Budget tab on the alert's month.
///
/// Composition root (like `app.dart`), because it needs both the router and a feature's
/// controller. A tap that launched the app is held until the user is signed in and onboarded,
/// so the redirect to splash/login/onboarding doesn't swallow it. Only the latest tap is kept.

abstract class _$NotificationTapRouter extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element as $ClassProviderElement<AnyNotifier<void, void>, void, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
