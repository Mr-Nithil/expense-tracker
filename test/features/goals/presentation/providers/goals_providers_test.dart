import 'package:expense_tracker/core/session/session.dart';
import 'package:expense_tracker/core/utils/clock.dart';
import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/features/goals/data/goal_repository_provider.dart';
import 'package:expense_tracker/features/goals/domain/entities/goal.dart';
import 'package:expense_tracker/features/goals/domain/entities/goal_contribution.dart';
import 'package:expense_tracker/features/goals/presentation/providers/goals_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/test_database.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = createTestContainer(
      overrides: [clockProvider.overrideWithValue(FixedClock(DateTime(2026, 10, 11, 9)))],
    );
    container.read(sessionProvider.notifier).set(const SessionUser(userId: 'u1'));
  });

  test('lists goals and re-subscribes for a different user', () async {
    container.listen(goalsProvider, (_, _) {});
    final result = await container
        .read(goalRepositoryProvider)
        .create(
          const GoalDraft(name: 'Laptop', target: Money(150000), icon: 'savings', color: 0),
        );
    expect(result.isSuccess, isTrue);
    await pumpEventQueue();

    expect((await container.read(goalsProvider.future)).single.goal.name, 'Laptop');

    container.read(sessionProvider.notifier).set(const SessionUser(userId: 'u2'));
    await pumpEventQueue();

    expect(await container.read(goalsProvider.future), isEmpty);
  });

  test('goalsSummary totals the goals', () async {
    container.listen(goalsSummaryProvider, (_, _) {});
    final repository = container.read(goalRepositoryProvider);
    final goal = (await repository.create(
      const GoalDraft(name: 'Bike', target: Money(40000), icon: 'savings', color: 0),
    )).valueOrNull!;
    await repository.addContribution(
      ContributionDraft(
        goalId: goal.id,
        amount: const Money(10000),
        contributedOn: DateTime(2026, 10, 1),
      ),
    );
    await pumpEventQueue();

    final summary = container.read(goalsSummaryProvider).requireValue;
    expect(summary.totalSaved, const Money(10000));
    expect(summary.totalTarget, const Money(40000));
    expect(summary.top.single.goal.name, 'Bike');
  });
}
