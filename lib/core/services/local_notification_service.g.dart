// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_notification_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(notificationService)
final notificationServiceProvider = NotificationServiceProvider._();

final class NotificationServiceProvider
    extends $FunctionalProvider<NotificationService, NotificationService, NotificationService>
    with $Provider<NotificationService> {
  NotificationServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationServiceHash();

  @$internal
  @override
  $ProviderElement<NotificationService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotificationService create(Ref ref) {
    return notificationService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationService>(value),
    );
  }
}

String _$notificationServiceHash() => r'426c0d018ccdaf957148c03b10466f7bee3dacac';

/// Sets notifications up once for the app's lifetime (watched by `App`). Channel names follow
/// the app language. Failures are logged, never fatal: the app works without notifications.

@ProviderFor(notificationSetup)
final notificationSetupProvider = NotificationSetupProvider._();

/// Sets notifications up once for the app's lifetime (watched by `App`). Channel names follow
/// the app language. Failures are logged, never fatal: the app works without notifications.

final class NotificationSetupProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// Sets notifications up once for the app's lifetime (watched by `App`). Channel names follow
  /// the app language. Failures are logged, never fatal: the app works without notifications.
  NotificationSetupProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationSetupProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationSetupHash();

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    return notificationSetup(ref);
  }
}

String _$notificationSetupHash() => r'27d5ccc8d3f9a428582f6ff056367c0d5ce2498f';
