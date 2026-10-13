// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lock_settings_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The signed-in user's app lock settings on this device, kept up to date after every change.
/// The security feature's entry point for Settings (ARCHITECTURE §3). Fails with the repository's
/// `AppFailure` when they can't be read.

@ProviderFor(LockSettingsController)
final lockSettingsControllerProvider = LockSettingsControllerProvider._();

/// The signed-in user's app lock settings on this device, kept up to date after every change.
/// The security feature's entry point for Settings (ARCHITECTURE §3). Fails with the repository's
/// `AppFailure` when they can't be read.
final class LockSettingsControllerProvider
    extends $AsyncNotifierProvider<LockSettingsController, LockSettings> {
  /// The signed-in user's app lock settings on this device, kept up to date after every change.
  /// The security feature's entry point for Settings (ARCHITECTURE §3). Fails with the repository's
  /// `AppFailure` when they can't be read.
  LockSettingsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lockSettingsControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lockSettingsControllerHash();

  @$internal
  @override
  LockSettingsController create() => LockSettingsController();
}

String _$lockSettingsControllerHash() => r'f3e6294055c40f256ae8fa7944cf5bca2923ec1a';

/// The signed-in user's app lock settings on this device, kept up to date after every change.
/// The security feature's entry point for Settings (ARCHITECTURE §3). Fails with the repository's
/// `AppFailure` when they can't be read.

abstract class _$LockSettingsController extends $AsyncNotifier<LockSettings> {
  FutureOr<LockSettings> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<LockSettings>, LockSettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<LockSettings>, LockSettings>,
              AsyncValue<LockSettings>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Whether this phone can unlock with an enrolled face or fingerprint.

@ProviderFor(biometricsAvailable)
final biometricsAvailableProvider = BiometricsAvailableProvider._();

/// Whether this phone can unlock with an enrolled face or fingerprint.

final class BiometricsAvailableProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Whether this phone can unlock with an enrolled face or fingerprint.
  BiometricsAvailableProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'biometricsAvailableProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$biometricsAvailableHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return biometricsAvailable(ref);
  }
}

String _$biometricsAvailableHash() => r'efda0f4fe7b0af01dbddb60cf0f9651829b43cc7';
