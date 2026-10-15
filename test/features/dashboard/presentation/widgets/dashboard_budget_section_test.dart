import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/l10n/generated/app_localizations_en.dart';
import 'package:expense_tracker/core/router/routes.dart';
import 'package:expense_tracker/core/utils/clock.dart';
import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/core/widgets/progress_bar.dart';
import 'package:expense_tracker/features/budget/domain/entities/budget.dart';
import 'package:expense_tracker/features/budget/domain/entities/budget_overview.dart';
import 'package:expense_tracker/features/budget/domain/entities/budget_progress.dart';
import 'package:expense_tracker/features/budget/presentation/providers/budget_providers.dart';
import 'package:expense_tracker/features/budget/presentation/shared/budget_overall_card.dart';
import 'package:expense_tracker/features/budget/presentation/shared/budget_progress_tile.dart';
import 'package:expense_tracker/features/categories/domain/entities/category.dart';
import 'package:expense_tracker/features/categories/presentation/providers/categories_providers.dart';
import 'package:expense_tracker/features/dashboard/presentation/widgets/dashboard_budget_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  final l10n = AppLocalizationsEn();
  final now = DateTime(2026, 10, 11, 9);
  final september = DateTime(2026, 9);
  final at = DateTime.utc(2026, 9, 1);

  BudgetProgress progress(String id, int spent, {String? categoryId}) => BudgetProgress(
    budget: Budget(
      id: id,
      month: september,
      categoryId: categoryId,
      limit: const Money(10000),
      createdAt: at,
      updatedAt: at,
    ),
    spent: Money(spent),
  );

  Category category(String id) => Category(
    id: id,
    name: id,
    icon: 'food',
    color: 0xFFEF6C00,
    type: CategoryType.expense,
    isDefault: false,
    sortOrder: 0,
    isArchived: false,
    createdAt: at,
    updatedAt: at,
  );

  final ids = ['Low', 'Over', 'High', 'Mid'];
  final full = BudgetOverview(
    overall: progress('overall', 4000),
    categories: [
      progress('Low', 1000, categoryId: 'Low'),
      progress('Over', 12000, categoryId: 'Over'),
      progress('High', 8500, categoryId: 'High'),
      progress('Mid', 5000, categoryId: 'Mid'),
    ],
  );

  List<Override> overrides(Stream<BudgetOverview> Function() overview) => [
    clockProvider.overrideWithValue(FixedClock(now)),
    budgetOverviewProvider(september).overrideWith((ref) => overview()),
    for (final id in ids)
      categoryByIdProvider(id).overrideWith((ref) => Stream.value(category(id))),
  ];

  /// The section on a dashboard route, and a Budget route that shows its month.
  Future<void> pump(
    WidgetTester tester,
    Stream<BudgetOverview> Function() overview, {
    Brightness brightness = Brightness.light,
  }) => tester.pumpRouterApp(
    initialLocation: Routes.dashboardPath,
    brightness: brightness,
    overrides: overrides(overview),
    routes: [
      GoRoute(
        name: Routes.dashboard,
        path: Routes.dashboardPath,
        builder: (_, _) => Scaffold(
          body: SingleChildScrollView(
            child: DashboardBudgetSection(month: september, currencyCode: 'USD'),
          ),
        ),
      ),
      GoRoute(
        name: Routes.budget,
        path: Routes.budgetPath,
        builder: (_, _) => Consumer(
          builder: (_, ref, _) => Text('budget ${ref.watch(budgetMonthControllerProvider)}'),
        ),
      ),
    ],
  );

  testWidgetsBothThemes('shows the overall card and the three most used category budgets', (
    tester,
    brightness,
  ) async {
    await pump(tester, () => Stream.value(full), brightness: brightness);

    expect(findText(l10n.dashboardBudgetsTitle), findsOneWidget);
    expect(find.byType(BudgetOverallCard), findsOneWidget);
    final names = [
      for (final tile in tester.widgetList<BudgetProgressTile>(find.byType(BudgetProgressTile)))
        tile.progress.budget.categoryId,
    ];
    expect(names, ['Over', 'High', 'Mid']);
    expect(findText('Low'), findsNothing);
  });

  testWidgets('budget states look as on the Budget tab', (tester) async {
    await pump(tester, () => Stream.value(full));

    final levels = [
      for (final bar in tester.widgetList<ProgressBar>(find.byType(ProgressBar))) bar.level,
    ];
    // Overall 40%, then Over 120%, High 85%, Mid 50%.
    expect(levels, [
      ProgressLevel.normal,
      ProgressLevel.exceeded,
      ProgressLevel.warning,
      ProgressLevel.normal,
    ]);
    expect(findText(l10n.budgetStatusExceeded), findsOneWidget);
    expect(findText(l10n.budgetStatusWarning), findsOneWidget);
  });

  testWidgets('See all opens the Budget tab on the same month', (tester) async {
    await pump(tester, () => Stream.value(full));

    await tester.tap(findText(l10n.commonSeeAll));
    await tester.pumpAndSettle();

    expect(findText('budget $september'), findsOneWidget);
  });

  testWidgets('tapping a budget opens the Budget tab on the same month', (tester) async {
    await pump(tester, () => Stream.value(full));

    await tester.tap(findText('Over'));
    await tester.pumpAndSettle();

    expect(findText('budget $september'), findsOneWidget);
  });

  testWidgets('a month without budgets offers to set one', (tester) async {
    await pump(tester, () => Stream.value(const BudgetOverview()));

    expect(findText(l10n.dashboardBudgetsEmpty('September 2026')), findsOneWidget);
    expect(find.byType(BudgetOverallCard), findsNothing);

    await tester.tap(findText(l10n.dashboardBudgetsSet));
    await tester.pumpAndSettle();

    expect(findText('budget $september'), findsOneWidget);
  });

  testWidgets('only category budgets: the card says no overall budget is set', (tester) async {
    await pump(
      tester,
      () => Stream.value(BudgetOverview(categories: [progress('Mid', 5000, categoryId: 'Mid')])),
    );

    expect(findText(l10n.budgetOverallEmptyTitle), findsOneWidget);
    expect(find.byType(BudgetProgressTile), findsOneWidget);
  });

  testWidgets('an error offers a retry that reloads', (tester) async {
    var loads = 0;
    await pump(tester, () {
      loads++;
      return loads == 1 ? Stream.error(const StorageFailure('db')) : Stream.value(full);
    });
    expect(findText(l10n.errorStorage), findsOneWidget);

    await tester.tap(findText(l10n.commonRetry));
    await tester.pumpAndSettle();

    expect(find.byType(BudgetOverallCard), findsOneWidget);
  });
}
