import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/features/transactions/data/transaction_repository_provider.dart';
import 'package:expense_tracker/features/transactions/domain/transaction_repository.dart';
import 'package:expense_tracker/features/transactions/presentation/providers/transaction_list_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockTransactionRepository extends Mock implements TransactionRepository {}

void main() {
  late _MockTransactionRepository repository;
  late TransactionListController controller;

  setUp(() {
    repository = _MockTransactionRepository();
    final container = ProviderContainer(
      overrides: [transactionRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    controller = container.read(transactionListControllerProvider.notifier);
  });

  test('delete and restore pass the result through', () async {
    when(() => repository.delete('t1')).thenAnswer((_) async => Result.ok);
    when(() => repository.restore('t1')).thenAnswer((_) async => Result.ok);

    expect((await controller.delete('t1')).isSuccess, isTrue);
    expect((await controller.restore('t1')).isSuccess, isTrue);
  });

  test('a failure is returned, not thrown', () async {
    when(
      () => repository.delete('t1'),
    ).thenAnswer((_) async => const Result.failure(StorageFailure('db')));

    expect((await controller.delete('t1')).failureOrNull, isA<StorageFailure>());
  });
}
