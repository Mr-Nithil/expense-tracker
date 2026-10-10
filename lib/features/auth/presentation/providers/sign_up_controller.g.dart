// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sign_up_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Sign-up form state: idle (`AsyncData(null)`), submitting (`AsyncLoading`), the outcome of a
/// successful sign-up (`AsyncData(outcome)`), or the `AppFailure` of the last attempt.
///
/// Never navigates. On [SignUpOutcome.signedIn] the router redirect leaves the screen; the screen
/// handles [SignUpOutcome.emailConfirmationRequired].

@ProviderFor(SignUpController)
final signUpControllerProvider = SignUpControllerProvider._();

/// Sign-up form state: idle (`AsyncData(null)`), submitting (`AsyncLoading`), the outcome of a
/// successful sign-up (`AsyncData(outcome)`), or the `AppFailure` of the last attempt.
///
/// Never navigates. On [SignUpOutcome.signedIn] the router redirect leaves the screen; the screen
/// handles [SignUpOutcome.emailConfirmationRequired].
final class SignUpControllerProvider
    extends $AsyncNotifierProvider<SignUpController, SignUpOutcome?> {
  /// Sign-up form state: idle (`AsyncData(null)`), submitting (`AsyncLoading`), the outcome of a
  /// successful sign-up (`AsyncData(outcome)`), or the `AppFailure` of the last attempt.
  ///
  /// Never navigates. On [SignUpOutcome.signedIn] the router redirect leaves the screen; the screen
  /// handles [SignUpOutcome.emailConfirmationRequired].
  SignUpControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'signUpControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$signUpControllerHash();

  @$internal
  @override
  SignUpController create() => SignUpController();
}

String _$signUpControllerHash() => r'5837fea44673d5315b74924863323f52b779fc28';

/// Sign-up form state: idle (`AsyncData(null)`), submitting (`AsyncLoading`), the outcome of a
/// successful sign-up (`AsyncData(outcome)`), or the `AppFailure` of the last attempt.
///
/// Never navigates. On [SignUpOutcome.signedIn] the router redirect leaves the screen; the screen
/// handles [SignUpOutcome.emailConfirmationRequired].

abstract class _$SignUpController extends $AsyncNotifier<SignUpOutcome?> {
  FutureOr<SignUpOutcome?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<SignUpOutcome?>, SignUpOutcome?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<SignUpOutcome?>, SignUpOutcome?>,
              AsyncValue<SignUpOutcome?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
