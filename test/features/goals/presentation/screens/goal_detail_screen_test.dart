import 'package:expense_tracker/core/db/database_provider.dart';
import 'package:expense_tracker/core/l10n/generated/app_localizations_en.dart';
import 'package:expense_tracker/core/router/routes.dart';
import 'package:expense_tracker/core/session/session.dart';
import 'package:expense_tracker/core/sync/sync_status.dart';
import 'package:expense_tracker/core/utils/clock.dart';
import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/features/goals/data/goal_repository_provider.dart';
import 'package:expense_tracker/features/goals/domain/entities/goal.dart';
import 'package:expense_tracker/features/goals/domain/entities/goal_contribution.dart';
import 'package:expense_tracker/features/goals/presentation/screens/goal_detail_screen.dart';
import 'package:expense_tracker/features/goals/presentation/screens/goals_screen.dart';
import 'package:expense_tracker/features/goals/presentation/widgets/contribution_form_sheet.dart';
import 'package:expense_tracker/features/goals/presentation/widgets/contribution_tile.dart';
import 'package:expense_tracker/features/goals/presentation/widgets/goal_form_sheet.dart';
import 'package:expense_tracker/features/goals/presentation/widgets/goal_summary.dart';
import 'package:expense_tracker/features/profile/presentation/providers/profile_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../../helpers/accessibility.dart';
import '../../../../helpers/fake_sync_trigger.dart';
import '../../../../helpers/pump_app.dart';
import '../../../../helpers/test_database.dart';

void main() {
  final l10n = AppLocalizationsEn();
  final now = DateTime(2026, 10, 11, 9);

  late ProviderContainer container;
  late Goal goal;

  /// The real repository on an in-memory DB, with the Goals list and a goal's page as routes.
  Future<void> pump(
    WidgetTester tester, {
    List<int> contributions = const [3000, 2000],
    Brightness brightness = Brightness.light,
  }) async {
    await tester.pumpRouterApp(
      initialLocation: Routes.goalsPath,
      brightness: brightness,
      overrides: [
        // Never reach Supabase: in-memory DB, fake sync trigger and status.
        databaseProvider.overrideWithValue(createTestDatabase()),
        FakeSyncTrigger().providerOverride,
        syncStatusProvider.overrideWith(
          (ref) => Stream.value(const SyncStatusInfo(SyncIndicator.synced)),
        ),
        clockProvider.overrideWithValue(FixedClock(now)),
        currencyCodeProvider.overrideWith((ref) async => 'USD'),
      ],
      routes: [
        GoRoute(
          name: Routes.goals,
          path: Routes.goalsPath,
          builder: (_, _) => const GoalsScreen(),
          routes: [
            GoRoute(
              name: Routes.goalDetail,
              path: ':${Routes.goalIdParam}',
              builder: (_, state) =>
                  GoalDetailScreen(id: state.pathParameters[Routes.goalIdParam]!),
            ),
          ],
        ),
      ],
    );
    container = ProviderScope.containerOf(tester.element(find.byType(GoalsScreen)));
    container.read(sessionProvider.notifier).set(const SessionUser(userId: 'u1'));
    final repository = container.read(goalRepositoryProvider);
    await tester.runAsync(() async {
      goal = (await repository.create(
        GoalDraft(
          name: 'Laptop',
          target: const Money(150000),
          deadlineOn: DateTime(2027, 1, 15),
          icon: 'savings',
          color: 0,
        ),
      )).valueOrNull!;
      for (final (i, amount) in contributions.indexed) {
        await repository.addContribution(
          ContributionDraft(
            goalId: goal.id,
            amount: Money(amount),
            contributedOn: DateTime(2026, 10, 1 + i),
            note: 'n$i',
          ),
        );
      }
    });
    await tester.pumpAndSettle();
    await tester.tap(find.text('Laptop'));
    await tester.pumpAndSettle();
  }

  testWidgets('tapping a goal in the list opens its page', (tester) async {
    await pump(tester);

    expect(find.byType(GoalDetailScreen), findsOneWidget);
    expect(find.widgetWithText(AppBar, 'Laptop'), findsOneWidget);
    expect(find.byType(GoalSummary), findsOneWidget);
    expect(find.text(l10n.goalsSavedOfTarget(r'$50.00', r'$1,500.00')), findsOneWidget);
  });

  testWidgets('lists the history newest first', (tester) async {
    await pump(tester);

    final dates = [
      for (final tile in tester.widgetList<ContributionTile>(find.byType(ContributionTile)))
        tile.contribution.contributedOn,
    ];
    expect(dates, [DateTime(2026, 10, 2), DateTime(2026, 10)]);
  });

  testWidgets('without contributions the history says so', (tester) async {
    await pump(tester, contributions: const []);

    expect(find.text(l10n.goalDetailHistoryEmpty), findsOneWidget);
  });

  testWidgets('"Add money" opens the sheet for this goal', (tester) async {
    await pump(tester);

    await tester.tap(find.text(l10n.goalsAddMoney));
    await tester.pumpAndSettle();

    expect(
      tester.widget<ContributionFormSheet>(find.byType(ContributionFormSheet)).goalId,
      goal.id,
    );
  });

  testWidgets('Edit opens the goal form', (tester) async {
    await pump(tester);

    await tester.tap(find.byTooltip(l10n.commonEdit));
    await tester.pumpAndSettle();

    expect(tester.widget<GoalFormSheet>(find.byType(GoalFormSheet)).goal?.id, goal.id);
  });

  testWidgets('swiping a contribution removes it, and Undo brings it back', (tester) async {
    await pump(tester);

    await tester.fling(find.text('n1'), const Offset(-500, 0), 1000);
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pumpAndSettle();

    expect(find.text('n1'), findsNothing);
    expect(find.text(l10n.goalContributionDeleted), findsOneWidget);
    expect(find.text(l10n.goalsSavedOfTarget(r'$30.00', r'$1,500.00')), findsOneWidget);

    await tester.tap(find.text(l10n.commonUndo));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pumpAndSettle();

    expect(find.text('n1'), findsOneWidget);
    expect(find.text(l10n.goalsSavedOfTarget(r'$50.00', r'$1,500.00')), findsOneWidget);
  });

  testWidgets('Delete asks first, then closes the page and removes the goal', (tester) async {
    await pump(tester);

    await tester.tap(find.byTooltip(l10n.goalDetailDelete));
    await tester.pumpAndSettle();
    expect(find.text(l10n.goalDeleteConfirmTitle('Laptop')), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, l10n.commonDelete));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pumpAndSettle();

    expect(find.byType(GoalDetailScreen), findsNothing);
    expect(find.text(l10n.goalsEmptyTitle), findsOneWidget);
    expect(find.text(l10n.goalDetailMissingTitle), findsNothing);
  });

  testWidgets('a goal deleted elsewhere shows "not found"', (tester) async {
    await pump(tester);

    await tester.runAsync(() => container.read(goalRepositoryProvider).delete(goal.id));
    await tester.pumpAndSettle();

    expect(find.text(l10n.goalDetailMissingTitle), findsOneWidget);
  });

  group('accessibility (M9.5)', () {
    testWidgetsBothThemes('meets the guidelines', (tester, brightness) async {
      await pump(tester, brightness: brightness);
      await expectAccessible(tester);
    });

    testWidgets('large text (2x) fits', (tester) async {
      useTextScale(tester, 2);
      await pump(tester);
      await scrollThrough(tester);
    });
  });
}
