// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_lock_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether the app is locked right now (M7.4).
///
/// Locks on a cold start when a PIN is set, and when the app comes back after being hidden for at
/// least the chosen timeout ("Immediately" = every time). Hide/show (not inactive) is used, so a
/// biometric prompt or the notification shade never locks it. Fails closed: settings that can't
/// be read keep it locked (recovery still works). Only a correct PIN or biometrics unlock it;
/// turning the PIN off (Settings or recovery) unlocks too.

@ProviderFor(AppLockController)
final appLockControllerProvider = AppLockControllerProvider._();

/// Whether the app is locked right now (M7.4).
///
/// Locks on a cold start when a PIN is set, and when the app comes back after being hidden for at
/// least the chosen timeout ("Immediately" = every time). Hide/show (not inactive) is used, so a
/// biometric prompt or the notification shade never locks it. Fails closed: settings that can't
/// be read keep it locked (recovery still works). Only a correct PIN or biometrics unlock it;
/// turning the PIN off (Settings or recovery) unlocks too.
final class AppLockControllerProvider extends $NotifierProvider<AppLockController, AppLockStatus> {
  /// Whether the app is locked right now (M7.4).
  ///
  /// Locks on a cold start when a PIN is set, and when the app comes back after being hidden for at
  /// least the chosen timeout ("Immediately" = every time). Hide/show (not inactive) is used, so a
  /// biometric prompt or the notification shade never locks it. Fails closed: settings that can't
  /// be read keep it locked (recovery still works). Only a correct PIN or biometrics unlock it;
  /// turning the PIN off (Settings or recovery) unlocks too.
  AppLockControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appLockControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appLockControllerHash();

  @$internal
  @override
  AppLockController create() => AppLockController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppLockStatus value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppLockStatus>(value),
    );
  }
}

String _$appLockControllerHash() => r'4c0da8ff979f45f7bddc423d9709326596078018';

/// Whether the app is locked right now (M7.4).
///
/// Locks on a cold start when a PIN is set, and when the app comes back after being hidden for at
/// least the chosen timeout ("Immediately" = every time). Hide/show (not inactive) is used, so a
/// biometric prompt or the notification shade never locks it. Fails closed: settings that can't
/// be read keep it locked (recovery still works). Only a correct PIN or biometrics unlock it;
/// turning the PIN off (Settings or recovery) unlocks too.

abstract class _$AppLockController extends $Notifier<AppLockStatus> {
  AppLockStatus build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AppLockStatus, AppLockStatus>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AppLockStatus, AppLockStatus>,
              AppLockStatus,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
