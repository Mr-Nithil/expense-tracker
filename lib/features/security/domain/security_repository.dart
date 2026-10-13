import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/features/security/domain/entities/lock_settings.dart';

/// The app lock on this device: PIN (stored only as a salted hash), biometrics and timeout.
/// Device-only, never synced; belongs to the signed-in user (another user's settings are ignored).
///
/// Writes fail with an `AuthFailure` without a session and a `StorageFailure` when secure storage
/// fails.
abstract interface class SecurityRepository {
  /// The signed-in user's settings; defaults (no PIN) when none are stored.
  Future<Result<LockSettings>> load();

  /// Turns the lock on with [pin], or changes the PIN. A `ValidationFailure` (`pinInvalid`) unless
  /// it has 4–6 digits.
  Future<Result<LockSettings>> setPin(String pin);

  /// Whether [pin] is the stored PIN (`false` without a PIN).
  Future<Result<bool>> verifyPin(String pin);

  /// Turns the lock off (also biometrics).
  Future<Result<LockSettings>> removePin();

  /// Biometric unlock in addition to the PIN. A `ValidationFailure` (`pinRequired`) without a PIN.
  Future<Result<LockSettings>> setBiometricsEnabled({required bool enabled});

  Future<Result<LockSettings>> setTimeout(LockTimeout timeout);
}
