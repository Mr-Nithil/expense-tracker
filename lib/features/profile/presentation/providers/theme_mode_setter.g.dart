// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_mode_setter.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Saves the theme preference on the profile (synced to the user's other devices). The profile
/// feature's entry point for Settings (ARCHITECTURE §3). Kept alive because it is used from
/// callbacks.

@ProviderFor(ThemeModeSetter)
final themeModeSetterProvider = ThemeModeSetterProvider._();

/// Saves the theme preference on the profile (synced to the user's other devices). The profile
/// feature's entry point for Settings (ARCHITECTURE §3). Kept alive because it is used from
/// callbacks.
final class ThemeModeSetterProvider extends $NotifierProvider<ThemeModeSetter, void> {
  /// Saves the theme preference on the profile (synced to the user's other devices). The profile
  /// feature's entry point for Settings (ARCHITECTURE §3). Kept alive because it is used from
  /// callbacks.
  ThemeModeSetterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themeModeSetterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themeModeSetterHash();

  @$internal
  @override
  ThemeModeSetter create() => ThemeModeSetter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$themeModeSetterHash() => r'3b3ee0661d5938db8f788b54c3b29fdf76a909c7';

/// Saves the theme preference on the profile (synced to the user's other devices). The profile
/// feature's entry point for Settings (ARCHITECTURE §3). Kept alive because it is used from
/// callbacks.

abstract class _$ThemeModeSetter extends $Notifier<void> {
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
