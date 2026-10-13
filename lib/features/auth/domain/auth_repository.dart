import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/features/auth/domain/entities/auth_snapshot.dart';
import 'package:expense_tracker/features/auth/domain/entities/auth_user.dart';
import 'package:expense_tracker/features/auth/domain/entities/sign_up_outcome.dart';

/// Authentication. The only auth entry point for the rest of the app.
///
/// Write methods validate input, never throw, and return [Result] with an `AuthFailure`,
/// `NetworkFailure` or `ValidationFailure` on error.
abstract interface class AuthRepository {
  /// Emits on sign-in, refresh, sign-out and password recovery (repeats are dropped).
  Stream<AuthSnapshot> authStateChanges();

  /// Problems with an opened email link (confirmation or reset): an `AuthFailure` with reason
  /// `linkExpired` or `linkInvalid`. Other auth stream errors (e.g. an offline refresh) are not
  /// included.
  Stream<AuthFailure> authLinkErrors();

  /// The user from the persisted session, available offline. `null` when signed out.
  AuthUser? get currentUser;

  Future<Result<AuthUser>> signIn({required String email, required String password});

  Future<Result<SignUpOutcome>> signUp({
    required String email,
    required String password,
    String? displayName,
  });

  /// Clears the local session even when offline.
  Future<Result<void>> signOut();

  Future<Result<void>> sendPasswordReset({required String email});

  /// Sends the sign-up confirmation email again (e.g. after the first link expired).
  Future<Result<void>> resendConfirmation({required String email});

  /// Sets a new password for the signed-in user (after opening a reset link). Ends recovery.
  Future<Result<void>> updatePassword({required String newPassword});

  /// Checks [password] against the signed-in account by signing in again with its email (needs a
  /// connection). Keeps the session and all local data. For PIN recovery (M7.7).
  Future<Result<void>> confirmPassword(String password);
}
