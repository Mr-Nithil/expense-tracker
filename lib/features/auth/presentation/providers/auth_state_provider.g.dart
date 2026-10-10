// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_state_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The auth state: the signed-in user (or `null`) and whether a password reset is in progress.
///
/// Starts with the session restored from local storage (no network needed, ARCHITECTURE §10),
/// then follows sign-in, sign-out and token refresh events.
///
/// Never retried: the Supabase stream keeps running after an error (e.g. a refresh failing
/// offline), so rebuilding would only re-subscribe for nothing.

@ProviderFor(authState)
final authStateProvider = AuthStateProvider._();

/// The auth state: the signed-in user (or `null`) and whether a password reset is in progress.
///
/// Starts with the session restored from local storage (no network needed, ARCHITECTURE §10),
/// then follows sign-in, sign-out and token refresh events.
///
/// Never retried: the Supabase stream keeps running after an error (e.g. a refresh failing
/// offline), so rebuilding would only re-subscribe for nothing.

final class AuthStateProvider
    extends $FunctionalProvider<AsyncValue<AuthSnapshot>, AuthSnapshot, Stream<AuthSnapshot>>
    with $FutureModifier<AuthSnapshot>, $StreamProvider<AuthSnapshot> {
  /// The auth state: the signed-in user (or `null`) and whether a password reset is in progress.
  ///
  /// Starts with the session restored from local storage (no network needed, ARCHITECTURE §10),
  /// then follows sign-in, sign-out and token refresh events.
  ///
  /// Never retried: the Supabase stream keeps running after an error (e.g. a refresh failing
  /// offline), so rebuilding would only re-subscribe for nothing.
  AuthStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: _noRetry,
        name: r'authStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authStateHash();

  @$internal
  @override
  $StreamProviderElement<AuthSnapshot> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<AuthSnapshot> create(Ref ref) {
    return authState(ref);
  }
}

String _$authStateHash() => r'cff453c2b9620f7eb2fa5a20fad93e46e4982d21';

/// Problems with opened email links (expired, used, other device), for the app-wide
/// `AuthLinkErrorListener`. Supabase replays earlier errors to new subscribers, so a link that
/// failed during startup is still reported.

@ProviderFor(authLinkErrors)
final authLinkErrorsProvider = AuthLinkErrorsProvider._();

/// Problems with opened email links (expired, used, other device), for the app-wide
/// `AuthLinkErrorListener`. Supabase replays earlier errors to new subscribers, so a link that
/// failed during startup is still reported.

final class AuthLinkErrorsProvider
    extends $FunctionalProvider<AsyncValue<AuthFailure>, AuthFailure, Stream<AuthFailure>>
    with $FutureModifier<AuthFailure>, $StreamProvider<AuthFailure> {
  /// Problems with opened email links (expired, used, other device), for the app-wide
  /// `AuthLinkErrorListener`. Supabase replays earlier errors to new subscribers, so a link that
  /// failed during startup is still reported.
  AuthLinkErrorsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authLinkErrorsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authLinkErrorsHash();

  @$internal
  @override
  $StreamProviderElement<AuthFailure> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<AuthFailure> create(Ref ref) {
    return authLinkErrors(ref);
  }
}

String _$authLinkErrorsHash() => r'3bec2897b6ac3c16ba310fd21c62e1454be81c7c';

/// Drives core's [Session] and the router's [AuthStatusController] from [authStateProvider].
///
/// Must be kept alive by the app (see `App`). Stream errors keep the last known status, so a
/// failed token refresh while offline does not sign the user out.
///
/// On every sign-in the local data is claimed for that user first (`LocalDataRepository`); the
/// status stays `unknown` (splash) until then, so no screen shows another user's data.

@ProviderFor(authStatusBinding)
final authStatusBindingProvider = AuthStatusBindingProvider._();

/// Drives core's [Session] and the router's [AuthStatusController] from [authStateProvider].
///
/// Must be kept alive by the app (see `App`). Stream errors keep the last known status, so a
/// failed token refresh while offline does not sign the user out.
///
/// On every sign-in the local data is claimed for that user first (`LocalDataRepository`); the
/// status stays `unknown` (splash) until then, so no screen shows another user's data.

final class AuthStatusBindingProvider extends $FunctionalProvider<void, void, void>
    with $Provider<void> {
  /// Drives core's [Session] and the router's [AuthStatusController] from [authStateProvider].
  ///
  /// Must be kept alive by the app (see `App`). Stream errors keep the last known status, so a
  /// failed token refresh while offline does not sign the user out.
  ///
  /// On every sign-in the local data is claimed for that user first (`LocalDataRepository`); the
  /// status stays `unknown` (splash) until then, so no screen shows another user's data.
  AuthStatusBindingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authStatusBindingProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authStatusBindingHash();

  @$internal
  @override
  $ProviderElement<void> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  void create(Ref ref) {
    return authStatusBinding(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$authStatusBindingHash() => r'8a59250fb93a07ca46e773c12e0f4069e1983e60';
