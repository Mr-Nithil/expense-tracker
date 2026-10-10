import 'dart:async';

import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/features/auth/data/logout_repository_provider.dart';
import 'package:expense_tracker/features/auth/domain/logout_repository.dart';
import 'package:expense_tracker/features/auth/presentation/providers/logout_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockLogoutRepository extends Mock implements LogoutRepository {}

void main() {
  late _MockLogoutRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = _MockLogoutRepository();
    container = ProviderContainer(
      overrides: [logoutRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    container.listen(logoutControllerProvider, (_, _) {});
  });

  LogoutController controller() => container.read(logoutControllerProvider.notifier);
  AsyncValue<void> state() => container.read(logoutControllerProvider);

  test('pendingChanges passes the repository count through', () async {
    when(() => repository.pendingChangesCount()).thenAnswer((_) async => const Result.success(2));
    expect((await controller().pendingChanges()).valueOrNull, 2);
  });

  test('is loading while logging out, then succeeds', () async {
    final completer = Completer<Result<void>>();
    when(() => repository.logout()).thenAnswer((_) => completer.future);

    final pending = controller().logout();
    expect(state().isLoading, isTrue);

    completer.complete(Result.ok);
    await pending;

    expect(state(), isA<AsyncData<void>>());
  });

  test('exposes a cleanup failure as an error', () async {
    const failure = StorageFailure('cleanup');
    when(() => repository.logout()).thenAnswer((_) async => const Result.failure(failure));

    await controller().logout();

    expect(state().error, failure);
  });

  test('ignores a second logout while one is in flight', () async {
    final completer = Completer<Result<void>>();
    when(() => repository.logout()).thenAnswer((_) => completer.future);

    final first = controller().logout();
    await controller().logout();
    completer.complete(Result.ok);
    await first;

    verify(() => repository.logout()).called(1);
  });
}
