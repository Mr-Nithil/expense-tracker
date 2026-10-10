import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/l10n/generated/app_localizations.dart';
import 'package:expense_tracker/core/utils/validators.dart';
import 'package:flutter/widgets.dart';

/// The one central mapper from [AppFailure] to a user-facing message (ARCHITECTURE §8).
extension AppFailureL10n on AppFailure {
  String toL10n(BuildContext context) => localize(context.l10n);

  String localize(AppLocalizations l10n) => switch (this) {
    ValidationFailure() => l10n.errorValidation,
    NotFoundFailure() => l10n.errorNotFound,
    AuthFailure(:final reason) => switch (reason) {
      AuthFailureReason.invalidCredentials => l10n.errorAuthInvalidCredentials,
      AuthFailureReason.emailAlreadyRegistered => l10n.errorAuthEmailExists,
      AuthFailureReason.weakPassword => l10n.errorAuthWeakPassword,
      AuthFailureReason.emailNotConfirmed => l10n.errorAuthEmailNotConfirmed,
      AuthFailureReason.samePassword => l10n.errorAuthSamePassword,
      AuthFailureReason.linkExpired => l10n.errorAuthLinkExpired,
      AuthFailureReason.linkInvalid => l10n.errorAuthLinkInvalid,
      AuthFailureReason.rateLimited => l10n.errorAuthRateLimited,
      AuthFailureReason.unknown => l10n.errorAuth,
    },
    NetworkFailure() => l10n.errorNetwork,
    StorageFailure() => l10n.errorStorage,
    UnexpectedFailure() => l10n.errorUnexpected,
  };
}

/// Maps a form/repository [ValidationError] to a field error message.
extension ValidationErrorL10n on ValidationError {
  String toL10n(BuildContext context) => localize(context.l10n);

  String localize(AppLocalizations l10n) => switch (this) {
    ValidationError.required => l10n.errorFieldRequired,
    ValidationError.invalidEmail => l10n.errorEmailInvalid,
    ValidationError.passwordTooShort => l10n.errorPasswordTooShort(Validators.minPasswordLength),
    ValidationError.passwordMismatch => l10n.errorPasswordMismatch,
  };
}

/// Maps any error (an [AppFailure] or an unknown exception) to a user-facing message.
String errorMessageOf(Object error, BuildContext context) =>
    error is AppFailure ? error.toL10n(context) : context.l10n.errorUnexpected;
