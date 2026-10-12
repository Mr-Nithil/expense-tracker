// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locale_setter.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Saves the app language on the profile (synced to the user's other devices); `null` follows
/// the device. The profile feature's entry point for Settings (ARCHITECTURE §3). Kept alive
/// because it is used from callbacks.

@ProviderFor(LocaleSetter)
final localeSetterProvider = LocaleSetterProvider._();

/// Saves the app language on the profile (synced to the user's other devices); `null` follows
/// the device. The profile feature's entry point for Settings (ARCHITECTURE §3). Kept alive
/// because it is used from callbacks.
final class LocaleSetterProvider extends $NotifierProvider<LocaleSetter, void> {
  /// Saves the app language on the profile (synced to the user's other devices); `null` follows
  /// the device. The profile feature's entry point for Settings (ARCHITECTURE §3). Kept alive
  /// because it is used from callbacks.
  LocaleSetterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localeSetterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localeSetterHash();

  @$internal
  @override
  LocaleSetter create() => LocaleSetter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$localeSetterHash() => r'da8359f00b5e36d64c9d2468627927f45f68ae59';

/// Saves the app language on the profile (synced to the user's other devices); `null` follows
/// the device. The profile feature's entry point for Settings (ARCHITECTURE §3). Kept alive
/// because it is used from callbacks.

abstract class _$LocaleSetter extends $Notifier<void> {
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
