import 'dart:async';

import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/features/auth/data/auth_repository_provider.dart';
import 'package:expense_tracker/features/auth/domain/auth_repository.dart';
import 'package:expense_tracker/features/auth/domain/entities/auth_user.dart';
import 'package:expense_tracker/features/auth/presentation/providers/login_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fake_auth_repository.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  const email = 'me@example.com';
  const password = 'secret-password';

  late _MockAuthRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = _MockAuthRepository();
    container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    // Keep the auto-dispose controller alive for the whole test, like a mounted screen.
    container.listen(loginControllerProvider, (_, _) {});
  });

  void stubSignIn(Future<Result<AuthUser>> Function() answer) => when(
    () => repository.signIn(
      email: any(named: 'email'),
      password: any(named: 'password'),
    ),
  ).thenAnswer((_) => answer());

  LoginController controller() => container.read(loginControllerProvider.notifier);
  AsyncValue<void> state() => container.read(loginControllerProvider);

  test('starts idle', () {
    expect(state(), isA<AsyncData<void>>());
  });

  test('is loading while signing in, then succeeds', () async {
    final completer = Completer<Result<AuthUser>>();
    stubSignIn(() => completer.future);

    final pending = controller().signIn(email: email, password: password);
    expect(state().isLoading, isTrue);

    completer.complete(const Result.success(testUser));
    await pending;

    expect(state(), isA<AsyncData<void>>());
    verify(() => repository.signIn(email: email, password: password)).called(1);
  });

  test('exposes the failure as an error', () async {
    const failure = AuthFailure('bad', reason: AuthFailureReason.invalidCredentials);
    stubSignIn(() async => const Result.failure(failure));

    await controller().signIn(email: email, password: password);

    expect(state().error, failure);
  });

  test('ignores a second submit while one is in flight', () async {
    final completer = Completer<Result<AuthUser>>();
    stubSignIn(() => completer.future);

    final first = controller().signIn(email: email, password: password);
    await controller().signIn(email: email, password: password);
    completer.complete(const Result.success(testUser));
    await first;

    verify(
      () => repository.signIn(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).called(1);
  });

  test('resendConfirmation passes the repository result through', () async {
    when(
      () => repository.resendConfirmation(email: email),
    ).thenAnswer((_) async => Result.ok);

    final result = await controller().resendConfirmation(email);

    expect(result.isSuccess, isTrue);
    expect(state(), isA<AsyncData<void>>());
  });
}
