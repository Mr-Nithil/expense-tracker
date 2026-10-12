import 'dart:async';

import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/l10n/generated/app_localizations_en.dart';
import 'package:expense_tracker/core/router/routes.dart';
import 'package:expense_tracker/core/sync/sync_status.dart';
import 'package:expense_tracker/core/utils/clock.dart';
import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/core/widgets/sync_status_indicator.dart';
import 'package:expense_tracker/features/categories/domain/entities/category.dart';
import 'package:expense_tracker/features/categories/presentation/providers/categories_providers.dart';
import 'package:expense_tracker/features/profile/domain/entities/profile.dart';
import 'package:expense_tracker/features/profile/presentation/providers/profile_providers.dart';
import 'package:expense_tracker/features/transactions/data/transaction_repository_provider.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction.dart';
import 'package:expense_tracker/features/transactions/domain/transaction_repository.dart';
import 'package:expense_tracker/features/transactions/presentation/providers/transactions_providers.dart';
import 'package:expense_tracker/features/transactions/presentation/screens/transactions_screen.dart';
import 'package:expense_tracker/features/transactions/presentation/shared/transaction_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/accessibility.dart';
import '../../../../helpers/fake_sync_trigger.dart';
import '../../../../helpers/pump_app.dart';

class _MockTransactionRepository extends Mock implements TransactionRepository {}

