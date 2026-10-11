import 'dart:async';

import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/features/transactions/data/transaction_repository_provider.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction.dart';
import 'package:expense_tracker/features/transactions/domain/transaction_repository.dart';
import 'package:expense_tracker/features/transactions/presentation/providers/transaction_form_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockTransactionRepository extends Mock implements TransactionRepository {}

void main() {
  final at = DateTime.utc(2026, 10, 11);
  final lunch = Transaction(
    id: 't1',
    type: TransactionType.expense,
    amount: const Money(1200),
    categoryId: 'food',
    occurredOn: DateTime(2026, 10, 11),
    isDeleted: false,
    createdAt: at,
    updatedAt: at,
  );

  late _MockTransactionRepository repository;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(
      TransactionDraft(
        type: TransactionType.expense,
        amount: Money.zero,
        categoryId: 'x',
        occurredOn: DateTime(2026),
      ),
    );
    registerFallbackValue(lunch);
  });

  setUp(() {
    repository = _MockTransactionRepository();
    container = ProviderContainer(
      overrides: [transactionRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    container.listen(transactionFormControllerProvider, (_, _) {});
  });

  TransactionFormController controller() =>
      container.read(transactionFormControllerProvider.notifier);
  AsyncValue<void> state() => container.read(transactionFormControllerProvider);

  Future<void> saveNew() => controller().save(
    type: TransactionType.income,
    amount: const Money(850000),
    categoryId: 'salary',
    occurredOn: DateTime(2026, 10, 1),
    note: 'October',
  );

  test('creates a new transaction from the form values', () async {
    when(() => repository.create(any())).thenAnswer((_) async => Result.success(lunch));

    await saveNew();

    final draft = verify(() => repository.create(captureAny())).captured.single as TransactionDraft;
    expect(
      draft,
      TransactionDraft(
        type: TransactionType.income,
        amount: const Money(850000),
        categoryId: 'salary',
        occurredOn: DateTime(2026, 10, 1),
        note: 'October',
      ),
    );
    expect(state(), isA<AsyncData<void>>());
  });

  test('updates an existing transaction', () async {
    when(() => repository.update(any())).thenAnswer((_) async => Result.success(lunch));

    await controller().save(
      existing: lunch,
      type: TransactionType.expense,
      amount: const Money(1500),
      categoryId: 'food',
      occurredOn: DateTime(2026, 10, 10),
    );

    final saved = verify(() => repository.update(captureAny())).captured.single as Transaction;
    expect(saved.id, 't1');
    expect(saved.amount, const Money(1500));
    expect(saved.occurredOn, DateTime(2026, 10, 10));
    verifyNever(() => repository.create(any()));
  });

  test('is loading while saving and exposes a failure as an error', () async {
    final completer = Completer<Result<Transaction>>();
    when(() => repository.create(any())).thenAnswer((_) => completer.future);

    final pending = saveNew();
    expect(state().isLoading, isTrue);

    const failure = ValidationFailure('amountNotPositive', field: 'amount');
    completer.complete(const Result.failure(failure));
    await pending;

    expect(state().error, failure);
  });

  test('ignores a second save while one is in flight', () async {
    final completer = Completer<Result<Transaction>>();
    when(() => repository.create(any())).thenAnswer((_) => completer.future);

    final first = saveNew();
    await saveNew();
    completer.complete(Result.success(lunch));
    await first;

    verify(() => repository.create(any())).called(1);
  });
}
