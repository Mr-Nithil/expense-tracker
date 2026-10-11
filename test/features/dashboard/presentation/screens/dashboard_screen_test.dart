import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/l10n/generated/app_localizations_en.dart';
import 'package:expense_tracker/core/sync/sync_status.dart';
import 'package:expense_tracker/core/utils/clock.dart';
import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/core/widgets/sync_status_indicator.dart';
import 'package:expense_tracker/features/budget/domain/entities/budget_overview.dart';
import 'package:expense_tracker/features/budget/presentation/providers/budget_providers.dart';
import 'package:expense_tracker/features/categories/domain/entities/category.dart';
import 'package:expense_tracker/features/categories/presentation/providers/categories_providers.dart';
import 'package:expense_tracker/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:expense_tracker/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:expense_tracker/features/dashboard/presentation/widgets/dashboard_budget_section.dart';
import 'package:expense_tracker/features/dashboard/presentation/widgets/dashboard_heatmap_section.dart';
import 'package:expense_tracker/features/dashboard/presentation/widgets/dashboard_recent_section.dart';
import 'package:expense_tracker/features/dashboard/presentation/widgets/dashboard_spending_section.dart';
import 'package:expense_tracker/features/dashboard/presentation/widgets/dashboard_summary_cards.dart';
import 'package:expense_tracker/features/profile/domain/entities/profile.dart';
import 'package:expense_tracker/features/profile/presentation/providers/profile_providers.dart';
import 'package:expense_tracker/features/transactions/domain/entities/month_totals.dart';
import 'package:expense_tracker/features/transactions/domain/entities/spending_breakdown.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction.dart';
import 'package:expense_tracker/features/transactions/presentation/providers/transactions_providers.dart';
import 'package:expense_tracker/features/transactions/presentation/shared/transaction_form_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show ProviderScope;
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fake_sync_trigger.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  final l10n = AppLocalizationsEn();
  final now = DateTime(2026, 10, 11, 9);
  final october = DateTime(2026, 10);
  final september = DateTime(2026, 9);
  const octoberTotals = MonthTotals(income: Money(500000), expense: Money(120050));

  final sync = syncStatusProvider.overrideWith(
    (ref) => Stream.value(const SyncStatusInfo(SyncIndicator.synced)),
  );

  List<Override> overrides(Stream<MonthTotals> Function() totals) => [
    clockProvider.overrideWithValue(FixedClock(now)),
    currencyCodeProvider.overrideWith((ref) async => 'USD'),
    monthTotalsProvider(october).overrideWith((ref) => totals()),
    spendingBreakdownProvider(october).overrideWith((ref) => Stream.value(SpendingBreakdown.empty)),
    monthDailyTotalsProvider(october).overrideWith((ref) => Stream.value({})),
    monthDailyTotalsProvider(september).overrideWith((ref) => Stream.value({})),
    budgetOverviewProvider(october).overrideWith((ref) => Stream.value(const BudgetOverview())),
    transactionsProvider(TransactionFilter(month: october)).overrideWith((ref) => Stream.value([])),
    transactionsProvider(TransactionFilter(month: september)).overrideWith(
      (ref) => Stream.value([]),
    ),
    budgetOverviewProvider(september).overrideWith((ref) => Stream.value(const BudgetOverview())),
    spendingBreakdownProvider(september).overrideWith(
      (ref) => Stream.value(SpendingBreakdown.empty),
    ),
    monthTotalsProvider(september).overrideWith(
      (ref) => Stream.value(const MonthTotals(income: Money(0), expense: Money(4200))),
    ),
    sync,
  ];

  Future<void> pumpScreen(WidgetTester tester, {Brightness brightness = Brightness.light}) async {
    await tester.pumpApp(
      const DashboardScreen(),
      brightness: brightness,
      overrides: overrides(() => Stream.value(octoberTotals)),
    );
    await tester.pumpAndSettle();
  }

  testWidgetsBothThemes('shows this month\'s summary', (tester, brightness) async {
    await pumpScreen(tester, brightness: brightness);

    expect(find.text(l10n.dashboardTitle), findsOneWidget);
    expect(find.text('October 2026'), findsOneWidget);
    expect(find.byType(DashboardSummaryCards), findsOneWidget);
    expect(find.text(r'$3,799.50'), findsOneWidget);
    expect(find.byType(DashboardHeatmapSection), findsOneWidget);
    await tester.scrollUntilVisible(find.byType(DashboardSpendingSection), 200);
    expect(find.byType(DashboardSpendingSection), findsOneWidget);
    await tester.scrollUntilVisible(find.byType(DashboardBudgetSection), 200);
    expect(find.byType(DashboardBudgetSection), findsOneWidget);
    await tester.scrollUntilVisible(find.byType(DashboardRecentSection), 200);
    expect(find.byType(DashboardRecentSection), findsOneWidget);
  });

  testWidgets('the + button opens the add-transaction sheet', (tester) async {
    await tester.pumpApp(
      const DashboardScreen(),
      overrides: [
        ...overrides(() => Stream.value(octoberTotals)),
        categoriesProvider(CategoryType.expense).overrideWith((ref) => Stream.value([])),
      ],
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip(l10n.transactionsAdd));
    await tester.pumpAndSettle();

    expect(find.byType(TransactionFormSheet), findsOneWidget);
    expect(find.text(l10n.transactionFormNewTitle), findsOneWidget);
  });

  testWidgets('the app bar shows the sync state', (tester) async {
    await pumpScreen(tester);

    expect(find.byType(SyncStatusIndicator), findsOneWidget);
  });

  testWidgets('the previous month shows that month\'s totals', (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.byTooltip(l10n.commonPreviousMonth));
    await tester.pumpAndSettle();

    expect(find.text('September 2026'), findsOneWidget);
    expect(find.text(r'-$42.00'), findsOneWidget);
  });

  testWidgets('cannot go past the last month that can hold transactions', (tester) async {
    await pumpScreen(tester);
    final last = DashboardMonthController.monthBounds(now).last;
    ProviderScope.containerOf(
      tester.element(find.byType(DashboardScreen)),
    ).read(dashboardMonthControllerProvider.notifier).setMonth(last);
    await tester.pumpAndSettle();

    final next = tester.widget<IconButton>(
      find.ancestor(of: find.byTooltip(l10n.commonNextMonth), matching: find.byType(IconButton)),
    );
    expect(next.onPressed, isNull);
  });

  testWidgets('an error offers a retry that reloads', (tester) async {
    var loads = 0;
    await tester.pumpApp(
      const DashboardScreen(),
      overrides: overrides(() {
        loads++;
        return loads == 1 ? Stream.error(const StorageFailure('db')) : Stream.value(octoberTotals);
      }),
    );
    await tester.pumpAndSettle();
    expect(find.text(l10n.errorStorage), findsOneWidget);

    await tester.tap(find.text(l10n.commonRetry));
    await tester.pumpAndSettle();

    expect(find.byType(DashboardSummaryCards), findsOneWidget);
  });

  testWidgets('a failed profile (currency) load offers a retry', (tester) async {
    var loads = 0;
    await tester.pumpApp(
      const DashboardScreen(),
      overrides: [
        clockProvider.overrideWithValue(FixedClock(now)),
        profileProvider.overrideWith((ref) {
          loads++;
          return loads == 1
              ? Stream.error(const StorageFailure('db'))
              : Stream.value(const Profile(id: 'u1', currencyCode: 'USD'));
        }),
        monthTotalsProvider(october).overrideWith((ref) => Stream.value(octoberTotals)),
        spendingBreakdownProvider(october).overrideWith(
          (ref) => Stream.value(SpendingBreakdown.empty),
        ),
        monthDailyTotalsProvider(october).overrideWith((ref) => Stream.value({})),
        budgetOverviewProvider(october).overrideWith((ref) => Stream.value(const BudgetOverview())),
        transactionsProvider(TransactionFilter(month: october)).overrideWith(
          (ref) => Stream.value([]),
        ),
        sync,
      ],
    );
    await tester.pumpAndSettle();
    expect(find.text(l10n.errorStorage), findsOneWidget);

    await tester.tap(find.text(l10n.commonRetry));
    await tester.pumpAndSettle();

    expect(find.byType(DashboardSummaryCards), findsOneWidget);
  });

  group('pull to refresh', () {
    late FakeSyncTrigger trigger;

    setUp(() => trigger = FakeSyncTrigger());

    Future<void> pull(WidgetTester tester) async {
      await tester.pumpApp(
        const DashboardScreen(),
        overrides: [...overrides(() => Stream.value(octoberTotals)), trigger.providerOverride],
      );
      await tester.pumpAndSettle();
      await tester.fling(find.byType(DashboardSummaryCards), const Offset(0, 500), 1000);
      await tester.pumpAndSettle();
    }

    testWidgets('pulling the dashboard syncs now', (tester) async {
      await pull(tester);

      expect(trigger.immediate, 1);
    });

    testWidgets('a failed sync says why', (tester) async {
      trigger.nowResult = const Result.failure(NetworkFailure('offline'));

      await pull(tester);

      expect(find.text(l10n.errorNetwork), findsOneWidget);
    });
  });
}
