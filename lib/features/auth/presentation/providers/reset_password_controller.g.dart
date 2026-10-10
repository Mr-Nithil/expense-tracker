// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reset_password_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Set-new-password state (after opening a reset link): idle/success (`AsyncData`), saving
/// (`AsyncLoading`) or the `AppFailure` of the last attempt.
///
/// Never navigates: saving ends recovery (and [cancel] signs out), and the router redirect leaves.

@ProviderFor(ResetPasswordController)
final resetPasswordControllerProvider = ResetPasswordControllerProvider._();

/// Set-new-password state (after opening a reset link): idle/success (`AsyncData`), saving
/// (`AsyncLoading`) or the `AppFailure` of the last attempt.
///
/// Never navigates: saving ends recovery (and [cancel] signs out), and the router redirect leaves.
final class ResetPasswordControllerProvider
    extends $AsyncNotifierProvider<ResetPasswordController, void> {
  /// Set-new-password state (after opening a reset link): idle/success (`AsyncData`), saving
  /// (`AsyncLoading`) or the `AppFailure` of the last attempt.
  ///
  /// Never navigates: saving ends recovery (and [cancel] signs out), and the router redirect leaves.
  ResetPasswordControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'resetPasswordControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$resetPasswordControllerHash();

  @$internal
  @override
  ResetPasswordController create() => ResetPasswordController();
}

String _$resetPasswordControllerHash() => r'b4941117e201047abbd2a4065f78c297ba72f4c1';

/// Set-new-password state (after opening a reset link): idle/success (`AsyncData`), saving
/// (`AsyncLoading`) or the `AppFailure` of the last attempt.
///
/// Never navigates: saving ends recovery (and [cancel] signs out), and the router redirect leaves.

abstract class _$ResetPasswordController extends $AsyncNotifier<void> {
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
