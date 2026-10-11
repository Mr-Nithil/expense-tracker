import 'dart:async';

import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/features/budget/data/budget_repository_provider.dart';
import 'package:expense_tracker/features/budget/domain/budget_repository.dart';
import 'package:expense_tracker/features/budget/domain/entities/budget.dart';
import 'package:expense_tracker/features/budget/presentation/providers/budget_form_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/test_database.dart';

class _MockBudgetRepository extends Mock implements BudgetRepository {}

void main() {
  final october = DateTime(2026, 10);
  final budget = Budget(
    id: 'b1',
    month: october,
    categoryId: 'food',
    limit: const Money(20000),
    createdAt: DateTime.utc(2026, 10),
    updatedAt: DateTime.utc(2026, 10),
  );

  late _MockBudgetRepository repository;
  late ProviderContainer container;

  setUpAll(() => registerFallbackValue(const Money(0)));

  setUp(() {
    repository = _MockBudgetRepository();
    container = ProviderContainer(
      retry: noAutoRetry,
      overrides: [budgetRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    container.listen(budgetFormControllerProvider, (_, _) {});
  });

  BudgetFormController controller() => container.read(budgetFormControllerProvider.notifier);
  AsyncValue<void> state() => container.read(budgetFormControllerProvider);

  test('sets the budget from the form values', () async {
    when(
      () => repository.set(
        month: any(named: 'month'),
        categoryId: any(named: 'categoryId'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => Result.success(budget));

    await controller().save(month: october, categoryId: 'food', limit: const Money(20000));

    verify(
      () => repository.set(month: october, categoryId: 'food', limit: const Money(20000)),
    ).called(1);
    expect(state(), isA<AsyncData<void>>());
  });

  test('a failed save keeps the failure for the form', () async {
    const failure = ValidationFailure('limitNotPositive', field: 'limit');
    when(
      () => repository.set(
        month: any(named: 'month'),
        categoryId: any(named: 'categoryId'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => const Result.failure(failure));

    await controller().save(month: october, limit: const Money(0));

    expect(state().error, failure);
  });

  test('removes the budget', () async {
    when(() => repository.delete('b1')).thenAnswer((_) async => Result.ok);

    await controller().remove('b1');

    verify(() => repository.delete('b1')).called(1);
    expect(state(), isA<AsyncData<void>>());
  });

  test('ignores a second tap while busy', () async {
    final pending = Completer<Result<void>>();
    when(() => repository.delete('b1')).thenAnswer((_) => pending.future);

    final first = controller().remove('b1');
    expect(state().isLoading, isTrue);
    await controller().remove('b1');
    pending.complete(Result.ok);
    await first;

    verify(() => repository.delete('b1')).called(1);
  });
}
