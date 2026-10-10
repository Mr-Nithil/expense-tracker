import 'package:expense_tracker/features/auth/domain/entities/auth_user.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_snapshot.freezed.dart';

/// The auth state at one point in time.
@freezed
abstract class AuthSnapshot with _$AuthSnapshot {
  const factory AuthSnapshot({
    /// The signed-in user, or `null` when signed out.
    AuthUser? user,

    /// Signed in through a password-reset link: the user must set a new password before entering
    /// the app. Stays true across token refreshes until the password is updated or the user signs
    /// out. In memory only, so it does not survive an app restart.
    @Default(false) bool isPasswordRecovery,
  }) = _AuthSnapshot;
}
