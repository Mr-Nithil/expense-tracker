import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/l10n/generated/app_localizations_en.dart';
import 'package:expense_tracker/core/router/routes.dart';
import 'package:expense_tracker/core/utils/clock.dart';
import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/features/calendar/presentation/shared/calendar_day_panel.dart';
import 'package:expense_tracker/features/categories/domain/entities/category.dart';
import 'package:expense_tracker/features/categories/presentation/providers/categories_providers.dart';
import 'package:expense_tracker/features/profile/presentation/providers/profile_providers.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction.dart';
import 'package:expense_tracker/features/transactions/presentation/providers/transactions_providers.dart';
import 'package:expense_tracker/features/transactions/presentation/shared/transaction_form_sheet.dart';
import 'package:expense_tracker/features/transactions/presentation/shared/transaction_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  final l10n = AppLocalizationsEn();
  final now = DateTime(2026, 10, 11, 9);
  final day = DateTime(2026, 10, 5);
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

  Transaction tx(String id, int dayOfMonth, int amount) => Transaction(
    id: id,
    type: TransactionType.expense,
    amount: Money(amount),
    categoryId: 'food',
    occurredOn: DateTime(2026, 10, dayOfMonth),
    isDeleted: false,
    createdAt: at,
    updatedAt: at,
  );

  // Newest first, as the repository returns them.
  final month = [tx('late', 9, 900), tx('a', 5, 1250), tx('b', 5, 300), tx('early', 2, 200)];

  List<Override> overrides(Stream<List<Transaction>> Function() transactions) => [
    clockProvider.overrideWithValue(FixedClock(now)),
    currencyCodeProvider.overrideWith((ref) async => 'USD'),
    transactionsProvider(october).overrideWith((ref) => transactions()),
    categoryByIdProvider('food').overrideWith((ref) => Stream.value(food)),
    categoriesProvider(CategoryType.expense).overrideWith((ref) => Stream.value([food])),
  ];

  Future<void> pump(
    WidgetTester tester,
    Stream<List<Transaction>> Function() transactions, {
    DateTime? selected,
    bool showDate = true,
    ValueChanged<Transaction>? onTransactionTap,
    Brightness brightness = Brightness.light,
  }) => tester.pumpRouterApp(
    initialLocation: '/calendar',
    brightness: brightness,
    overrides: overrides(transactions),
    routes: [
      GoRoute(
        path: '/calendar',
        builder: (_, _) => Scaffold(
          body: SingleChildScrollView(
            child: CalendarDayPanel(
              day: selected ?? day,
              currencyCode: 'USD',
              showDate: showDate,
              onTransactionTap: onTransactionTap,
            ),
          ),
        ),
      ),
      GoRoute(
        name: Routes.transactionDetail,
        path: '/transactions/:${Routes.transactionIdParam}',
        builder: (_, state) => Text('detail ${state.pathParameters[Routes.transactionIdParam]}'),
      ),
    ],
  );

  testWidgetsBothThemes('lists only the selected day\'s transactions', (tester, brightness) async {
    await pump(tester, () => Stream.value(month), brightness: brightness);

    expect(find.text('Monday, October 5, 2026'), findsOneWidget);
    final ids = [
      for (final tile in tester.widgetList<TransactionTile>(find.byType(TransactionTile)))
        tile.transaction.id,
    ];
    expect(ids, ['a', 'b']);
  });

  testWidgets('a day without transactions says so', (tester) async {
    await pump(tester, () => Stream.value(month), selected: DateTime(2026, 10, 6));

    expect(
      find.text(l10n.calendarNoTransactionsOn('Tuesday, October 6, 2026')),
      findsOneWidget,
    );
    expect(find.byType(TransactionTile), findsNothing);
  });

  testWidgets('"Add transaction" opens the sheet on that day', (tester) async {
    await pump(tester, () => Stream.value(month));

    await tester.tap(find.text(l10n.transactionsAdd));
    await tester.pumpAndSettle();

    final sheet = tester.widget<TransactionFormSheet>(find.byType(TransactionFormSheet));
    expect(sheet.initialDate, day);
    expect(find.text('Oct 5, 2026'), findsOneWidget);
  });

  testWidgets('tapping a transaction opens its detail page', (tester) async {
    await pump(tester, () => Stream.value(month));

    await tester.tap(find.byType(TransactionTile).first);
    await tester.pumpAndSettle();

    expect(find.text('detail a'), findsOneWidget);
  });

  testWidgets('can hide the date', (tester) async {
    await pump(tester, () => Stream.value(month), showDate: false);

    expect(find.text('Monday, October 5, 2026'), findsNothing);
    expect(find.text(l10n.transactionsAdd), findsOneWidget);
  });

  testWidgets('a custom tap handler replaces opening the detail page', (tester) async {
    Transaction? tapped;
    await pump(tester, () => Stream.value(month), onTransactionTap: (t) => tapped = t);

    await tester.tap(find.byType(TransactionTile).first);
    await tester.pumpAndSettle();

    expect(tapped?.id, 'a');
    expect(find.text('detail a'), findsNothing);
  });

  testWidgets('an error offers a retry that reloads', (tester) async {
    var loads = 0;
    await pump(tester, () {
      loads++;
      return loads == 1 ? Stream.error(const StorageFailure('db')) : Stream.value(month);
    });
    expect(find.text(l10n.errorStorage), findsOneWidget);

    await tester.tap(find.text(l10n.commonRetry));
    await tester.pumpAndSettle();

    expect(find.byType(TransactionTile), findsNWidgets(2));
  });
}
