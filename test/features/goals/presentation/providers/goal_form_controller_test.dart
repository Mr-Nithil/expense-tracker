import 'dart:async';

import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/features/goals/data/goal_repository_provider.dart';
import 'package:expense_tracker/features/goals/domain/entities/goal.dart';
import 'package:expense_tracker/features/goals/domain/goal_repository.dart';
import 'package:expense_tracker/features/goals/domain/services/goal_validator.dart';
import 'package:expense_tracker/features/goals/presentation/providers/goal_form_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/test_database.dart';

class _MockGoalRepository extends Mock implements GoalRepository {}

void main() {
  final goal = Goal(
    id: 'g',
    name: 'Laptop',
    target: const Money(150000),
    icon: 'savings',
    color: 1,
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  );

  late _MockGoalRepository repository;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(
      const GoalDraft(name: 'x', target: Money(1), icon: 'x', color: 0),
    );
    registerFallbackValue(goal);
  });

  setUp(() {
    repository = _MockGoalRepository();
    container = ProviderContainer(
      retry: noAutoRetry,
      overrides: [goalRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    container.listen(goalFormControllerProvider, (_, _) {});
  });

  GoalFormController controller() => container.read(goalFormControllerProvider.notifier);
  AsyncValue<void> state() => container.read(goalFormControllerProvider);

  Future<void> save({Goal? existing}) => controller().save(
    existing: existing,
    name: 'Bike',
    target: const Money(40000),
    deadlineOn: DateTime(2027, 3),
    icon: 'sports',
    color: 2,
  );

  test('creates a goal from the form values', () async {
    when(() => repository.create(any())).thenAnswer((_) async => Result.success(goal));

    await save();

    final draft = verify(() => repository.create(captureAny())).captured.single as GoalDraft;
    expect(
      draft,
      GoalDraft(
        name: 'Bike',
        target: const Money(40000),
        deadlineOn: DateTime(2027, 3),
        icon: 'sports',
        color: 2,
      ),
    );
    expect(state(), isA<AsyncData<void>>());
  });

  test('updates an existing goal with the new values', () async {
    when(() => repository.update(any())).thenAnswer((_) async => Result.success(goal));

    await save(existing: goal);

    final updated = verify(() => repository.update(captureAny())).captured.single as Goal;
    expect(updated.id, 'g');
    expect(updated.name, 'Bike');
    expect(updated.deadlineOn, DateTime(2027, 3));
    expect(updated.color, 2);
  });

  test('a failed save keeps the failure for the form', () async {
    const failure = ValidationFailure(
      GoalValidator.deadlineOutOfRange,
      field: GoalValidator.deadlineField,
    );
    when(() => repository.create(any())).thenAnswer((_) async => const Result.failure(failure));

    await save();

    expect(state().error, failure);
  });

  test('ignores a second tap while saving', () async {
    final pending = Completer<Result<Goal>>();
    when(() => repository.create(any())).thenAnswer((_) => pending.future);

    final first = save();
    expect(state().isLoading, isTrue);
    await save();
    pending.complete(Result.success(goal));
    await first;

    verify(() => repository.create(any())).called(1);
  });
}
