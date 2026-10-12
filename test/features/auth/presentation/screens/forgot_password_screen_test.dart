import 'dart:async';

import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/l10n/generated/app_localizations_en.dart';
import 'package:expense_tracker/core/router/routes.dart';
import 'package:expense_tracker/features/auth/data/auth_repository_provider.dart';
import 'package:expense_tracker/features/auth/domain/auth_repository.dart';
import 'package:expense_tracker/features/auth/presentation/screens/forgot_password_screen.dart';
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

  late _MockAuthRepository repository;

  setUp(() => repository = _MockAuthRepository());

  Future<void> pumpScreen(
    WidgetTester tester, {
    String? initialEmail,
    Brightness brightness = Brightness.light,
  }) => tester.pumpRouterApp(
    initialLocation: Routes.forgotPasswordPath,
    brightness: brightness,
    overrides: [authRepositoryProvider.overrideWithValue(repository)],
    routes: [
      GoRoute(
        name: Routes.login,
        path: Routes.loginPath,
        builder: (_, _) => const Scaffold(body: Text('login')),
      ),
      GoRoute(
        name: Routes.forgotPassword,
        path: Routes.forgotPasswordPath,
        builder: (_, _) => ForgotPasswordScreen(initialEmail: initialEmail),
      ),
    ],
  );

  Finder emailField() => find.widgetWithText(TextFormField, l10n.authEmailLabel);
  Finder submitButton() => find.widgetWithText(FilledButton, l10n.authForgotPasswordSubmit);

  void stubReset(Future<Result<void>> Function() answer) => when(
    () => repository.sendPasswordReset(email: any(named: 'email')),
  ).thenAnswer((_) => answer());

  Future<void> submit(WidgetTester tester) async {
    await tester.tap(submitButton());
    await tester.pump();
  }

  testWidgetsBothThemes('renders the form', (tester, brightness) async {
    await pumpScreen(tester, brightness: brightness);

    expect(find.widgetWithText(AppBar, l10n.authForgotPasswordTitle), findsOneWidget);
    expect(find.text(l10n.authForgotPasswordSubtitle), findsOneWidget);
    expect(emailField(), findsOneWidget);
    expect(submitButton(), findsOneWidget);
  });

  testWidgets('an invalid email is rejected in the form', (tester) async {
    await pumpScreen(tester);

    await tester.enterText(emailField(), 'nope');
    await submit(tester);

    expect(find.text(l10n.errorEmailInvalid), findsOneWidget);
    verifyNever(() => repository.sendPasswordReset(email: any(named: 'email')));
  });

  testWidgets('pre-fills the email passed from login', (tester) async {
    await pumpScreen(tester, initialEmail: email);

    expect(find.widgetWithText(TextFormField, email), findsOneWidget);
  });

  testWidgets('sends the link, shows loading, then the neutral sent view', (tester) async {
    final completer = Completer<Result<void>>();
    stubReset(() => completer.future);
    await pumpScreen(tester, initialEmail: email);

    await submit(tester);
    expect(
      find.descendant(of: submitButton(), matching: find.byType(CircularProgressIndicator)),
      findsOneWidget,
    );

    completer.complete(Result.ok);
    await tester.pumpAndSettle();

    verify(() => repository.sendPasswordReset(email: email)).called(1);
    expect(find.text(l10n.authForgotPasswordSentTitle), findsOneWidget);
    expect(find.text(l10n.authForgotPasswordSentMessage(email)), findsOneWidget);
    expect(emailField(), findsNothing);
  });

  testWidgets('back to sign in goes to login', (tester) async {
    stubReset(() async => Result.ok);
    await pumpScreen(tester, initialEmail: email);
    await submit(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.text(l10n.authForgotPasswordBackToLogin));
    await tester.pumpAndSettle();

    expect(find.text('login'), findsOneWidget);
  });

  testWidgets('a failure shows a snackbar and keeps the form', (tester) async {
    stubReset(() async => const Result.failure(NetworkFailure('offline')));
    await pumpScreen(tester, initialEmail: email);

    await submit(tester);
    await tester.pumpAndSettle();

    expect(find.text(l10n.errorNetwork), findsOneWidget);
    expect(emailField(), findsOneWidget);
  });

  testWidgets('the keyboard done action on the email submits', (tester) async {
    stubReset(() async => Result.ok);
    await pumpScreen(tester);

    await tester.enterText(emailField(), email);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    verify(() => repository.sendPasswordReset(email: email)).called(1);
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
