import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/features/budget/data/budget_repository_provider.dart';
import 'package:expense_tracker/features/budget/domain/budget_repository.dart';
import 'package:expense_tracker/features/budget/presentation/providers/budget_list_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockBudgetRepository extends Mock implements BudgetRepository {}

void main() {
  test('copies the previous month (across a year boundary) into the month', () async {
    final repository = _MockBudgetRepository();
    final container = ProviderContainer(
      overrides: [budgetRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    when(
      () => repository.copyMonth(from: DateTime(2025, 12), to: DateTime(2026)),
    ).thenAnswer((_) async => const Result.success(3));

    final result = await container
        .read(budgetListControllerProvider.notifier)
        .copyPreviousMonth(DateTime(2026));

    expect(result.valueOrNull, 3);
  });
}
