import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_status.g.dart';

enum AuthStatus {
  /// The session is still being restored.
  unknown,
  signedOut,
  signedIn,
}

/// The session state the router redirects on.
///
/// Lives in core so the router does not import a feature. The auth feature drives it via
/// [AuthStatusController.set].
@Riverpod(keepAlive: true)
class AuthStatusController extends _$AuthStatusController {
  // TODO(M1.2): start at `unknown` and bind to the Supabase session. Until auth exists,
  // the app opens straight into the tabs.
  @override
  AuthStatus build() => AuthStatus.signedIn;

  void set(AuthStatus status) => state = status;
}
