// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Onboarding state: idle/success (`AsyncData`), saving (`AsyncLoading`) or the `AppFailure` of
/// the last attempt (`AsyncError`).
///
/// Never navigates: once the profile has a currency, the router's onboarding gate leaves.

@ProviderFor(OnboardingController)
final onboardingControllerProvider = OnboardingControllerProvider._();

/// Onboarding state: idle/success (`AsyncData`), saving (`AsyncLoading`) or the `AppFailure` of
/// the last attempt (`AsyncError`).
///
/// Never navigates: once the profile has a currency, the router's onboarding gate leaves.
final class OnboardingControllerProvider
    extends $AsyncNotifierProvider<OnboardingController, void> {
  /// Onboarding state: idle/success (`AsyncData`), saving (`AsyncLoading`) or the `AppFailure` of
  /// the last attempt (`AsyncError`).
  ///
  /// Never navigates: once the profile has a currency, the router's onboarding gate leaves.
  OnboardingControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingControllerHash();

  @$internal
  @override
  OnboardingController create() => OnboardingController();
}

String _$onboardingControllerHash() => r'3805b86ae7051fac6c45257089b2716b483cfc0c';

/// Onboarding state: idle/success (`AsyncData`), saving (`AsyncLoading`) or the `AppFailure` of
/// the last attempt (`AsyncError`).
///
/// Never navigates: once the profile has a currency, the router's onboarding gate leaves.

abstract class _$OnboardingController extends $AsyncNotifier<void> {
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
