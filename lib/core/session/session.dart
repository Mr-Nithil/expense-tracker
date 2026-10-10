import 'package:meta/meta.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'session.g.dart';

/// The signed-in user as far as core and repositories need to know.
@immutable
class SessionUser {
  const SessionUser({required this.userId, this.displayName});

  final String userId;
  final String? displayName;

  @override
  bool operator ==(Object other) =>
      other is SessionUser && other.userId == userId && other.displayName == displayName;

  @override
  int get hashCode => Object.hash(userId, displayName);

  @override
  String toString() => 'SessionUser($userId)';
}

/// The current session (`null` when signed out). Repositories read it to set `user_id`.
///
/// Lives in core so features never import auth internals. The auth feature drives it via [set]
/// (`authStatusBindingProvider`), before updating the router's auth status.
@Riverpod(keepAlive: true)
class Session extends _$Session {
  @override
  SessionUser? build() => null;

  void set(SessionUser? user) => state = user;

  /// The signed-in user, or `null`. For non-reactive reads (repositories); widgets and providers
  /// watch [sessionProvider] instead.
  SessionUser? get currentUser => state;

  /// The signed-in user. Throws [StateError] when signed out: call it inside the repository's
  /// try/catch and map the error to an `AuthFailure`.
  SessionUser requireUser() => currentUser ?? (throw StateError('No signed-in user'));

  /// Shortcut for `requireUser().userId`.
  String requireUserId() => requireUser().userId;
}
