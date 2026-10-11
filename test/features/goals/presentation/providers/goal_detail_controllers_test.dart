import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/session/session.dart';
import 'package:expense_tracker/core/utils/clock.dart';
import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/features/goals/data/goal_repository_provider.dart';
import 'package:expense_tracker/features/goals/domain/entities/goal.dart';
import 'package:expense_tracker/features/goals/domain/services/goal_validator.dart';
import 'package:expense_tracker/features/goals/presentation/providers/contribution_form_controller.dart';
import 'package:expense_tracker/features/goals/presentation/providers/goal_detail_controller.dart';
import 'package:expense_tracker/features/goals/presentation/providers/goals_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/test_database.dart';

void main() {
  late ProviderContainer container;
  late Goal goal;

  setUp(() async {
    container = createTestContainer(
      overrides: [clockProvider.overrideWithValue(FixedClock(DateTime(2026, 10, 11, 9)))],
    );
    container.read(sessionProvider.notifier).set(const SessionUser(userId: 'u1'));
    goal =
        (await container
                .read(goalRepositoryProvider)
                .create(
                  const GoalDraft(name: 'Laptop', target: Money(150000), icon: 'savings', color: 0),
                ))
            .valueOrNull!;
    container
      ..listen(goalByIdProvider(goal.id), (_, _) {})
      ..listen(goalContributionsProvider(goal.id), (_, _) {})
      ..listen(contributionFormControllerProvider, (_, _) {});
  });

  Future<void> add(int amount) => container
      .read(contributionFormControllerProvider.notifier)
      .add(goalId: goal.id, amount: Money(amount), contributedOn: DateTime(2026, 10, 5));

  test('adding money updates the saved total and the history', () async {
    await add(3000);
    await pumpEventQueue();

    expect(container.read(contributionFormControllerProvider), isA<AsyncData<void>>());
    expect((await container.read(goalByIdProvider(goal.id).future))?.saved, const Money(3000));
    expect(await container.read(goalContributionsProvider(goal.id).future), hasLength(1));
  });

  test('an invalid amount leaves the failure for the form', () async {
    await add(0);

    expect(
      (container.read(contributionFormControllerProvider).error! as ValidationFailure).message,
      GoalValidator.amountNotPositive,
    );
  });

  test('a contribution can be removed and restored', () async {
    await add(3000);
    await pumpEventQueue();
    final id = (await container.read(goalContributionsProvider(goal.id).future)).single.id;
    final detail = container.read(goalDetailControllerProvider.notifier);

    expect(await detail.deleteContribution(id), Result.ok);
    await pumpEventQueue();
    expect((await container.read(goalByIdProvider(goal.id).future))?.saved, Money.zero);

    expect(await detail.restoreContribution(id), Result.ok);
    await pumpEventQueue();
    expect((await container.read(goalByIdProvider(goal.id).future))?.saved, const Money(3000));
  });

  test('deleting the goal makes it disappear', () async {
    expect(
      await container.read(goalDetailControllerProvider.notifier).deleteGoal(goal.id),
      Result.ok,
    );
    await pumpEventQueue();

    expect(await container.read(goalByIdProvider(goal.id).future), isNull);
  });
}
