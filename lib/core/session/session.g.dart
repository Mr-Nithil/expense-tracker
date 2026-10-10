// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The current session (`null` when signed out). Repositories read it to set `user_id`.
///
/// Lives in core so features never import auth internals. The auth feature drives it via [set]
/// (`authStatusBindingProvider`), before updating the router's auth status.

@ProviderFor(Session)
final sessionProvider = SessionProvider._();

/// The current session (`null` when signed out). Repositories read it to set `user_id`.
///
/// Lives in core so features never import auth internals. The auth feature drives it via [set]
/// (`authStatusBindingProvider`), before updating the router's auth status.
final class SessionProvider extends $NotifierProvider<Session, SessionUser?> {
  /// The current session (`null` when signed out). Repositories read it to set `user_id`.
  ///
  /// Lives in core so features never import auth internals. The auth feature drives it via [set]
  /// (`authStatusBindingProvider`), before updating the router's auth status.
  SessionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionHash();

  @$internal
  @override
  Session create() => Session();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SessionUser? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SessionUser?>(value),
    );
  }
}

String _$sessionHash() => r'201b0bb4748ad7dcc2635d86775185999a796228';

/// The current session (`null` when signed out). Repositories read it to set `user_id`.
///
/// Lives in core so features never import auth internals. The auth feature drives it via [set]
/// (`authStatusBindingProvider`), before updating the router's auth status.

abstract class _$Session extends $Notifier<SessionUser?> {
  SessionUser? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SessionUser?, SessionUser?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SessionUser?, SessionUser?>,
              SessionUser?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
