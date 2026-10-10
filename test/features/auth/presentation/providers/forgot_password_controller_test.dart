import 'dart:async';

import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/features/auth/data/auth_repository_provider.dart';
import 'package:expense_tracker/features/auth/domain/auth_repository.dart';
import 'package:expense_tracker/features/auth/presentation/providers/forgot_password_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  const email = 'me@example.com';

  late _MockAuthRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = _MockAuthRepository();
    container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    // Keep the auto-dispose controller alive for the whole test, like a mounted screen.
    container.listen(forgotPasswordControllerProvider, (_, _) {});
  });

  void stubReset(Future<Result<void>> Function() answer) => when(
    () => repository.sendPasswordReset(email: any(named: 'email')),
  ).thenAnswer((_) => answer());

  ForgotPasswordController controller() =>
      container.read(forgotPasswordControllerProvider.notifier);
  AsyncValue<String?> state() => container.read(forgotPasswordControllerProvider);

  test('starts idle', () {
    expect(state(), const AsyncData<String?>(null));
  });

  test('is loading, then holds the trimmed email it was sent to', () async {
    final completer = Completer<Result<void>>();
    stubReset(() => completer.future);

    final pending = controller().sendReset(email: ' $email ');
    expect(state().isLoading, isTrue);

    completer.complete(Result.ok);
    await pending;

    expect(state().value, email);
  });

  test('exposes the failure as an error', () async {
    const failure = NetworkFailure('offline');
    stubReset(() async => const Result.failure(failure));

    await controller().sendReset(email: email);

    expect(state().error, failure);
  });

  test('ignores a second submit while one is in flight', () async {
    final completer = Completer<Result<void>>();
    stubReset(() => completer.future);

    final first = controller().sendReset(email: email);
    await controller().sendReset(email: email);
    completer.complete(Result.ok);
    await first;

    verify(() => repository.sendPasswordReset(email: any(named: 'email'))).called(1);
  });

  test('reset returns to the form', () async {
    stubReset(() async => Result.ok);
    await controller().sendReset(email: email);

    controller().reset();

    expect(state().value, isNull);
  });
}
