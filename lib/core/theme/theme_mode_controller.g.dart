// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_mode_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The app theme: the signed-in user's profile `theme_mode` (synced, so it follows the user to
/// other devices), or the system setting when signed out or before the profile exists.
///
/// Read-only: the theme is changed through the profile repository (the single write path).

@ProviderFor(ThemeModeController)
final themeModeControllerProvider = ThemeModeControllerProvider._();

/// The app theme: the signed-in user's profile `theme_mode` (synced, so it follows the user to
/// other devices), or the system setting when signed out or before the profile exists.
///
/// Read-only: the theme is changed through the profile repository (the single write path).
final class ThemeModeControllerProvider
    extends $StreamNotifierProvider<ThemeModeController, ThemeMode> {
  /// The app theme: the signed-in user's profile `theme_mode` (synced, so it follows the user to
  /// other devices), or the system setting when signed out or before the profile exists.
  ///
  /// Read-only: the theme is changed through the profile repository (the single write path).
  ThemeModeControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themeModeControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themeModeControllerHash();

  @$internal
  @override
  ThemeModeController create() => ThemeModeController();
}

String _$themeModeControllerHash() => r'dca203fb9c960a467b00b70d304a3a3d61e6714e';

/// The app theme: the signed-in user's profile `theme_mode` (synced, so it follows the user to
/// other devices), or the system setting when signed out or before the profile exists.
///
/// Read-only: the theme is changed through the profile repository (the single write path).

abstract class _$ThemeModeController extends $StreamNotifier<ThemeMode> {
  Stream<ThemeMode> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<ThemeMode>, ThemeMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ThemeMode>, ThemeMode>,
              AsyncValue<ThemeMode>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
