// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forgot_password_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Forgot-password state: idle (`AsyncData(null)`), sending (`AsyncLoading`), sent
/// (`AsyncData(email)`, the address the link went to), or the `AppFailure` of the last attempt.

@ProviderFor(ForgotPasswordController)
final forgotPasswordControllerProvider = ForgotPasswordControllerProvider._();

/// Forgot-password state: idle (`AsyncData(null)`), sending (`AsyncLoading`), sent
/// (`AsyncData(email)`, the address the link went to), or the `AppFailure` of the last attempt.
final class ForgotPasswordControllerProvider
    extends $AsyncNotifierProvider<ForgotPasswordController, String?> {
  /// Forgot-password state: idle (`AsyncData(null)`), sending (`AsyncLoading`), sent
  /// (`AsyncData(email)`, the address the link went to), or the `AppFailure` of the last attempt.
  ForgotPasswordControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'forgotPasswordControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$forgotPasswordControllerHash();

  @$internal
  @override
  ForgotPasswordController create() => ForgotPasswordController();
}

String _$forgotPasswordControllerHash() => r'2be2633094dae7596157e7dd4b052a77eed4b823';

/// Forgot-password state: idle (`AsyncData(null)`), sending (`AsyncLoading`), sent
/// (`AsyncData(email)`, the address the link went to), or the `AppFailure` of the last attempt.

abstract class _$ForgotPasswordController extends $AsyncNotifier<String?> {
  FutureOr<String?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<String?>, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<String?>, String?>,
              AsyncValue<String?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
