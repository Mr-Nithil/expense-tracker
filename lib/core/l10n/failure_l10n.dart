import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/l10n/generated/app_localizations.dart';
import 'package:flutter/widgets.dart';

/// The one central mapper from [AppFailure] to a user-facing message (ARCHITECTURE §8).
extension AppFailureL10n on AppFailure {
  String toL10n(BuildContext context) => localize(context.l10n);

  String localize(AppLocalizations l10n) => switch (this) {
    ValidationFailure() => l10n.errorValidation,
    NotFoundFailure() => l10n.errorNotFound,
    AuthFailure() => l10n.errorAuth,
    NetworkFailure() => l10n.errorNetwork,
    StorageFailure() => l10n.errorStorage,
    UnexpectedFailure() => l10n.errorUnexpected,
  };
}

/// Maps any error (an [AppFailure] or an unknown exception) to a user-facing message.
String errorMessageOf(Object error, BuildContext context) =>
    error is AppFailure ? error.toL10n(context) : context.l10n.errorUnexpected;
