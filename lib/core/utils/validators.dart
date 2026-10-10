/// Why a value is invalid. Presentation maps each value to an l10n message.
enum ValidationError { required, invalidEmail, passwordTooShort, passwordMismatch }

/// Shared validation rules, used by repositories (authoritative) and forms (instant feedback).
///
/// Each function returns `null` when the value is valid.
abstract final class Validators {
  static const minPasswordLength = 8;

  /// Matches the `profiles.display_name` check constraint.
  static const maxDisplayNameLength = 100;

  // Pragmatic check: something@something.tld, no spaces. The server does the real check.
  static final _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  static ValidationError? required(String? value) =>
      (value == null || value.trim().isEmpty) ? ValidationError.required : null;

  static ValidationError? email(String? value) {
    if (required(value) case final error?) return error;
    return _emailPattern.hasMatch(value!.trim()) ? null : ValidationError.invalidEmail;
  }

  static ValidationError? password(String? value) {
    if (required(value) case final error?) return error;
    return value!.length < minPasswordLength ? ValidationError.passwordTooShort : null;
  }

  /// The "confirm password" field must repeat [password] exactly.
  static ValidationError? passwordConfirmation(String password, String? confirmation) {
    if (required(confirmation) case final error?) return error;
    return confirmation == password ? null : ValidationError.passwordMismatch;
  }
}
