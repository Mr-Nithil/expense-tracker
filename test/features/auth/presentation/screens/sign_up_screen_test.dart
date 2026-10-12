import 'dart:async';

import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/l10n/generated/app_localizations_en.dart';
import 'package:expense_tracker/core/router/routes.dart';
import 'package:expense_tracker/features/auth/data/auth_repository_provider.dart';
import 'package:expense_tracker/features/auth/domain/auth_repository.dart';
import 'package:expense_tracker/features/auth/domain/entities/sign_up_outcome.dart';
import 'package:expense_tracker/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/accessibility.dart';
import '../../../../helpers/pump_app.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  final l10n = AppLocalizationsEn();
  const email = 'me@example.com';
  const password = 'secret-password';

  late _MockAuthRepository repository;

  setUp(() => repository = _MockAuthRepository());

  /// Sign-up inside a minimal router, so navigation back to login can be observed.
  Future<void> pumpSignUp(WidgetTester tester, {Brightness brightness = Brightness.light}) =>
      tester.pumpRouterApp(
        initialLocation: Routes.signUpPath,
        brightness: brightness,
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
        routes: [
          GoRoute(
            name: Routes.login,
            path: Routes.loginPath,
            builder: (_, _) => const Scaffold(body: Text('login')),
          ),
          GoRoute(
            name: Routes.signUp,
            path: Routes.signUpPath,
            builder: (_, _) => const SignUpScreen(),
          ),
        ],
      );

  Finder field(String label) => find.widgetWithText(TextFormField, label);
  Finder submitButton() => find.widgetWithText(FilledButton, l10n.authSignUpSubmit);

  void stubSignUp(Future<Result<SignUpOutcome>> Function() answer) => when(
    () => repository.signUp(
      email: any(named: 'email'),
      password: any(named: 'password'),
      displayName: any(named: 'displayName'),
    ),
  ).thenAnswer((_) => answer());

  void verifyNoSignUp() => verifyNever(
    () => repository.signUp(
      email: any(named: 'email'),
      password: any(named: 'password'),
      displayName: any(named: 'displayName'),
    ),
  );

  Future<void> fill(
    WidgetTester tester, {
    String name = 'Me',
    String pass = password,
    String confirm = password,
  }) async {
    await tester.enterText(field(l10n.authDisplayNameLabel), name);
    await tester.enterText(field(l10n.authEmailLabel), email);
    await tester.enterText(field(l10n.authPasswordLabel), pass);
    await tester.enterText(field(l10n.authConfirmPasswordLabel), confirm);
  }

  Future<void> submit(WidgetTester tester) async {
    await tester.ensureVisible(submitButton());
    await tester.tap(submitButton());
    await tester.pump();
  }

  for (final brightness in Brightness.values) {
    testWidgets('renders all fields (${brightness.name})', (tester) async {
      await pumpSignUp(tester, brightness: brightness);

      expect(find.widgetWithText(AppBar, l10n.authSignUpTitle), findsOneWidget);
      for (final label in [
        l10n.authDisplayNameLabel,
        l10n.authEmailLabel,
        l10n.authPasswordLabel,
        l10n.authConfirmPasswordLabel,
      ]) {
        expect(field(label), findsOneWidget, reason: label);
      }
    });
  }

  testWidgets('empty submit requires email and both passwords, not the name', (tester) async {
    await pumpSignUp(tester);

    await submit(tester);

    expect(find.text(l10n.errorFieldRequired), findsNWidgets(3));
    verifyNoSignUp();
  });

  testWidgets('a short password is rejected', (tester) async {
    await pumpSignUp(tester);

    await fill(tester, pass: 'short', confirm: 'short');
    await submit(tester);

    expect(find.text(l10n.errorPasswordTooShort(8)), findsOneWidget);
    verifyNoSignUp();
  });

  testWidgets('mismatched passwords are rejected', (tester) async {
    await pumpSignUp(tester);

    await fill(tester, confirm: '$password-typo');
    await submit(tester);

    expect(find.text(l10n.errorPasswordMismatch), findsOneWidget);
    verifyNoSignUp();
  });

  testWidgets('valid input signs up with the entered values', (tester) async {
    final completer = Completer<Result<SignUpOutcome>>();
    stubSignUp(() => completer.future);
    await pumpSignUp(tester);

    await fill(tester);
    await submit(tester);

    verify(
      () => repository.signUp(email: email, password: password, displayName: 'Me'),
    ).called(1);
    expect(
      find.descendant(of: submitButton(), matching: find.byType(CircularProgressIndicator)),
      findsOneWidget,
    );

    completer.complete(const Result.success(SignUpOutcome.signedIn));
    await tester.pumpAndSettle();
  });

  testWidgets('an existing email shows a friendly snackbar', (tester) async {
    stubSignUp(
      () async => const Result.failure(
        AuthFailure('exists', reason: AuthFailureReason.emailAlreadyRegistered),
      ),
    );
    await pumpSignUp(tester);

    await fill(tester);
    await submit(tester);
    await tester.pumpAndSettle();

    expect(find.text(l10n.errorAuthEmailExists), findsOneWidget);
  });

  testWidgets('when email confirmation is required, returns to login with a message', (
    tester,
  ) async {
    stubSignUp(() async => const Result.success(SignUpOutcome.emailConfirmationRequired));
    await pumpSignUp(tester);

    await fill(tester);
    await submit(tester);
    await tester.pumpAndSettle();

    expect(find.text('login'), findsOneWidget);
    expect(find.text(l10n.authSignUpConfirmEmailSent), findsOneWidget);
  });

  testWidgets('the keyboard done action on confirm-password submits', (tester) async {
    stubSignUp(() async => const Result.success(SignUpOutcome.signedIn));
    await pumpSignUp(tester);

    await fill(tester);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    verify(
      () => repository.signUp(email: email, password: password, displayName: 'Me'),
    ).called(1);
  });

  group('accessibility (M9.5)', () {
    testWidgetsBothThemes('meets the guidelines', (tester, brightness) async {
      await pumpSignUp(tester, brightness: brightness);
      await expectAccessible(tester);
    });

    testWidgets('large text (2x) fits', (tester) async {
      useTextScale(tester, 2);
      await pumpSignUp(tester);
      await scrollThrough(tester);
    });
  });
}
