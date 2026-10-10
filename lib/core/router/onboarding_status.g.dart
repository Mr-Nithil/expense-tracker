// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_status.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether the signed-in user has finished onboarding, read from the local profile.
///
/// Lives in core (like `AuthStatusController`) so the router does not import the profile feature.
/// Until the initial pull on login exists (M3.8), a second device sees onboarding again.

@ProviderFor(onboardingStatus)
final onboardingStatusProvider = OnboardingStatusProvider._();

/// Whether the signed-in user has finished onboarding, read from the local profile.
///
/// Lives in core (like `AuthStatusController`) so the router does not import the profile feature.
/// Until the initial pull on login exists (M3.8), a second device sees onboarding again.

final class OnboardingStatusProvider
    extends
        $FunctionalProvider<
          AsyncValue<OnboardingStatus>,
          OnboardingStatus,
          Stream<OnboardingStatus>
        >
    with $FutureModifier<OnboardingStatus>, $StreamProvider<OnboardingStatus> {
  /// Whether the signed-in user has finished onboarding, read from the local profile.
  ///
  /// Lives in core (like `AuthStatusController`) so the router does not import the profile feature.
  /// Until the initial pull on login exists (M3.8), a second device sees onboarding again.
  OnboardingStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingStatusProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingStatusHash();

  @$internal
  @override
  $StreamProviderElement<OnboardingStatus> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<OnboardingStatus> create(Ref ref) {
    return onboardingStatus(ref);
  }
}

String _$onboardingStatusHash() => r'd0679f168bf65852ea7d33c70cace6e39987d15d';
