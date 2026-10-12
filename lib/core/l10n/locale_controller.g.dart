// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locale_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The app language: the signed-in user's profile `locale` (synced, so it follows the user to
/// other devices), or `null` to follow the device (signed out, not chosen, or not supported).
///
/// Read-only: the language is changed through the profile repository (the single write path).

@ProviderFor(LocaleController)
final localeControllerProvider = LocaleControllerProvider._();

/// The app language: the signed-in user's profile `locale` (synced, so it follows the user to
/// other devices), or `null` to follow the device (signed out, not chosen, or not supported).
///
/// Read-only: the language is changed through the profile repository (the single write path).
final class LocaleControllerProvider extends $StreamNotifierProvider<LocaleController, Locale?> {
  /// The app language: the signed-in user's profile `locale` (synced, so it follows the user to
  /// other devices), or `null` to follow the device (signed out, not chosen, or not supported).
  ///
  /// Read-only: the language is changed through the profile repository (the single write path).
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
}

String _$localeControllerHash() => r'f4e62c05f2b9138611a801c64dfaed8c30a26caf';

/// The app language: the signed-in user's profile `locale` (synced, so it follows the user to
/// other devices), or `null` to follow the device (signed out, not chosen, or not supported).
///
/// Read-only: the language is changed through the profile repository (the single write path).

abstract class _$LocaleController extends $StreamNotifier<Locale?> {
  Stream<Locale?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Locale?>, Locale?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Locale?>, Locale?>,
              AsyncValue<Locale?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