void main() {
  final l10n = AppLocalizationsEn();
  final now = DateTime(2026, 10, 11, 9);
  final october = TransactionFilter(month: DateTime(2026, 10));
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

  Transaction tx(String id, int day, int amount) => Transaction(
    id: id,
    type: TransactionType.expense,
    amount: Money(amount),
    categoryId: 'food',
    occurredOn: DateTime(2026, 10, day),
    isDeleted: false,
    createdAt: at,
    updatedAt: at,
  );

  List<Override> overrides(
    Stream<List<Transaction>> Function() transactions, {
    Map<TransactionFilter, List<Transaction>> others = const {},
  }) => [
    for (final MapEntry(key: other, value: list) in others.entries)
      transactionsProvider(other).overrideWith((ref) => Stream.value(list)),
    clockProvider.overrideWithValue(FixedClock(now)),
    currencyCodeProvider.overrideWith((ref) async => 'USD'),
    transactionsProvider(october).overrideWith((ref) => transactions()),
    categoryByIdProvider('food').overrideWith((ref) => Stream.value(food)),
    categoriesProvider(CategoryType.expense).overrideWith((ref) => Stream.value([food])),
    syncStatusProvider.overrideWith(
      (ref) => Stream.value(const SyncStatusInfo(SyncIndicator.synced)),
    ),
  ];

  Future<void> pumpScreen(
    WidgetTester tester,
    List<Transaction> list, {
    Brightness brightness = Brightness.light,
  }) async {
    await tester.pumpApp(
      const TransactionsScreen(),
      brightness: brightness,
      overrides: overrides(() => Stream.value(list)),
    );
    await tester.pumpAndSettle();
  }

  testWidgetsBothThemes('groups the month by day with subtotals', (tester, brightness) async {
    await pumpScreen(tester, [
      tx('a', 11, 1250),
      tx('b', 11, 750),
      tx('c', 9, 400),
    ], brightness: brightness);

    expect(find.text(l10n.commonToday), findsOneWidget);
    expect(find.text('Fri, Oct 9'), findsOneWidget);
    expect(find.text(r'-$20.00'), findsOneWidget);
    expect(find.text(r'-$4.00'), findsNWidgets(2));
    expect(find.byType(TransactionTile), findsNWidgets(3));
  });

  testWidgets('the app bar shows the sync state', (tester) async {
    await pumpScreen(tester, const []);

    expect(find.byType(SyncStatusIndicator), findsOneWidget);
    expect(find.byTooltip(l10n.syncStatusSynced), findsOneWidget);
  });

  testWidgets('an empty month offers to add one', (tester) async {
    await pumpScreen(tester, const []);

    expect(find.text(l10n.transactionsEmptyTitle('October 2026')), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, l10n.transactionsAdd));
    await tester.pumpAndSettle();

    expect(find.text(l10n.transactionFormNewTitle), findsOneWidget);
  });

  testWidgets('tapping a row opens its detail page', (tester) async {
    await tester.pumpRouterApp(
      initialLocation: Routes.transactionsPath,
      overrides: overrides(() => Stream.value([tx('a', 11, 1250)])),
      routes: [
        GoRoute(
          path: Routes.transactionsPath,
          builder: (_, _) => const TransactionsScreen(),
          routes: [
            GoRoute(
              name: Routes.transactionDetail,
              path: ':${Routes.transactionIdParam}',
              builder: (_, state) =>
                  Text('detail ${state.pathParameters[Routes.transactionIdParam]}'),
            ),
          ],
        ),
      ],
    );

    await tester.tap(find.byType(TransactionTile));
    await tester.pumpAndSettle();

    expect(find.text('detail a'), findsOneWidget);
  });

  testWidgets('the add button opens the new-transaction sheet', (tester) async {
    await pumpScreen(tester, const []);

    await tester.tap(find.byTooltip(l10n.transactionsAdd));
    await tester.pumpAndSettle();

    expect(find.text(l10n.transactionFormNewTitle), findsOneWidget);
  });

  testWidgets('an error offers a retry that reloads', (tester) async {
    var loads = 0;
    await tester.pumpApp(
      const TransactionsScreen(),
      overrides: overrides(() {
        loads++;
        return Stream.error(const StorageFailure('db'));
      }),
    );
    await tester.pumpAndSettle();

    expect(find.text(l10n.errorStorage), findsOneWidget);
    await tester.tap(find.text(l10n.commonRetry));
    await tester.pumpAndSettle();
    expect(loads, greaterThan(1));
  });

  group('filters', () {
    Transaction income(String id, int day) => tx(id, day, 85000).copyWith(
      type: TransactionType.income,
    );

    testWidgets('the previous month shows that month’s transactions', (tester) async {
      await tester.pumpApp(
        const TransactionsScreen(),
        overrides: overrides(
          () => Stream.value([tx('oct', 11, 1250)]),
          others: {
            TransactionFilter(month: DateTime(2026, 9)): [tx('sep', 1, 999)],
          },
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip(l10n.commonPreviousMonth));
      await tester.pumpAndSettle();

      expect(find.text('September 2026'), findsOneWidget);
      expect(find.text(r'-$9.99'), findsWidgets);
    });

    testWidgets('choosing income shows only the income list', (tester) async {
      await tester.pumpApp(
        const TransactionsScreen(),
        overrides: overrides(
          () => Stream.value([tx('a', 11, 1250)]),
          others: {
            TransactionFilter(month: DateTime(2026, 10), type: TransactionType.income): [
              income('b', 10),
            ],
          },
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text(l10n.commonIncome));
      await tester.pumpAndSettle();

      expect(find.text(r'+$850.00'), findsWidgets);
      expect(find.text(r'-$12.50'), findsNothing);
    });

    testWidgets('a filter that hides everything offers to clear it', (tester) async {
      await tester.pumpApp(
        const TransactionsScreen(),
        overrides: overrides(
          () => Stream.value([tx('a', 11, 1250)]),
          others: {
            TransactionFilter(month: DateTime(2026, 10), type: TransactionType.income): const [],
          },
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.commonIncome));
      await tester.pumpAndSettle();

      expect(find.text(l10n.transactionsNoMatchesTitle), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, l10n.transactionsClearFilters));
      await tester.pumpAndSettle();

      expect(find.byType(TransactionTile), findsOneWidget);
    });
  });

  group('swipe to delete', () {
    late _MockTransactionRepository repository;

    setUp(() {
      repository = _MockTransactionRepository();
      when(() => repository.delete(any())).thenAnswer((_) async => Result.ok);
      when(() => repository.restore(any())).thenAnswer((_) async => Result.ok);
    });

    Future<void> pumpWith(WidgetTester tester, List<Transaction> list) async {
      await tester.pumpApp(
        const TransactionsScreen(),
        overrides: [
          ...overrides(() => Stream.value(list)),
          transactionRepositoryProvider.overrideWithValue(repository),
        ],
      );
      await tester.pumpAndSettle();
    }

    /// Swipes the row showing [amount] (not the day header, which can show the same text).
    Future<void> swipe(WidgetTester tester, String amount) async {
      await tester.fling(
        find.descendant(of: find.byType(TransactionTile), matching: find.text(amount)),
        const Offset(-600, 0),
        1000,
      );
      await tester.pumpAndSettle();
    }

    testWidgets('hides the row at once and offers Undo', (tester) async {
      await pumpWith(tester, [tx('a', 11, 1250), tx('b', 11, 750)]);

      await swipe(tester, r'-$12.50');

      verify(() => repository.delete('a')).called(1);
      expect(find.byType(TransactionTile), findsOneWidget);
      expect(find.text(l10n.transactionDeleted), findsOneWidget);
      expect(find.text(r'-$7.50'), findsNWidgets(2));

      await tester.tap(find.text(l10n.commonUndo));
      await tester.pumpAndSettle();

      verify(() => repository.restore('a')).called(1);
      expect(find.byType(TransactionTile), findsNWidgets(2));
    });

    testWidgets('Undo still works after deleting the month’s last transaction', (
      tester,
    ) async {
      // A live list, like the database stream: delete/restore update it.
      final lunch = tx('a', 11, 1250);
      final data = StreamController<List<Transaction>>.broadcast();
      addTearDown(data.close);
      when(() => repository.delete('a')).thenAnswer((_) async {
        data.add(const []);
        return Result.ok;
      });
      when(() => repository.restore('a')).thenAnswer((_) async {
        data.add([lunch]);
        return Result.ok;
      });
      await tester.pumpApp(
        const TransactionsScreen(),
        overrides: [
          ...overrides(() async* {
            yield [lunch];
            yield* data.stream;
          }),
          transactionRepositoryProvider.overrideWithValue(repository),
        ],
      );
      await tester.pumpAndSettle();

      await swipe(tester, r'-$12.50');
      expect(find.text(l10n.transactionsEmptyTitle('October 2026')), findsOneWidget);

      await tester.tap(find.text(l10n.commonUndo));
      await tester.pumpAndSettle();

      verify(() => repository.restore('a')).called(1);
      expect(find.byType(TransactionTile), findsOneWidget);
    });

    testWidgets('a failed delete brings the row back with the error', (tester) async {
      when(
        () => repository.delete(any()),
      ).thenAnswer((_) async => const Result.failure(StorageFailure('db')));
      await pumpWith(tester, [tx('a', 11, 1250)]);

      await swipe(tester, r'-$12.50');

      expect(find.byType(TransactionTile), findsOneWidget);
      expect(find.text(l10n.errorStorage), findsOneWidget);
    });

    testWidgets('swiping a day’s only transaction removes its header', (tester) async {
      await pumpWith(tester, [tx('a', 11, 1250), tx('b', 9, 400)]);

      await swipe(tester, r'-$4.00');

      expect(find.text('Fri, Oct 9'), findsNothing);
      expect(find.text(l10n.commonToday), findsOneWidget);
    });
  });

  testWidgets('a failed profile (currency) load offers a retry that shows the list', (
    tester,
  ) async {
    var loads = 0;
    await tester.pumpApp(
      const TransactionsScreen(),
      overrides: [
        clockProvider.overrideWithValue(FixedClock(now)),
        profileProvider.overrideWith((ref) {
          loads++;
          return loads == 1
              ? Stream.error(const StorageFailure('db'))
              : Stream.value(const Profile(id: 'u1', currencyCode: 'USD'));
        }),
        transactionsProvider(october).overrideWith((ref) => Stream.value([tx('a', 11, 1250)])),
        syncStatusProvider.overrideWith(
          (ref) => Stream.value(const SyncStatusInfo(SyncIndicator.synced)),
        ),
        categoryByIdProvider('food').overrideWith((ref) => Stream.value(food)),
      ],
    );
    await tester.pumpAndSettle();
    expect(find.text(l10n.errorStorage), findsOneWidget);

    await tester.tap(find.text(l10n.commonRetry));
    await tester.pumpAndSettle();

    expect(find.byType(TransactionTile), findsOneWidget);
  });

  group('pull to refresh', () {
    late FakeSyncTrigger trigger;

    setUp(() => trigger = FakeSyncTrigger());

    Future<void> pumpWith(WidgetTester tester, List<Transaction> list) async {
      await tester.pumpApp(
        const TransactionsScreen(),
        overrides: [...overrides(() => Stream.value(list)), trigger.providerOverride],
      );
      await tester.pumpAndSettle();
    }

    Future<void> pull(WidgetTester tester, Finder from) async {
      await tester.fling(from, const Offset(0, 500), 1000);
      await tester.pumpAndSettle();
    }

    testWidgets('pulling the list syncs now', (tester) async {
      await pumpWith(tester, [tx('a', 11, 1250)]);

      await pull(tester, find.byType(TransactionTile));

      expect(trigger.immediate, 1);
    });

    testWidgets('an empty month can be pulled too', (tester) async {
      await pumpWith(tester, const []);

      await pull(tester, find.text(l10n.transactionsEmptyTitle('October 2026')));

      expect(trigger.immediate, 1);
    });

    testWidgets('a failed sync says why', (tester) async {
      trigger.nowResult = const Result.failure(NetworkFailure('offline'));
      await pumpWith(tester, [tx('a', 11, 1250)]);

      await pull(tester, find.byType(TransactionTile));

      expect(find.text(l10n.errorNetwork), findsOneWidget);
    });
  });

  group('accessibility (M9.5)', () {
    testWidgetsBothThemes('meets the guidelines', (tester, brightness) async {
      await pumpScreen(tester, [tx('a', 11, 1250), tx('b', 9, 400)], brightness: brightness);
      await expectAccessible(tester);
      await scrollThrough(tester);
      await expectAccessible(tester);
    });

    testWidgets('large text (2x) fits', (tester) async {
      useTextScale(tester, 2);
      await pumpScreen(tester, [tx('a', 11, 1250), tx('b', 9, 400)]);
      await scrollThrough(tester);
    });
  });
}
