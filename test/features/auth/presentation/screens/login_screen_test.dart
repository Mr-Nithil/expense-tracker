import 'dart:async';

import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/l10n/generated/app_localizations_en.dart';
import 'package:expense_tracker/features/auth/data/auth_repository_provider.dart';
import 'package:expense_tracker/features/auth/domain/auth_repository.dart';
import 'package:expense_tracker/features/auth/domain/entities/auth_user.dart';
import 'package:expense_tracker/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fake_auth_repository.dart';
import '../../../../helpers/pump_app.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  final l10n = AppLocalizationsEn();
  const email = 'me@example.com';
  const password = 'secret-password';

  late _MockAuthRepository repository;

  setUp(() => repository = _MockAuthRepository());

  Future<void> pumpLogin(WidgetTester tester, {Brightness brightness = Brightness.light}) =>
      tester.pumpApp(
        const LoginScreen(),
        brightness: brightness,
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
      );

  Finder field(String label) => find.widgetWithText(TextFormField, label);
  Finder submitButton() => find.widgetWithText(FilledButton, l10n.authLoginSubmit);

  void stubSignIn(Future<Result<AuthUser>> Function() answer) => when(
    () => repository.signIn(
      email: any(named: 'email'),
      password: any(named: 'password'),
    ),
  ).thenAnswer((_) => answer());

  Future<void> fillAndSubmit(WidgetTester tester, {String mail = email}) async {
    await tester.enterText(field(l10n.authEmailLabel), mail);
    await tester.enterText(field(l10n.authPasswordLabel), password);
    await tester.tap(submitButton());
    await tester.pump();
  }

  testWidgetsBothThemes('renders the form', (tester, brightness) async {
    await pumpLogin(tester, brightness: brightness);

    expect(find.text(l10n.authLoginSubtitle), findsOneWidget);
    expect(field(l10n.authEmailLabel), findsOneWidget);
    expect(field(l10n.authPasswordLabel), findsOneWidget);
    expect(submitButton(), findsOneWidget);
  });

  testWidgets('empty submit shows required errors and does not sign in', (tester) async {
    await pumpLogin(tester);

    await tester.tap(submitButton());
    await tester.pump();

    expect(find.text(l10n.errorFieldRequired), findsNWidgets(2));
    verifyNever(
      () => repository.signIn(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    );
  });

  testWidgets('a malformed email is rejected in the form', (tester) async {
    await pumpLogin(tester);

    await fillAndSubmit(tester, mail: 'not-an-email');

    expect(find.text(l10n.errorEmailInvalid), findsOneWidget);
    verifyNever(
      () => repository.signIn(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    );
  });

  testWidgets('valid input signs in and shows the loading state meanwhile', (tester) async {
    final completer = Completer<Result<AuthUser>>();
    stubSignIn(() => completer.future);
    await pumpLogin(tester);

    await fillAndSubmit(tester);

    verify(() => repository.signIn(email: email, password: password)).called(1);
    expect(
      find.descendant(of: submitButton(), matching: find.byType(CircularProgressIndicator)),
      findsOneWidget,
    );
    expect(tester.widget<TextFormField>(field(l10n.authEmailLabel)).enabled, isFalse);

    completer.complete(const Result.success(testUser));
    await tester.pumpAndSettle();
    expect(
      find.descendant(of: submitButton(), matching: find.byType(CircularProgressIndicator)),
      findsNothing,
    );
  });

  testWidgets('wrong credentials show a friendly snackbar', (tester) async {
    stubSignIn(
      () async => const Result.failure(
        AuthFailure('bad', reason: AuthFailureReason.invalidCredentials),
      ),
    );
    await pumpLogin(tester);

    await fillAndSubmit(tester);
    await tester.pumpAndSettle();

    expect(find.text(l10n.errorAuthInvalidCredentials), findsOneWidget);
  });

  testWidgets('the eye button toggles password visibility', (tester) async {
    await pumpLogin(tester);
    EditableText passwordText() => tester.widget<EditableText>(
      find.descendant(of: field(l10n.authPasswordLabel), matching: find.byType(EditableText)),
    );

    expect(passwordText().obscureText, isTrue);
    await tester.tap(find.byTooltip(l10n.authShowPassword));
    await tester.pump();
    expect(passwordText().obscureText, isFalse);
    expect(find.byTooltip(l10n.authHidePassword), findsOneWidget);
  });

  testWidgets('the keyboard done action on the password submits', (tester) async {
    stubSignIn(() async => const Result.success(testUser));
    await pumpLogin(tester);

    await tester.enterText(field(l10n.authEmailLabel), email);
    await tester.enterText(field(l10n.authPasswordLabel), password);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    verify(() => repository.signIn(email: email, password: password)).called(1);
  });

  group('email not confirmed', () {
    setUp(
      () => stubSignIn(
        () async => const Result.failure(
          AuthFailure('unconfirmed', reason: AuthFailureReason.emailNotConfirmed),
        ),
      ),
    );

    testWidgets('offers to resend the confirmation email', (tester) async {
      when(
        () => repository.resendConfirmation(email: any(named: 'email')),
      ).thenAnswer((_) async => Result.ok);
      await pumpLogin(tester);

      await fillAndSubmit(tester);
      await tester.pumpAndSettle();
      expect(find.text(l10n.errorAuthEmailNotConfirmed), findsOneWidget);

      await tester.tap(find.text(l10n.authResendConfirmation));
      await tester.pumpAndSettle();

      verify(() => repository.resendConfirmation(email: email)).called(1);
      expect(find.text(l10n.authConfirmationResent), findsOneWidget);
    });

    testWidgets('a failed resend shows why', (tester) async {
      when(() => repository.resendConfirmation(email: any(named: 'email'))).thenAnswer(
        (_) async => const Result.failure(
          AuthFailure('slow', reason: AuthFailureReason.rateLimited),
        ),
      );
      await pumpLogin(tester);

      await fillAndSubmit(tester);
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.authResendConfirmation));
      await tester.pumpAndSettle();

      expect(find.text(l10n.errorAuthRateLimited), findsOneWidget);
    });
  });

  testWidgets('other sign-in errors have no resend action', (tester) async {
    stubSignIn(
      () async => const Result.failure(
        AuthFailure('bad', reason: AuthFailureReason.invalidCredentials),
      ),
    );
    await pumpLogin(tester);

    await fillAndSubmit(tester);
    await tester.pumpAndSettle();

    expect(find.text(l10n.errorAuthInvalidCredentials), findsOneWidget);
    expect(find.text(l10n.authResendConfirmation), findsNothing);
  });
}
