import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/l10n/generated/app_localizations_en.dart';
import 'package:expense_tracker/core/router/routes.dart';
import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/features/dashboard/presentation/widgets/dashboard_goals_section.dart';
import 'package:expense_tracker/features/goals/domain/entities/goal.dart';
import 'package:expense_tracker/features/goals/domain/entities/goal_progress.dart';
import 'package:expense_tracker/features/goals/presentation/providers/goals_providers.dart';
import 'package:expense_tracker/features/goals/presentation/shared/goal_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  final l10n = AppLocalizationsEn();

  GoalProgress goal(String id, int target, int saved) => GoalProgress(
    goal: Goal(
      id: id,
      name: id,
      target: Money(target),
      icon: 'savings',
      color: 0,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    ),
    saved: Money(saved),
  );

  final goals = [
    goal('Laptop', 150000, 50000),
    goal('Bike', 40000, 40000),
    goal('Trip', 90000, 81000),
    goal('Car', 900000, 9000),
    goal('Phone', 80000, 40000),
  ];

  Future<void> pump(
    WidgetTester tester,
    Stream<List<GoalProgress>> Function() stream, {
    Brightness brightness = Brightness.light,
  }) => tester.pumpRouterApp(
    initialLocation: Routes.dashboardPath,
    brightness: brightness,
    overrides: [goalsProvider.overrideWith((ref) => stream())],
    routes: [
      GoRoute(
        name: Routes.dashboard,
        path: Routes.dashboardPath,
        builder: (_, _) => const Scaffold(
          body: SingleChildScrollView(child: DashboardGoalsSection(currencyCode: 'USD')),
        ),
      ),
      GoRoute(
        name: Routes.goals,
        path: Routes.goalsPath,
        builder: (_, _) => const Text('goals tab'),
        routes: [
          GoRoute(
            name: Routes.goalDetail,
            path: ':${Routes.goalIdParam}',
            builder: (_, state) => Text('goal ${state.pathParameters[Routes.goalIdParam]}'),
          ),
        ],
      ),
    ],
  );

  testWidgetsBothThemes('shows totals, reached count and the three closest unfinished goals', (
    tester,
    brightness,
  ) async {
    await pump(tester, () => Stream.value(goals), brightness: brightness);

    expect(findText(l10n.goalsTitle), findsOneWidget);
    expect(findText(l10n.dashboardGoalsTotal(r'$2,200.00', r'$12,600.00')), findsOneWidget);
    expect(findText(l10n.dashboardGoalsReached(1)), findsOneWidget);
    final shown = [
      for (final tile in tester.widgetList<GoalTile>(find.byType(GoalTile))) tile.progress.goal.id,
    ];
    expect(shown, ['Trip', 'Phone', 'Laptop']);
  });

  testWidgets('without reached goals the count is not shown', (tester) async {
    await pump(tester, () => Stream.value([goal('Laptop', 150000, 50000)]));

    expect(find.textContaining('reached'), findsNothing);
  });

  testWidgets('See all opens the Goals tab', (tester) async {
    await pump(tester, () => Stream.value(goals));

    await tester.tap(findText(l10n.commonSeeAll));
    await tester.pumpAndSettle();

    expect(findText('goals tab'), findsOneWidget);
  });

  testWidgets('a goal opens its page', (tester) async {
    await pump(tester, () => Stream.value(goals));

    await tester.tap(findText('Trip'));
    await tester.pumpAndSettle();

    expect(findText('goal Trip'), findsOneWidget);
  });

  testWidgets('without goals it offers to set one', (tester) async {
    await pump(tester, () => Stream.value(const []));

    expect(findText(l10n.dashboardGoalsEmpty), findsOneWidget);
    await tester.tap(findText(l10n.dashboardGoalsSet));
    await tester.pumpAndSettle();

    expect(findText('goals tab'), findsOneWidget);
  });

  testWidgets('an error offers a retry that reloads', (tester) async {
    var loads = 0;
    await pump(tester, () {
      loads++;
      return loads == 1 ? Stream.error(const StorageFailure('db')) : Stream.value(goals);
    });
    expect(findText(l10n.errorStorage), findsOneWidget);

    await tester.tap(findText(l10n.commonRetry));
    await tester.pumpAndSettle();

    expect(find.byType(GoalTile), findsNWidgets(3));
  });
}
