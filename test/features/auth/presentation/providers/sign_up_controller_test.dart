import 'dart:async';

import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/features/auth/data/auth_repository_provider.dart';
import 'package:expense_tracker/features/auth/domain/auth_repository.dart';
import 'package:expense_tracker/features/auth/domain/entities/sign_up_outcome.dart';
import 'package:expense_tracker/features/auth/presentation/providers/sign_up_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

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
    container.listen(signUpControllerProvider, (_, _) {});
  });

  void stubSignUp(Future<Result<SignUpOutcome>> Function() answer) => when(
    () => repository.signUp(
      email: any(named: 'email'),
      password: any(named: 'password'),
      displayName: any(named: 'displayName'),
    ),
  ).thenAnswer((_) => answer());

  SignUpController controller() => container.read(signUpControllerProvider.notifier);
  AsyncValue<SignUpOutcome?> state() => container.read(signUpControllerProvider);

  test('starts idle', () {
    expect(state(), const AsyncData<SignUpOutcome?>(null));
  });

  for (final outcome in SignUpOutcome.values) {
    test('is loading, then exposes the ${outcome.name} outcome', () async {
      final completer = Completer<Result<SignUpOutcome>>();
      stubSignUp(() => completer.future);

      final pending = controller().signUp(email: email, password: password, displayName: 'Me');
      expect(state().isLoading, isTrue);

      completer.complete(Result.success(outcome));
      await pending;

      expect(state().value, outcome);
      verify(
        () => repository.signUp(email: email, password: password, displayName: 'Me'),
      ).called(1);
    });
  }

  test('exposes the failure as an error', () async {
    const failure = AuthFailure('exists', reason: AuthFailureReason.emailAlreadyRegistered);
    stubSignUp(() async => const Result.failure(failure));

    await controller().signUp(email: email, password: password);

    expect(state().error, failure);
  });

  test('ignores a second submit while one is in flight', () async {
    final completer = Completer<Result<SignUpOutcome>>();
    stubSignUp(() => completer.future);

    final first = controller().signUp(email: email, password: password);
    await controller().signUp(email: email, password: password);
    completer.complete(const Result.success(SignUpOutcome.signedIn));
    await first;

    verify(
      () => repository.signUp(
        email: any(named: 'email'),
        password: any(named: 'password'),
        displayName: any(named: 'displayName'),
      ),
    ).called(1);
  });
}
