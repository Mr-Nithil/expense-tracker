// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_status.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The session state the router redirects on.
///
/// Lives in core so the router does not import a feature. The auth feature drives it via
/// [AuthStatusController.set] (`authStatusBindingProvider`).

@ProviderFor(AuthStatusController)
final authStatusControllerProvider = AuthStatusControllerProvider._();

/// The session state the router redirects on.
///
/// Lives in core so the router does not import a feature. The auth feature drives it via
/// [AuthStatusController.set] (`authStatusBindingProvider`).
final class AuthStatusControllerProvider
    extends $NotifierProvider<AuthStatusController, AuthStatus> {
  /// The session state the router redirects on.
  ///
  /// Lives in core so the router does not import a feature. The auth feature drives it via
  /// [AuthStatusController.set] (`authStatusBindingProvider`).
  AuthStatusControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authStatusControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authStatusControllerHash();

  @$internal
  @override
  AuthStatusController create() => AuthStatusController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthStatus value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthStatus>(value),
    );
  }
}

String _$authStatusControllerHash() => r'423349a7c0b23fc8f58bf51c378baff3e912fa90';

/// The session state the router redirects on.
///
/// Lives in core so the router does not import a feature. The auth feature drives it via
/// [AuthStatusController.set] (`authStatusBindingProvider`).

abstract class _$AuthStatusController extends $Notifier<AuthStatus> {
  AuthStatus build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AuthStatus, AuthStatus>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AuthStatus, AuthStatus>,
              AuthStatus,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
