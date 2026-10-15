import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/l10n/generated/app_localizations_en.dart';
import 'package:expense_tracker/features/auth/data/auth_repository_provider.dart';
import 'package:expense_tracker/features/auth/domain/auth_repository.dart';
import 'package:expense_tracker/features/auth/domain/entities/auth_snapshot.dart';
import 'package:expense_tracker/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/accessibility.dart';
import '../../../../helpers/fake_auth_repository.dart';
import '../../../../helpers/pump_app.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  final l10n = AppLocalizationsEn();
  const password = 'new-password';

  late _MockAuthRepository repository;

  setUp(() {
    repository = _MockAuthRepository();
    when(() => repository.currentUser).thenReturn(testUser);
    when(() => repository.authStateChanges()).thenAnswer(
      (_) => Stream.value(const AuthSnapshot(user: testUser, isPasswordRecovery: true)),
    );
  });

  Future<void> pumpScreen(WidgetTester tester, {Brightness brightness = Brightness.light}) async {
    await tester.pumpApp(
      const ResetPasswordScreen(),
      brightness: brightness,
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );
    await tester.pumpAndSettle();
  }

  Finder field(String label) => findWidgetWithText(TextFormField, label);
  Finder saveButton() => findWidgetWithText(FilledButton, l10n.authResetPasswordSubmit);

  void verifyNoUpdate() =>
      verifyNever(() => repository.updatePassword(newPassword: any(named: 'newPassword')));

  Future<void> fillAndSave(WidgetTester tester, {String pass = password, String? confirm}) async {
    await tester.enterText(field(l10n.authNewPasswordLabel), pass);
    await tester.enterText(field(l10n.authConfirmPasswordLabel), confirm ?? pass);
    await tester.tap(saveButton());
    await tester.pumpAndSettle();
  }

  testWidgetsBothThemes('renders the form for the signed-in email', (tester, brightness) async {
    await pumpScreen(tester, brightness: brightness);

    expect(findText(l10n.authResetPasswordSubtitle(testUser.email)), findsOneWidget);
    expect(field(l10n.authNewPasswordLabel), findsOneWidget);
    expect(field(l10n.authConfirmPasswordLabel), findsOneWidget);
    expect(saveButton(), findsOneWidget);
  });

  testWidgets('rejects a short or mismatched password', (tester) async {
    await pumpScreen(tester);

    await fillAndSave(tester, pass: 'short');
    expect(findText(l10n.errorPasswordTooShort(8)), findsOneWidget);

    await fillAndSave(tester, confirm: '$password-typo');
    expect(findText(l10n.errorPasswordMismatch), findsOneWidget);

    verifyNoUpdate();
  });

  testWidgets('saves the new password', (tester) async {
    when(
      () => repository.updatePassword(newPassword: any(named: 'newPassword')),
    ).thenAnswer((_) async => Result.ok);
    await pumpScreen(tester);

    await fillAndSave(tester);

    verify(() => repository.updatePassword(newPassword: password)).called(1);
  });

  testWidgets('reusing the old password shows a friendly snackbar', (tester) async {
    when(() => repository.updatePassword(newPassword: any(named: 'newPassword'))).thenAnswer(
      (_) async => const Result.failure(
        AuthFailure('same', reason: AuthFailureReason.samePassword),
      ),
    );
    await pumpScreen(tester);

    await fillAndSave(tester);

    expect(findText(l10n.errorAuthSamePassword), findsOneWidget);
  });

  testWidgets('cancel signs out', (tester) async {
    when(() => repository.signOut()).thenAnswer((_) async => Result.ok);
    await pumpScreen(tester);

    await tester.tap(findText(l10n.authResetPasswordCancel));
    await tester.pumpAndSettle();

    verify(() => repository.signOut()).called(1);
    verifyNoUpdate();
  });

  group('accessibility (M9.5)', () {
    testWidgetsBothThemes('meets the guidelines', (tester, brightness) async {
      await pumpScreen(tester, brightness: brightness);
      await expectAccessible(tester);
    });

    testWidgets('large text (2x) fits', (tester) async {
      useTextScale(tester, 2);
      await pumpScreen(tester);
      await scrollThrough(tester);
    });
  });
}
