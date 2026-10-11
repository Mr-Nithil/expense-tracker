// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The signed-in user's profile. Re-subscribes when the user changes.

@ProviderFor(profile)
final profileProvider = ProfileProvider._();

/// The signed-in user's profile. Re-subscribes when the user changes.

final class ProfileProvider
    extends $FunctionalProvider<AsyncValue<Profile?>, Profile?, Stream<Profile?>>
    with $FutureModifier<Profile?>, $StreamProvider<Profile?> {
  /// The signed-in user's profile. Re-subscribes when the user changes.
  ProfileProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileHash();

  @$internal
  @override
  $StreamProviderElement<Profile?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Profile?> create(Ref ref) {
    return profile(ref);
  }
}

String _$profileHash() => r'666477a60afb9ff2aeabb8c8a95cdeb79977139e';

/// The user's one currency (ISO 4217). Always set behind the onboarding gate; the fallback is
/// only a safety net. A future, so forms wait for the real currency before formatting amounts.

@ProviderFor(currencyCode)
final currencyCodeProvider = CurrencyCodeProvider._();

/// The user's one currency (ISO 4217). Always set behind the onboarding gate; the fallback is
/// only a safety net. A future, so forms wait for the real currency before formatting amounts.

final class CurrencyCodeProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  /// The user's one currency (ISO 4217). Always set behind the onboarding gate; the fallback is
  /// only a safety net. A future, so forms wait for the real currency before formatting amounts.
  CurrencyCodeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currencyCodeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currencyCodeHash();

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    return currencyCode(ref);
  }
}

String _$currencyCodeHash() => r'416dad19119a0e1375c530b85f2243e6f0c5ef42';
