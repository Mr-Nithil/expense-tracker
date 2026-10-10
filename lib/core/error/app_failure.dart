/// A failure returned by a repository instead of throwing (ARCHITECTURE §8).
///
/// [message] is a developer message for logs. It is never shown to users. Presentation maps a
/// failure to a localized message with `failure.toL10n(context)`.
sealed class AppFailure {
  const AppFailure(this.message);

  final String message;

  @override
  String toString() => '$runtimeType($message)';
}

/// Input failed validation. [field] names the invalid input (e.g. `amount`).
final class ValidationFailure extends AppFailure {
  const ValidationFailure(super.message, {required this.field});

  final String field;
}

/// The requested record does not exist (or is soft-deleted).
final class NotFoundFailure extends AppFailure {
  const NotFoundFailure(super.message);
}

/// Authentication failed or the session is missing.
final class AuthFailure extends AppFailure {
  const AuthFailure(super.message);
}

/// The network is unavailable or a remote call failed.
final class NetworkFailure extends AppFailure {
  const NetworkFailure(super.message);
}

/// Reading or writing local storage failed.
final class StorageFailure extends AppFailure {
  const StorageFailure(super.message);
}

/// Anything else. [cause] keeps the original error for logging.
final class UnexpectedFailure extends AppFailure {
  const UnexpectedFailure(super.message, {this.cause});

  final Object? cause;
}
