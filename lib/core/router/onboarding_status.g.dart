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
/// Without a local currency it waits for the initial pull (M3.8): a second device then downloads
/// the profile instead of asking for the currency again. A failed pull falls back to onboarding.

@ProviderFor(onboardingStatus)
final onboardingStatusProvider = OnboardingStatusProvider._();

/// Whether the signed-in user has finished onboarding, read from the local profile.
///
/// Lives in core (like `AuthStatusController`) so the router does not import the profile feature.
/// Without a local currency it waits for the initial pull (M3.8): a second device then downloads
/// the profile instead of asking for the currency again. A failed pull falls back to onboarding.

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
  /// Without a local currency it waits for the initial pull (M3.8): a second device then downloads
  /// the profile instead of asking for the currency again. A failed pull falls back to onboarding.
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

String _$onboardingStatusHash() => r'f583af7c559294221fb3a7b7e2f567bd0809bfaf';
