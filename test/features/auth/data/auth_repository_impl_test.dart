import 'dart:async';
import 'dart:io';

import 'package:expense_tracker/core/config/deep_links.dart';
import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/utils/validators.dart';
import 'package:expense_tracker/features/auth/data/auth_repository_impl.dart';
import 'package:expense_tracker/features/auth/domain/entities/auth_snapshot.dart';
import 'package:expense_tracker/features/auth/domain/entities/auth_user.dart';
import 'package:expense_tracker/features/auth/domain/entities/sign_up_outcome.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;

class _MockGoTrueClient extends Mock implements GoTrueClient {}

void main() {
  late _MockGoTrueClient auth;
  late AuthRepositoryImpl repository;

  const email = 'me@example.com';
  const password = 'secret-password';

  User user({String id = 'u1', String? displayName}) => User(
    id: id,
    email: email,
    appMetadata: const {},
    userMetadata: {'display_name': ?displayName},
    aud: 'authenticated',
    createdAt: '2026-10-10T00:00:00Z',
  );

  Session session(User u) => Session(accessToken: 'token', tokenType: 'bearer', user: u);

  setUp(() {
    auth = _MockGoTrueClient();
    repository = AuthRepositoryImpl(auth);
  });

  AppFailure failureOf<T>(Result<T> result) => result.failureOrNull!;

  group('confirmPassword', () {
    test('signs in again with the current account email', () async {
      when(() => auth.currentUser).thenReturn(user());
      when(
        () => auth.signInWithPassword(email: email, password: password),
      ).thenAnswer((_) async => AuthResponse(session: session(user())));

      expect(await repository.confirmPassword(password), isA<Success<void>>());
      verify(() => auth.signInWithPassword(email: email, password: password)).called(1);
    });

    test('a wrong password is invalidCredentials', () async {
      when(() => auth.currentUser).thenReturn(user());
      when(
        () => auth.signInWithPassword(email: email, password: 'wrong'),
      ).thenThrow(const AuthApiException('Invalid login credentials', code: 'invalid_credentials'));

      final failure = failureOf(await repository.confirmPassword('wrong'));
      expect((failure as AuthFailure).reason, AuthFailureReason.invalidCredentials);
    });

    test('fails without a session, without calling Supabase', () async {
      when(() => auth.currentUser).thenReturn(null);

      expect(failureOf(await repository.confirmPassword(password)), isA<AuthFailure>());
      verifyNever(
        () => auth.signInWithPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      );
    });
  });

  group('signIn', () {
    test('returns the mapped user and trims the email', () async {
      when(
        () => auth.signInWithPassword(email: email, password: password),
      ).thenAnswer((_) async => AuthResponse(session: session(user(displayName: 'Nithil'))));

      final result = await repository.signIn(email: '  $email ', password: password);

      expect(
        result.valueOrNull,
        const AuthUser(id: 'u1', email: email, displayName: 'Nithil'),
      );
    });

    test('rejects invalid input without calling Supabase', () async {
      final badEmail = await repository.signIn(email: 'nope', password: password);
      final noPassword = await repository.signIn(email: email, password: '');

      expect((failureOf(badEmail) as ValidationFailure).field, 'email');
      expect((failureOf(noPassword) as ValidationFailure).field, 'password');
      verifyNever(
        () => auth.signInWithPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      );
    });

    test('maps wrong credentials to AuthFailure.invalidCredentials', () async {
      when(
        () => auth.signInWithPassword(email: email, password: password),
      ).thenThrow(const AuthApiException('bad', statusCode: '400', code: 'invalid_credentials'));

      final failure = failureOf(await repository.signIn(email: email, password: password));

      expect(failure, isA<AuthFailure>());
      expect((failure as AuthFailure).reason, AuthFailureReason.invalidCredentials);
    });

    test('maps connection problems to NetworkFailure', () async {
      for (final error in <Exception>[
        AuthRetryableFetchException(message: 'offline'),
        const SocketException('offline'),
        TimeoutException('slow'),
      ]) {
        when(
          () => auth.signInWithPassword(email: email, password: password),
        ).thenThrow(error);
        final result = await repository.signIn(email: email, password: password);
        expect(failureOf(result), isA<NetworkFailure>(), reason: error.runtimeType.toString());
      }
    });

    test('maps unknown errors to UnexpectedFailure', () async {
      when(
        () => auth.signInWithPassword(email: email, password: password),
      ).thenThrow(StateError('boom'));

      final result = await repository.signIn(email: email, password: password);

      expect(failureOf(result), isA<UnexpectedFailure>());
    });
  });

  group('signUp', () {
    void stubSignUp(AuthResponse response) => when(
      () => auth.signUp(
        email: any(named: 'email'),
        password: any(named: 'password'),
        data: any(named: 'data'),
        emailRedirectTo: any(named: 'emailRedirectTo'),
      ),
    ).thenAnswer((_) async => response);

    test('is signedIn when a session is returned and sends the display name', () async {
      stubSignUp(AuthResponse(session: session(user())));

      final result = await repository.signUp(
        email: email,
        password: password,
        displayName: ' Nithil ',
      );

      expect(result.valueOrNull, SignUpOutcome.signedIn);
      verify(
        () => auth.signUp(
          email: email,
          password: password,
          data: {'display_name': 'Nithil'},
          emailRedirectTo: DeepLinks.authCallback,
        ),
      ).called(1);
    });

    test('requires email confirmation when no session is returned', () async {
      stubSignUp(AuthResponse(user: user()));

      final result = await repository.signUp(email: email, password: password);

      expect(result.valueOrNull, SignUpOutcome.emailConfirmationRequired);
    });

    test('enforces password length and display name length locally', () async {
      final shortPassword = await repository.signUp(email: email, password: 'short');
      final longName = await repository.signUp(
        email: email,
        password: password,
        displayName: 'x' * (Validators.maxDisplayNameLength + 1),
      );

      expect((failureOf(shortPassword) as ValidationFailure).field, 'password');
      expect((failureOf(longName) as ValidationFailure).field, 'displayName');
      verifyNever(
        () => auth.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          data: any(named: 'data'),
          emailRedirectTo: any(named: 'emailRedirectTo'),
        ),
      );
    });

    test('maps an existing email to emailAlreadyRegistered', () async {
      when(
        () => auth.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          data: any(named: 'data'),
          emailRedirectTo: any(named: 'emailRedirectTo'),
        ),
      ).thenThrow(const AuthApiException('exists', statusCode: '422', code: 'user_already_exists'));

      final failure = failureOf(await repository.signUp(email: email, password: password));

      expect((failure as AuthFailure).reason, AuthFailureReason.emailAlreadyRegistered);
    });
  });

  group('signOut', () {
    test('succeeds', () async {
      when(() => auth.signOut()).thenAnswer((_) async {});
      expect((await repository.signOut()).isSuccess, isTrue);
    });

    test('still succeeds when the server call fails (local session is already cleared)', () async {
      when(() => auth.signOut()).thenThrow(AuthRetryableFetchException(message: 'offline'));
      expect((await repository.signOut()).isSuccess, isTrue);
    });
  });

  group('sendPasswordReset', () {
    test('sends to the trimmed email', () async {
      when(
        () => auth.resetPasswordForEmail(email, redirectTo: DeepLinks.authCallback),
      ).thenAnswer((_) async {});

      final result = await repository.sendPasswordReset(email: ' $email');

      expect(result.isSuccess, isTrue);
      verify(
        () => auth.resetPasswordForEmail(email, redirectTo: DeepLinks.authCallback),
      ).called(1);
    });

    test('rejects an invalid email locally', () async {
      final result = await repository.sendPasswordReset(email: 'nope');
      expect(failureOf(result), isA<ValidationFailure>());
      verifyNever(
        () => auth.resetPasswordForEmail(any(), redirectTo: any(named: 'redirectTo')),
      );
    });
  });

  group('updatePassword', () {
    setUpAll(() => registerFallbackValue(UserAttributes()));

    test('updates the password', () async {
      when(() => auth.updateUser(any())).thenAnswer((_) async => UserResponse.fromJson({}));

      final result = await repository.updatePassword(newPassword: password);

      expect(result.isSuccess, isTrue);
      final attributes =
          verify(() => auth.updateUser(captureAny())).captured.single as UserAttributes;
      expect(attributes.password, password);
    });

    test('rejects a short password locally', () async {
      final result = await repository.updatePassword(newPassword: 'short');

      expect((failureOf(result) as ValidationFailure).field, 'password');
      verifyNever(() => auth.updateUser(any()));
    });

    test('maps same_password and network errors', () async {
      when(() => auth.updateUser(any())).thenThrow(
        const AuthApiException('same', statusCode: '422', code: 'same_password'),
      );
      final same = failureOf(await repository.updatePassword(newPassword: password));
      expect((same as AuthFailure).reason, AuthFailureReason.samePassword);

      when(() => auth.updateUser(any())).thenThrow(AuthRetryableFetchException(message: 'x'));
      final offline = failureOf(await repository.updatePassword(newPassword: password));
      expect(offline, isA<NetworkFailure>());
    });
  });

  group('session state', () {
    test('authStateChanges maps sessions to users and drops repeats', () async {
      final u = user();
      final controller = StreamController<AuthState>();
      when(() => auth.onAuthStateChange).thenAnswer((_) => controller.stream);

      final emitted = expectLater(
        repository.authStateChanges(),
        emitsInOrder([
          const AuthSnapshot(
            user: AuthUser(id: 'u1', email: email),
          ),
          const AuthSnapshot(),
          emitsDone,
        ]),
      );
      controller
        ..add(AuthState(AuthChangeEvent.signedIn, session(u)))
        ..add(AuthState(AuthChangeEvent.tokenRefreshed, session(u)))
        ..add(const AuthState(AuthChangeEvent.signedOut, null));
      await controller.close();
      await emitted;
    });

    test('password recovery is sticky across refreshes and ends on userUpdated', () async {
      final u = user();
      const signedIn = AuthUser(id: 'u1', email: email);
      final controller = StreamController<AuthState>();
      when(() => auth.onAuthStateChange).thenAnswer((_) => controller.stream);

      final emitted = expectLater(
        repository.authStateChanges(),
        emitsInOrder([
          const AuthSnapshot(user: signedIn, isPasswordRecovery: true),
          const AuthSnapshot(user: signedIn),
          emitsDone,
        ]),
      );
      controller
        ..add(AuthState(AuthChangeEvent.passwordRecovery, session(u)))
        ..add(AuthState(AuthChangeEvent.tokenRefreshed, session(u)))
        ..add(AuthState(AuthChangeEvent.userUpdated, session(u)));
      await controller.close();
      await emitted;
    });

    test('signing out ends password recovery', () async {
      final controller = StreamController<AuthState>();
      when(() => auth.onAuthStateChange).thenAnswer((_) => controller.stream);

      final emitted = expectLater(
        repository.authStateChanges().map((s) => s.isPasswordRecovery),
        emitsInOrder([true, false, emitsDone]),
      );
      controller
        ..add(AuthState(AuthChangeEvent.passwordRecovery, session(user())))
        ..add(const AuthState(AuthChangeEvent.signedOut, null));
      await controller.close();
      await emitted;
    });

    test('currentUser reads the restored session', () {
      when(() => auth.currentUser).thenReturn(user());
      expect(repository.currentUser?.id, 'u1');

      when(() => auth.currentUser).thenReturn(null);
      expect(repository.currentUser, isNull);
    });
  });

  group('auth link errors', () {
    test('authLinkFailureOf maps link problems and ignores everything else', () {
      AuthFailureReason? reasonOf(Object error) => authLinkFailureOf(error)?.reason;

      // URL error from an expired or used email link (fields swapped by Supabase).
      expect(
        reasonOf(
          const AuthException('expired', statusCode: 'otp_expired', code: 'access_denied'),
        ),
        AuthFailureReason.linkExpired,
      );
      expect(
        reasonOf(const AuthApiException('x', code: 'flow_state_expired')),
        AuthFailureReason.linkExpired,
      );
      expect(
        reasonOf(const AuthApiException('x', code: 'flow_state_not_found')),
        AuthFailureReason.linkInvalid,
      );
      expect(
        reasonOf(const AuthException('Code verifier could not be found in local storage.')),
        AuthFailureReason.linkInvalid,
      );
      expect(
        reasonOf(const AuthPKCEGrantCodeExchangeError('No code detected')),
        AuthFailureReason.linkInvalid,
      );

      expect(authLinkFailureOf(AuthRetryableFetchException(message: 'offline')), isNull);
      expect(authLinkFailureOf(const AuthException('x', code: 'session_missing')), isNull);
      expect(authLinkFailureOf(StateError('boom')), isNull);
    });

    test('authLinkErrors emits only link failures', () async {
      final controller = StreamController<AuthState>();
      when(() => auth.onAuthStateChange).thenAnswer((_) => controller.stream);

      final emitted = expectLater(
        repository.authLinkErrors().map((f) => f.reason),
        emitsInOrder([AuthFailureReason.linkExpired, emitsDone]),
      );
      controller
        ..add(AuthState(AuthChangeEvent.signedIn, session(user())))
        ..addError(AuthRetryableFetchException(message: 'offline'))
        ..addError(const AuthApiException('x', code: 'otp_expired'));
      await controller.close();
      await emitted;
    });
  });

  group('resendConfirmation', () {
    setUpAll(() => registerFallbackValue(OtpType.signup));

    void stubResend(Future<ResendResponse> Function() answer) => when(
      () => auth.resend(
        type: any(named: 'type'),
        email: any(named: 'email'),
        emailRedirectTo: any(named: 'emailRedirectTo'),
      ),
    ).thenAnswer((_) => answer());

    test('resends the sign-up email to the trimmed address with the app redirect', () async {
      stubResend(() async => ResendResponse());

      final result = await repository.resendConfirmation(email: ' $email ');

      expect(result.isSuccess, isTrue);
      verify(
        () => auth.resend(
          type: OtpType.signup,
          email: email,
          emailRedirectTo: DeepLinks.authCallback,
        ),
      ).called(1);
    });

    test('rejects an invalid email locally', () async {
      final result = await repository.resendConfirmation(email: 'nope');

      expect(failureOf(result), isA<ValidationFailure>());
      verifyNever(
        () => auth.resend(
          type: any(named: 'type'),
          email: any(named: 'email'),
          emailRedirectTo: any(named: 'emailRedirectTo'),
        ),
      );
    });

    test('maps rate limiting', () async {
      when(
        () => auth.resend(
          type: any(named: 'type'),
          email: any(named: 'email'),
          emailRedirectTo: any(named: 'emailRedirectTo'),
        ),
      ).thenThrow(const AuthApiException('slow down', code: 'over_email_send_rate_limit'));

      final failure = failureOf(await repository.resendConfirmation(email: email));

      expect((failure as AuthFailure).reason, AuthFailureReason.rateLimited);
    });
  });

  group('authFailureReasonOf', () {
    test('maps Supabase error codes', () {
      final cases = {
        'email_exists': AuthFailureReason.emailAlreadyRegistered,
        'weak_password': AuthFailureReason.weakPassword,
        'email_not_confirmed': AuthFailureReason.emailNotConfirmed,
        'over_email_send_rate_limit': AuthFailureReason.rateLimited,
        'something_new': AuthFailureReason.unknown,
      };
      for (final MapEntry(key: code, value: reason) in cases.entries) {
        expect(authFailureReasonOf(AuthException('x', code: code)), reason, reason: code);
      }
      expect(
        authFailureReasonOf(const AuthException('x', statusCode: '429')),
        AuthFailureReason.rateLimited,
      );
    });
  });
}
