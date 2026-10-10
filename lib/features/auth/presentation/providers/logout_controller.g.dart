// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'logout_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Logout for any screen (used by Settings; ARCHITECTURE §3, cross-feature UI).
///
/// State: idle/success (`AsyncData`), logging out (`AsyncLoading`) or the `AppFailure` of the
/// last attempt. Never navigates: the sign-out event makes the router redirect to `/login`.

@ProviderFor(LogoutController)
final logoutControllerProvider = LogoutControllerProvider._();

/// Logout for any screen (used by Settings; ARCHITECTURE §3, cross-feature UI).
///
/// State: idle/success (`AsyncData`), logging out (`AsyncLoading`) or the `AppFailure` of the
/// last attempt. Never navigates: the sign-out event makes the router redirect to `/login`.
final class LogoutControllerProvider extends $AsyncNotifierProvider<LogoutController, void> {
  /// Logout for any screen (used by Settings; ARCHITECTURE §3, cross-feature UI).
  ///
  /// State: idle/success (`AsyncData`), logging out (`AsyncLoading`) or the `AppFailure` of the
  /// last attempt. Never navigates: the sign-out event makes the router redirect to `/login`.
  LogoutControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'logoutControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$logoutControllerHash();

  @$internal
  @override
  LogoutController create() => LogoutController();
}

String _$logoutControllerHash() => r'f57f5b0189a11d8d6bde66f8597f54469be33619';

/// Logout for any screen (used by Settings; ARCHITECTURE §3, cross-feature UI).
///
/// State: idle/success (`AsyncData`), logging out (`AsyncLoading`) or the `AppFailure` of the
/// last attempt. Never navigates: the sign-out event makes the router redirect to `/login`.

abstract class _$LogoutController extends $AsyncNotifier<void> {
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
