import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/l10n/generated/app_localizations_en.dart';
import 'package:expense_tracker/core/l10n/generated/app_localizations_si.dart';
import 'package:expense_tracker/core/sync/sync_status.dart';
import 'package:expense_tracker/core/utils/clock.dart';
import 'package:expense_tracker/core/utils/date_utils.dart';
import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/core/widgets/sync_status_indicator.dart';
import 'package:expense_tracker/features/budget/data/budget_repository_provider.dart';
import 'package:expense_tracker/features/budget/domain/budget_repository.dart';
import 'package:expense_tracker/features/budget/domain/entities/budget.dart';
import 'package:expense_tracker/features/budget/domain/entities/budget_overview.dart';
import 'package:expense_tracker/features/budget/domain/entities/budget_progress.dart';
import 'package:expense_tracker/features/budget/presentation/providers/budget_providers.dart';
import 'package:expense_tracker/features/budget/presentation/screens/budget_screen.dart';
import 'package:expense_tracker/features/budget/presentation/shared/budget_overall_card.dart';
import 'package:expense_tracker/features/budget/presentation/shared/budget_progress_tile.dart';
import 'package:expense_tracker/features/budget/presentation/widgets/budget_form_sheet.dart';
import 'package:expense_tracker/features/categories/domain/entities/category.dart';
import 'package:expense_tracker/features/categories/presentation/providers/categories_providers.dart';
import 'package:expense_tracker/features/profile/domain/entities/profile.dart';
import 'package:expense_tracker/features/profile/presentation/providers/profile_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show ProviderScope;
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/accessibility.dart';
import '../../../../helpers/fake_sync_trigger.dart';
import '../../../../helpers/pump_app.dart';

class _MockBudgetRepository extends Mock implements BudgetRepository {}

