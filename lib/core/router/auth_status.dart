import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_status.g.dart';

enum AuthStatus {
  /// The session is still being restored.
  unknown,
  signedOut,
  signedIn,

  /// Signed in through a password-reset link: must set a new password before entering the app.
  passwordRecovery,
}

/// The session state the router redirects on.
///
/// Lives in core so the router does not import a feature. The auth feature drives it via
/// [AuthStatusController.set] (`authStatusBindingProvider`).
@Riverpod(keepAlive: true)
class AuthStatusController extends _$AuthStatusController {
  @override
  AuthStatus build() => AuthStatus.unknown;

  void set(AuthStatus status) => state = status;
}
