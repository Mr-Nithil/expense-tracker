import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/l10n/failure_l10n.dart';
import 'package:expense_tracker/core/l10n/generated/app_localizations_en.dart';
import 'package:expense_tracker/core/utils/validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  final l10n = AppLocalizationsEn();

  test('every failure type maps to its own message', () {
    final messages = {
      const ValidationFailure('x', field: 'f'): l10n.errorValidation,
      const NotFoundFailure('x'): l10n.errorNotFound,
      const AuthFailure('x'): l10n.errorAuth,
      const NetworkFailure('x'): l10n.errorNetwork,
      const StorageFailure('x'): l10n.errorStorage,
      const UnexpectedFailure('x'): l10n.errorUnexpected,
    };
    for (final MapEntry(key: failure, value: message) in messages.entries) {
      expect(failure.localize(l10n), message, reason: failure.runtimeType.toString());
    }
    expect(messages.values.toSet(), hasLength(messages.length));
  });

  test('every auth failure reason has its own message, unknown falls back to errorAuth', () {
    final messages = {
      for (final reason in AuthFailureReason.values)
        reason: AuthFailure('x', reason: reason).localize(l10n),
    };
    expect(messages[AuthFailureReason.unknown], l10n.errorAuth);
    expect(messages[AuthFailureReason.invalidCredentials], l10n.errorAuthInvalidCredentials);
    expect(messages.values.toSet(), hasLength(AuthFailureReason.values.length));
  });

  test('every validation error has its own message', () {
    final messages = ValidationError.values.map((e) => e.localize(l10n)).toSet();
    expect(messages, hasLength(ValidationError.values.length));
    expect(
      ValidationError.passwordTooShort.localize(l10n),
      contains('${Validators.minPasswordLength}'),
    );
  });

  testWidgets('errorMessageOf never shows raw exception text', (tester) async {
    late String failureMessage;
    late String unknownMessage;
    await tester.pumpApp(
      Builder(
        builder: (context) {
          failureMessage = errorMessageOf(const NetworkFailure('socket closed'), context);
          unknownMessage = errorMessageOf(StateError('secret internals'), context);
          return const SizedBox();
        },
      ),
    );
    expect(failureMessage, l10n.errorNetwork);
    expect(unknownMessage, l10n.errorUnexpected);
  });
}
