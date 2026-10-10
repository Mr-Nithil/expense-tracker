// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Login form state: idle/success (`AsyncData`), submitting (`AsyncLoading`) or the
/// `AppFailure` of the last attempt (`AsyncError`).
///
/// Never navigates: on success the session changes and the router redirect leaves `/login`.

@ProviderFor(LoginController)
final loginControllerProvider = LoginControllerProvider._();

/// Login form state: idle/success (`AsyncData`), submitting (`AsyncLoading`) or the
/// `AppFailure` of the last attempt (`AsyncError`).
///
/// Never navigates: on success the session changes and the router redirect leaves `/login`.
final class LoginControllerProvider extends $AsyncNotifierProvider<LoginController, void> {
  /// Login form state: idle/success (`AsyncData`), submitting (`AsyncLoading`) or the
  /// `AppFailure` of the last attempt (`AsyncError`).
  ///
  /// Never navigates: on success the session changes and the router redirect leaves `/login`.
  LoginControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loginControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loginControllerHash();

  @$internal
  @override
  LoginController create() => LoginController();
}

String _$loginControllerHash() => r'e8820080579ba2abb8f287c01ff5e2e64cbdd58c';

/// Login form state: idle/success (`AsyncData`), submitting (`AsyncLoading`) or the
/// `AppFailure` of the last attempt (`AsyncError`).
///
/// Never navigates: on success the session changes and the router redirect leaves `/login`.

abstract class _$LoginController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
