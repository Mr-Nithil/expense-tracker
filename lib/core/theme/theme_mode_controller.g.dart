// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_mode_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The user's theme mode, persisted locally in `app_settings`.
///
/// Synced to the profile later (TASKS M3.10). Until the stored value loads, the app follows the
/// system setting.

@ProviderFor(ThemeModeController)
final themeModeControllerProvider = ThemeModeControllerProvider._();

/// The user's theme mode, persisted locally in `app_settings`.
///
/// Synced to the profile later (TASKS M3.10). Until the stored value loads, the app follows the
/// system setting.
final class ThemeModeControllerProvider
    extends $StreamNotifierProvider<ThemeModeController, ThemeMode> {
  /// The user's theme mode, persisted locally in `app_settings`.
  ///
  /// Synced to the profile later (TASKS M3.10). Until the stored value loads, the app follows the
  /// system setting.
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

String _$themeModeControllerHash() => r'31e9f4eba0f124a6a115c42691fd53bf2daa07e1';

/// The user's theme mode, persisted locally in `app_settings`.
///
/// Synced to the profile later (TASKS M3.10). Until the stored value loads, the app follows the
/// system setting.

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
