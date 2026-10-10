import 'dart:async';

import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/features/auth/data/auth_repository_provider.dart';
import 'package:expense_tracker/features/auth/domain/auth_repository.dart';
import 'package:expense_tracker/features/auth/presentation/providers/reset_password_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  const password = 'new-password';

  late _MockAuthRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = _MockAuthRepository();
    container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    container.listen(resetPasswordControllerProvider, (_, _) {});
  });

  ResetPasswordController controller() => container.read(resetPasswordControllerProvider.notifier);
  AsyncValue<void> state() => container.read(resetPasswordControllerProvider);

  void stubUpdate(Future<Result<void>> Function() answer) => when(
    () => repository.updatePassword(newPassword: any(named: 'newPassword')),
  ).thenAnswer((_) => answer());

  test('is loading while saving, then succeeds', () async {
    final completer = Completer<Result<void>>();
    stubUpdate(() => completer.future);

    final pending = controller().save(password);
    expect(state().isLoading, isTrue);

    completer.complete(Result.ok);
    await pending;

    expect(state(), isA<AsyncData<void>>());
    verify(() => repository.updatePassword(newPassword: password)).called(1);
  });

  test('exposes the failure as an error', () async {
    const failure = AuthFailure('same', reason: AuthFailureReason.samePassword);
    stubUpdate(() async => const Result.failure(failure));

    await controller().save(password);

    expect(state().error, failure);
  });

  test('ignores a second save while one is in flight', () async {
    final completer = Completer<Result<void>>();
    stubUpdate(() => completer.future);

    final first = controller().save(password);
    await controller().save(password);
    completer.complete(Result.ok);
    await first;

    verify(() => repository.updatePassword(newPassword: any(named: 'newPassword'))).called(1);
  });

  test('cancel signs out', () async {
    when(() => repository.signOut()).thenAnswer((_) async => Result.ok);

    await controller().cancel();

    verify(() => repository.signOut()).called(1);
  });
}
