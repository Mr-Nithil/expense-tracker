/// The result of a biometric prompt.
enum BiometricOutcome {
  success,

  /// The user closed the prompt (or the system did, e.g. the app went to the background).
  cancelled,

  /// Not recognized.
  failed,

  /// No biometric hardware, nothing enrolled, or the hardware is busy.
  unavailable,

  /// Too many attempts: the system blocks biometrics for a while.
  lockedOut,
}

/// Face / fingerprint authentication (ARCHITECTURE §11). Features use it through
/// `biometricServiceProvider`, never `local_auth` directly.
abstract interface class BiometricService {
  /// Whether this device can authenticate with an enrolled face or fingerprint.
  Future<bool> isAvailable();

  /// Shows the system prompt with [reason]. Biometrics only (the app PIN is the fallback).
  /// Never throws.
  Future<BiometricOutcome> authenticate({required String reason});
}
