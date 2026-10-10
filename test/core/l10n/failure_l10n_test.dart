import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/l10n/failure_l10n.dart';
import 'package:expense_tracker/core/l10n/generated/app_localizations_en.dart';
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