void main() {
  final l10n = AppLocalizationsEn();
  final now = DateTime(2026, 10, 11, 9);
  final october = DateTime(2026, 10);
  final september = DateTime(2026, 9);
  final at = DateTime.utc(2026, 10, 1);
  final food = Category(
    id: 'food',
    name: 'Food',
    icon: 'food',
    color: 0xFFEF6C00,
    type: CategoryType.expense,
    isDefault: true,
    sortOrder: 0,
    isArchived: false,
    createdAt: at,
    updatedAt: at,
  );

  BudgetProgress progress(int limit, int spent, {String? categoryId, DateTime? month}) =>
      BudgetProgress(
        budget: Budget(
          id: categoryId ?? 'overall',
          month: month ?? october,
          categoryId: categoryId,
          limit: Money(limit),
          createdAt: at,
          updatedAt: at,
        ),
        spent: Money(spent),
      );

  final full = BudgetOverview(
    overall: progress(50000, 12500),
    categories: [progress(20000, 5000, categoryId: 'food')],
  );

  List<Override> overrides(
    Stream<BudgetOverview> Function() overview, {
    Map<DateTime, BudgetOverview> others = const {},
  }) => [
    for (final MapEntry(key: month, value: other) in others.entries)
      budgetOverviewProvider(month).overrideWith((ref) => Stream.value(other)),
    clockProvider.overrideWithValue(FixedClock(now)),
    currencyCodeProvider.overrideWith((ref) async => 'USD'),
    budgetOverviewProvider(october).overrideWith((ref) => overview()),
    categoryByIdProvider('food').overrideWith((ref) => Stream.value(food)),
    categoriesProvider(CategoryType.expense).overrideWith((ref) => Stream.value([food])),
    syncStatusProvider.overrideWith(
      (ref) => Stream.value(const SyncStatusInfo(SyncIndicator.synced)),
    ),
  ];

  Future<void> pumpScreen(
    WidgetTester tester,
    BudgetOverview overview, {
    Brightness brightness = Brightness.light,
    List<Override> extra = const [],
    Locale locale = const Locale('en', 'US'),
  }) async {
    await tester.pumpApp(
      const BudgetScreen(),
      brightness: brightness,
      locale: locale,
      overrides: [...overrides(() => Stream.value(overview)), ...extra],
    );
    await tester.pumpAndSettle();
  }

  testWidgetsBothThemes('shows the overall card and the category budgets', (
    tester,
    brightness,
  ) async {
    await pumpScreen(tester, full, brightness: brightness);

    expect(findText('October 2026'), findsOneWidget);
    expect(find.byType(BudgetOverallCard), findsOneWidget);
    expect(findText(l10n.budgetOverallTitle), findsOneWidget);
    expect(findText(l10n.budgetSpentOfLimit(r'$125.00', r'$500.00')), findsOneWidget);
    expect(findText(l10n.budgetCategoriesHeader), findsOneWidget);
    expect(find.byType(BudgetProgressTile), findsOneWidget);
    expect(findText('Food'), findsOneWidget);
  });

  testWidgets('renders in Sinhala without overflow', (tester) async {
    final si = AppLocalizationsSi();
    await pumpScreen(tester, full, locale: const Locale('si'));

    expect(findText(si.budgetTitle), findsOneWidget);
    expect(findText(AppDateUtils.formatMonthYear(october, 'si')), findsOneWidget);
    expect(findText(si.budgetOverallTitle), findsOneWidget);
    expect(findText(si.budgetCategoriesHeader), findsOneWidget);
    expect(findText(si.budgetPercentUsed(25)), findsNWidgets(2));
  });

  testWidgets('the app bar shows the sync state', (tester) async {
    await pumpScreen(tester, full);

    expect(find.byType(SyncStatusIndicator), findsOneWidget);
    expect(find.byTooltip(l10n.syncStatusSynced), findsOneWidget);
  });

  testWidgets('only an overall budget: no categories section', (tester) async {
    await pumpScreen(tester, BudgetOverview(overall: progress(50000, 0)));

    expect(find.byType(BudgetOverallCard), findsOneWidget);
    expect(findText(l10n.budgetCategoriesHeader), findsNothing);
  });

  testWidgets('only category budgets: the card says no overall budget is set', (tester) async {
    await pumpScreen(
      tester,
      BudgetOverview(categories: [progress(20000, 5000, categoryId: 'food')]),
    );

    expect(findText(l10n.budgetOverallEmptyTitle), findsOneWidget);
    expect(find.byType(BudgetProgressTile), findsOneWidget);
  });

  testWidgets('a month without budgets shows the empty state', (tester) async {
    await pumpScreen(tester, const BudgetOverview());

    expect(findText(l10n.budgetEmptyTitle('October 2026')), findsOneWidget);
    expect(findText(l10n.budgetEmptyMessage), findsOneWidget);
    expect(find.byType(BudgetOverallCard), findsNothing);
  });

  testWidgets('the previous month shows that month’s budgets', (tester) async {
    await tester.pumpApp(
      const BudgetScreen(),
      overrides: overrides(
        () => Stream.value(full),
        others: {september: BudgetOverview(overall: progress(30000, 29000, month: september))},
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip(l10n.commonPreviousMonth));
    await tester.pumpAndSettle();

    expect(findText('September 2026'), findsOneWidget);
    expect(findText(l10n.budgetSpentOfLimit(r'$290.00', r'$300.00')), findsOneWidget);
    expect(find.byType(BudgetProgressTile), findsNothing);
  });

  testWidgets('cannot go past the last month that can hold budgets', (tester) async {
    await pumpScreen(tester, full);
    final container = ProviderScope.containerOf(tester.element(find.byType(BudgetScreen)));
    container.read(budgetMonthControllerProvider.notifier).setMonth(DateTime(2027, 10));
    await tester.pumpAndSettle();

    final next = tester.widget<IconButton>(
      find.ancestor(of: find.byTooltip(l10n.commonNextMonth), matching: find.byType(IconButton)),
    );
    expect(next.onPressed, isNull);
  });

  testWidgets('an error offers a retry that reloads', (tester) async {
    var loads = 0;
    await tester.pumpApp(
      const BudgetScreen(),
      overrides: overrides(() {
        loads++;
        return loads == 1 ? Stream.error(const StorageFailure('db')) : Stream.value(full);
      }),
    );
    await tester.pumpAndSettle();
    expect(findText(l10n.errorStorage), findsOneWidget);

    await tester.tap(findText(l10n.commonRetry));
    await tester.pumpAndSettle();

    expect(find.byType(BudgetOverallCard), findsOneWidget);
  });

  testWidgets('a failed profile (currency) load offers a retry that shows the budgets', (
    tester,
  ) async {
    var loads = 0;
    await tester.pumpApp(
      const BudgetScreen(),
      overrides: [
        clockProvider.overrideWithValue(FixedClock(now)),
        profileProvider.overrideWith((ref) {
          loads++;
          return loads == 1
              ? Stream.error(const StorageFailure('db'))
              : Stream.value(const Profile(id: 'u1', currencyCode: 'USD'));
        }),
        budgetOverviewProvider(october).overrideWith((ref) => Stream.value(full)),
        categoryByIdProvider('food').overrideWith((ref) => Stream.value(food)),
        syncStatusProvider.overrideWith(
          (ref) => Stream.value(const SyncStatusInfo(SyncIndicator.synced)),
        ),
      ],
    );
    await tester.pumpAndSettle();
    expect(findText(l10n.errorStorage), findsOneWidget);

    await tester.tap(findText(l10n.commonRetry));
    await tester.pumpAndSettle();

    expect(find.byType(BudgetOverallCard), findsOneWidget);
  });

  group('pull to refresh', () {
    late FakeSyncTrigger trigger;

    setUp(() => trigger = FakeSyncTrigger());

    Future<void> pull(WidgetTester tester, Finder from) async {
      await tester.fling(from, const Offset(0, 500), 1000);
      await tester.pumpAndSettle();
    }

    testWidgets('pulling the list syncs now', (tester) async {
      await pumpScreen(tester, full, extra: [trigger.providerOverride]);

      await pull(tester, find.byType(BudgetOverallCard));

      expect(trigger.immediate, 1);
    });

    testWidgets('an empty month can be pulled too', (tester) async {
      await pumpScreen(tester, const BudgetOverview(), extra: [trigger.providerOverride]);

      await pull(tester, findText(l10n.budgetEmptyTitle('October 2026')));

      expect(trigger.immediate, 1);
    });

    testWidgets('a failed sync says why', (tester) async {
      trigger.nowResult = const Result.failure(NetworkFailure('offline'));
      await pumpScreen(tester, full, extra: [trigger.providerOverride]);

      await pull(tester, find.byType(BudgetOverallCard));

      expect(findText(l10n.errorNetwork), findsOneWidget);
    });
  });

  group('set, edit and copy', () {
    late _MockBudgetRepository repository;

    setUp(() => repository = _MockBudgetRepository());

    Future<void> pumpWith(WidgetTester tester, BudgetOverview overview) => pumpScreen(
      tester,
      overview,
      extra: [budgetRepositoryProvider.overrideWithValue(repository)],
    );

    BudgetFormSheet formSheet(WidgetTester tester) => tester.widget(find.byType(BudgetFormSheet));

    testWidgets('the + button adds a budget, offering only what is not set yet', (tester) async {
      await pumpWith(tester, full);

      await tester.tap(find.byTooltip(l10n.budgetAdd));
      await tester.pumpAndSettle();

      expect(findText(l10n.budgetFormNewTitle), findsOneWidget);
      expect(formSheet(tester).overview, full);
      expect(findText(l10n.budgetFormNoCategoriesLeft), findsOneWidget);
    });

    testWidgets('the empty state offers to add one', (tester) async {
      await pumpWith(tester, const BudgetOverview());

      await tester.tap(findWidgetWithText(FilledButton, l10n.budgetAdd));
      await tester.pumpAndSettle();

      expect(findText(l10n.budgetFormNewTitle), findsOneWidget);
      expect(formSheet(tester).month, october);
    });

    testWidgets('tapping the overall card edits it', (tester) async {
      await pumpWith(tester, full);

      await tester.tap(findText(l10n.budgetOverallTitle));
      await tester.pumpAndSettle();

      expect(findText(l10n.budgetFormEditTitle), findsOneWidget);
      expect(formSheet(tester).budget, full.overall!.budget);
    });

    testWidgets('tapping the card without an overall budget adds one', (tester) async {
      await pumpWith(
        tester,
        BudgetOverview(categories: [progress(20000, 5000, categoryId: 'food')]),
      );

      await tester.tap(findText(l10n.budgetOverallEmptyTitle));
      await tester.pumpAndSettle();

      expect(findText(l10n.budgetFormNewTitle), findsOneWidget);
      expect(findText(l10n.budgetFormOverallHint), findsOneWidget);
    });

    testWidgets('tapping a category budget edits it', (tester) async {
      await pumpWith(tester, full);

      await tester.tap(find.byType(BudgetProgressTile));
      await tester.pumpAndSettle();

      expect(formSheet(tester).budget, full.categories.single.budget);
    });

    testWidgets('copying last month says how many budgets were added', (tester) async {
      when(
        () => repository.copyMonth(from: september, to: october),
      ).thenAnswer((_) async => const Result.success(2));
      await pumpWith(tester, const BudgetOverview());

      await tester.tap(find.byTooltip(l10n.budgetCopyPrevious));
      await tester.pumpAndSettle();

      expect(findText(l10n.budgetCopied(2)), findsOneWidget);
    });

    testWidgets('copying with nothing new says so', (tester) async {
      when(
        () => repository.copyMonth(from: september, to: october),
      ).thenAnswer((_) async => const Result.success(0));
      await pumpWith(tester, full);

      await tester.tap(find.byTooltip(l10n.budgetCopyPrevious));
      await tester.pumpAndSettle();

      expect(findText(l10n.budgetCopied(0)), findsOneWidget);
    });

    testWidgets('a failed copy says why', (tester) async {
      when(
        () => repository.copyMonth(from: september, to: october),
      ).thenAnswer((_) async => const Result.failure(StorageFailure('db')));
      await pumpWith(tester, full);

      await tester.tap(find.byTooltip(l10n.budgetCopyPrevious));
      await tester.pumpAndSettle();

      expect(findText(l10n.errorStorage), findsOneWidget);
    });
  });

  group('accessibility (M9.5)', () {
    testWidgetsBothThemes('meets the guidelines', (tester, brightness) async {
      await pumpScreen(tester, full, brightness: brightness);
      await expectAccessible(tester);
      await scrollThrough(tester);
      await expectAccessible(tester);
    });

    testWidgets('large text (2x) fits', (tester) async {
      useTextScale(tester, 2);
      await pumpScreen(tester, full);
      await scrollThrough(tester);
    });
  });
}
