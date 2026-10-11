import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/l10n/generated/app_localizations_en.dart';
import 'package:expense_tracker/core/router/routes.dart';
import 'package:expense_tracker/core/session/session.dart';
import 'package:expense_tracker/core/utils/clock.dart';
import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/features/categories/domain/entities/category.dart';
import 'package:expense_tracker/features/categories/presentation/providers/categories_providers.dart';
import 'package:expense_tracker/features/dashboard/presentation/widgets/dashboard_recent_section.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction.dart';
import 'package:expense_tracker/features/transactions/presentation/providers/transactions_providers.dart';
import 'package:expense_tracker/features/transactions/presentation/shared/transaction_tile.dart';
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

  Transaction tx(int day) => Transaction(
    id: 't$day',
    type: TransactionType.expense,
    amount: Money(day * 100),
    categoryId: 'food',
    occurredOn: DateTime(2026, 9, day),
    isDeleted: false,
    createdAt: at,
    updatedAt: at,
  );

  // Newest first, as the repository returns them.
  final seven = [for (var day = 30; day > 23; day--) tx(day)];

  List<Override> overrides(Stream<List<Transaction>> Function() transactions) => [
    clockProvider.overrideWithValue(FixedClock(now)),
    transactionsProvider(TransactionFilter(month: september)).overrideWith((ref) => transactions()),
    categoryByIdProvider('food').overrideWith((ref) => Stream.value(food)),
  ];

  Future<void> pump(
    WidgetTester tester,
    Stream<List<Transaction>> Function() transactions, {
    Brightness brightness = Brightness.light,
  }) => tester.pumpRouterApp(
    initialLocation: Routes.dashboardPath,
    brightness: brightness,
    overrides: overrides(transactions),
    routes: [
      GoRoute(
        name: Routes.dashboard,
        path: Routes.dashboardPath,
        builder: (_, _) => Scaffold(
          body: SingleChildScrollView(
            child: DashboardRecentSection(month: september, currencyCode: 'USD'),
          ),
        ),
      ),
      GoRoute(
        name: Routes.transactions,
        path: Routes.transactionsPath,
        builder: (_, _) => Consumer(
          builder: (_, ref, _) =>
              Text('transactions ${ref.watch(transactionFilterControllerProvider)}'),
        ),
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

  testWidgetsBothThemes('shows the five newest transactions of the month', (
    tester,
    brightness,
  ) async {
    await pump(tester, () => Stream.value(seven), brightness: brightness);

    expect(find.text(l10n.dashboardRecentTitle), findsOneWidget);
    final shown = [
      for (final tile in tester.widgetList<TransactionTile>(find.byType(TransactionTile)))
        tile.transaction.id,
    ];
    expect(shown, ['t30', 't29', 't28', 't27', 't26']);
    expect(find.text(r'-$30.00'), findsOneWidget);
  });

  testWidgets('See all opens the Transactions tab on the same month, unfiltered', (tester) async {
    await pump(tester, () => Stream.value(seven));
    final container = ProviderScope.containerOf(
      tester.element(find.byType(DashboardRecentSection)),
    );
    container.read(sessionProvider.notifier).set(const SessionUser(userId: 'u1'));
    container.read(transactionFilterControllerProvider.notifier)
      ..setType(TransactionType.income)
      ..setCategory('salary');

    await tester.tap(find.text(l10n.commonSeeAll));
    await tester.pumpAndSettle();

    expect(find.text('transactions ${TransactionFilter(month: september)}'), findsOneWidget);
  });

  testWidgets('tapping a transaction opens its detail page', (tester) async {
    await pump(tester, () => Stream.value(seven));

    await tester.tap(find.text(r'-$28.00'));
    await tester.pumpAndSettle();

    expect(find.text('detail t28'), findsOneWidget);
  });

  testWidgets('a month without transactions says so', (tester) async {
    await pump(tester, () => Stream.value(const []));

    expect(find.text(l10n.dashboardRecentEmpty('September 2026')), findsOneWidget);
    expect(find.byType(TransactionTile), findsNothing);
  });

  testWidgets('an error offers a retry that reloads', (tester) async {
    var loads = 0;
    await pump(tester, () {
      loads++;
      return loads == 1 ? Stream.error(const StorageFailure('db')) : Stream.value(seven);
    });
    expect(find.text(l10n.errorStorage), findsOneWidget);

    await tester.tap(find.text(l10n.commonRetry));
    await tester.pumpAndSettle();

    expect(find.byType(TransactionTile), findsNWidgets(5));
  });
}
