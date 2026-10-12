import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/features/profile/domain/entities/profile.dart';

/// The signed-in user's profile, read from and written to the local DB (synced later).
abstract interface class ProfileRepository {
  /// The current user's profile, or `null` when there is no local row (or no session).
  Stream<Profile?> watchProfile();

  /// Sets the currency once (onboarding). Fails with a `ValidationFailure` for an unsupported
  /// code or when a currency is already set, and with an `AuthFailure` without a session.
  Future<Result<Profile>> setCurrency(String currencyCode);

  /// Sets the theme preference (synced, so it follows the user to other devices). Saving the
  /// current value again is a no-op. Fails with an `AuthFailure` without a session.
  Future<Result<Profile>> setThemeMode(AppThemeMode mode);

  /// Sets the app language ([languageCode], e.g. `si`; `null` follows the device). Synced, so it
  /// follows the user to other devices. Saving the current value again is a no-op. Fails with a
  /// `ValidationFailure` for a language the app doesn't support and with an `AuthFailure` without
  /// a session.
  Future<Result<Profile>> setLocale(String? languageCode);
}
