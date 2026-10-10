// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locale_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The app locale. `null` follows the device. Persisted and synced in M9.3.

@ProviderFor(LocaleController)
final localeControllerProvider = LocaleControllerProvider._();

/// The app locale. `null` follows the device. Persisted and synced in M9.3.
final class LocaleControllerProvider extends $NotifierProvider<LocaleController, Locale?> {
  /// The app locale. `null` follows the device. Persisted and synced in M9.3.
  LocaleControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localeControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localeControllerHash();

  @$internal
  @override
  LocaleController create() => LocaleController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Locale? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Locale?>(value),
    );
  }
}

String _$localeControllerHash() => r'e4d0fa49dd5ce82781813ee90666612f088cf486';

/// The app locale. `null` follows the device. Persisted and synced in M9.3.

abstract class _$LocaleController extends $Notifier<Locale?> {
  Locale? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Locale?, Locale?>;
    final element =
        ref.element
            as $ClassProviderElement<AnyNotifier<Locale?, Locale?>, Locale?, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
