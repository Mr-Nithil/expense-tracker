import 'package:expense_tracker/core/l10n/generated/app_localizations_en.dart';
import 'package:expense_tracker/core/router/routes.dart';
import 'package:expense_tracker/core/utils/clock.dart';
import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/features/calendar/presentation/shared/calendar_day_sheet.dart';
import 'package:expense_tracker/features/categories/domain/entities/category.dart';
import 'package:expense_tracker/features/categories/presentation/providers/categories_providers.dart';
import 'package:expense_tracker/features/profile/presentation/providers/profile_providers.dart';
import 'package:expense_tracker/features/transactions/domain/entities/day_totals.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction.dart';
import 'package:expense_tracker/features/transactions/presentation/providers/transactions_providers.dart';
import 'package:expense_tracker/features/transactions/presentation/shared/transaction_form_sheet.dart';
import 'package:expense_tracker/features/transactions/presentation/shared/transaction_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../../helpers/accessibility.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  final l10n = AppLocalizationsEn();
  final now = DateTime(2026, 10, 11, 9);
  final day = DateTime(2026, 10, 5);
  final october = DateTime(2026, 10);
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

  Transaction tx(String id, int dayOfMonth, int amount, {TransactionType? type}) => Transaction(
    id: id,
    type: type ?? TransactionType.expense,
    amount: Money(amount),
    categoryId: 'food',
    occurredOn: DateTime(2026, 10, dayOfMonth),
    isDeleted: false,
    createdAt: at,
    updatedAt: at,
  );

  Future<void> open(
    WidgetTester tester, {
    DateTime? on,
    Brightness brightness = Brightness.light,
  }) async {
    await tester.pumpRouterApp(
      initialLocation: Routes.dashboardPath,
      brightness: brightness,
      overrides: [
        clockProvider.overrideWithValue(FixedClock(now)),
        currencyCodeProvider.overrideWith((ref) async => 'USD'),
        monthDailyTotalsProvider(october).overrideWith(
          (ref) => Stream.value({
            day: DayTotals(date: day, income: const Money(5000), expense: const Money(1550)),
          }),
        ),
        transactionsProvider(TransactionFilter(month: october)).overrideWith(
          (ref) => Stream.value([tx('a', 5, 1250), tx('b', 5, 300), tx('other', 9, 900)]),
        ),
        categoryByIdProvider('food').overrideWith((ref) => Stream.value(food)),
        categoriesProvider(CategoryType.expense).overrideWith((ref) => Stream.value([food])),
      ],
      routes: [
        GoRoute(
          name: Routes.dashboard,
          path: Routes.dashboardPath,
          builder: (context, _) => Scaffold(
            body: TextButton(
              onPressed: () => CalendarDaySheet.show(context, day: on ?? day, currencyCode: 'USD'),
              child: const Text('open'),
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
    await tester.tap(findText('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('is titled with the date and shows the day\'s totals', (tester) async {
    await open(tester);

    expect(findText('Monday, October 5, 2026'), findsOneWidget);
    expect(findText(r'$50.00'), findsOneWidget);
    expect(findText(r'$15.50'), findsOneWidget);
    expect(findText(r'$34.50'), findsOneWidget);
    expect(findText(l10n.calendarDayNet), findsOneWidget);
  });

  testWidgets('lists only that day\'s transactions', (tester) async {
    await open(tester);

    final ids = [
      for (final tile in tester.widgetList<TransactionTile>(find.byType(TransactionTile)))
        tile.transaction.id,
    ];
    expect(ids, ['a', 'b']);
  });

  testWidgets('an empty day shows zero totals and says so', (tester) async {
    await open(tester, on: DateTime(2026, 10, 6));

    expect(findText(r'$0.00'), findsNWidgets(3));
    expect(
      findText(l10n.calendarNoTransactionsOn('Tuesday, October 6, 2026')),
      findsOneWidget,
    );
  });

  testWidgets('"Add transaction" opens the form on that day, over the pop-up', (tester) async {
    await open(tester);

    await tester.tap(findText(l10n.transactionsAdd));
    await tester.pumpAndSettle();

    final form = tester.widget<TransactionFormSheet>(find.byType(TransactionFormSheet));
    expect(form.initialDate, day);
    expect(find.byType(CalendarDaySheet), findsOneWidget);
  });

  testWidgets('a transaction closes the pop-up and opens its detail page', (tester) async {
    await open(tester);

    await tester.tap(find.byType(TransactionTile).first);
    await tester.pumpAndSettle();

    expect(find.byType(CalendarDaySheet), findsNothing);
    expect(findText('detail a'), findsOneWidget);
  });

  testWidgets('each total is read as its label and amount', (tester) async {
    final handle = tester.ensureSemantics();
    await open(tester);

    expect(find.bySemanticsLabel(RegExp(r'Income.*\$50\.00', dotAll: true)), findsOneWidget);
    handle.dispose();
  });

  group('accessibility (M9.5)', () {
    testWidgetsBothThemes('meets the guidelines', (tester, brightness) async {
      await open(tester, brightness: brightness);
      await expectAccessible(tester);
    });

    testWidgets('large text (2x) fits', (tester) async {
      useTextScale(tester, 2);
      await open(tester);
      await scrollThrough(tester);
    });
  });
}
