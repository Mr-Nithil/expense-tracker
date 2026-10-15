import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/l10n/generated/app_localizations_en.dart';
import 'package:expense_tracker/core/sync/sync_status.dart';
import 'package:expense_tracker/core/utils/clock.dart';
import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/core/widgets/sync_status_indicator.dart';
import 'package:expense_tracker/features/calendar/presentation/screens/calendar_screen.dart';
import 'package:expense_tracker/features/calendar/presentation/shared/calendar_day_panel.dart';
import 'package:expense_tracker/features/calendar/presentation/widgets/calendar_day_cell.dart';
import 'package:expense_tracker/features/profile/presentation/providers/profile_providers.dart';
import 'package:expense_tracker/features/transactions/domain/entities/day_totals.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction.dart';
import 'package:expense_tracker/features/transactions/presentation/providers/transactions_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fake_sync_trigger.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  final l10n = AppLocalizationsEn();
  final now = DateTime(2026, 10, 11, 9);
  final october = DateTime(2026, 10);
  final september = DateTime(2026, 9);

  DayTotals day(DateTime date, int income, int expense) =>
      DayTotals(date: date, income: Money(income), expense: Money(expense));

  final octoberTotals = {
    DateTime(2026, 10, 5): day(DateTime(2026, 10, 5), 0, 1250),
    DateTime(2026, 10, 11): day(DateTime(2026, 10, 11), 500000, 0),
  };

  List<Override> overrides(Stream<Map<DateTime, DayTotals>> Function() october$) => [
    clockProvider.overrideWithValue(FixedClock(now)),
    currencyCodeProvider.overrideWith((ref) async => 'USD'),
    monthDailyTotalsProvider(october).overrideWith((ref) => october$()),
    monthDailyTotalsProvider(september).overrideWith(
      (ref) => Stream.value({DateTime(2026, 9, 30): day(DateTime(2026, 9, 30), 0, 4200)}),
    ),
    syncStatusProvider.overrideWith(
      (ref) => Stream.value(const SyncStatusInfo(SyncIndicator.synced)),
    ),
    for (final month in [october, september])
      transactionsProvider(TransactionFilter(month: month)).overrideWith(
        (ref) => Stream.value(const <Transaction>[]),
      ),
  ];

  Future<void> pumpScreen(
    WidgetTester tester, {
    Brightness brightness = Brightness.light,
    List<Override> extra = const [],
  }) async {
    await tester.pumpApp(
      const CalendarScreen(),
      brightness: brightness,
      overrides: [...overrides(() => Stream.value(octoberTotals)), ...extra],
    );
    await tester.pumpAndSettle();
  }

  CalendarDayCell cellOf(WidgetTester tester, DateTime date) => tester
      .widgetList<CalendarDayCell>(find.byType(CalendarDayCell))
      .singleWhere((cell) => cell.day == date);

  testWidgetsBothThemes('shows the month with each day\'s net', (tester, brightness) async {
    await pumpScreen(tester, brightness: brightness);

    expect(findText(l10n.calendarTitle), findsOneWidget);
    expect(findText('October 2026'), findsOneWidget);
    expect(find.byType(CalendarDayCell), findsNWidgets(31));
    expect(findText(r'-$13'), findsOneWidget);
    expect(findText(r'+$5K'), findsOneWidget);
    expect(cellOf(tester, DateTime(2026, 10, 5)).totals, octoberTotals[DateTime(2026, 10, 5)]);
    expect(cellOf(tester, DateTime(2026, 10, 6)).totals, isNull);
  });

  testWidgets('marks today', (tester) async {
    await pumpScreen(tester);

    expect(cellOf(tester, DateTime(2026, 10, 11)).isToday, isTrue);
    expect(cellOf(tester, DateTime(2026, 10, 10)).isToday, isFalse);
  });

  CalendarDayPanel panel(WidgetTester tester) => tester.widget(find.byType(CalendarDayPanel));

  testWidgets('today is selected at first, with its panel below', (tester) async {
    await pumpScreen(tester);

    expect(cellOf(tester, DateTime(2026, 10, 11)).isSelected, isTrue);
    expect(panel(tester).day, DateTime(2026, 10, 11));
  });

  testWidgets('tapping a day selects it and shows its panel', (tester) async {
    await pumpScreen(tester);

    await tester.tap(findText('5'));
    await tester.pumpAndSettle();

    expect(cellOf(tester, DateTime(2026, 10, 5)).isSelected, isTrue);
    expect(cellOf(tester, DateTime(2026, 10, 11)).isSelected, isFalse);
    expect(panel(tester).day, DateTime(2026, 10, 5));
  });

  testWidgets('another month starts with nothing selected', (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.byTooltip(l10n.commonPreviousMonth));
    await tester.pumpAndSettle();

    expect(find.byType(CalendarDayPanel), findsNothing);
  });

  testWidgets('the arrows change the month', (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.byTooltip(l10n.commonPreviousMonth));
    await tester.pumpAndSettle();

    expect(findText('September 2026'), findsOneWidget);
    expect(find.byType(CalendarDayCell), findsNWidgets(30));
    expect(findText(r'-$42'), findsOneWidget);
  });

  testWidgets('swiping changes the month', (tester) async {
    await pumpScreen(tester);

    await tester.fling(findText('15'), const Offset(400, 0), 1000);
    await tester.pumpAndSettle();

    expect(findText('September 2026'), findsOneWidget);
  });

  testWidgets('the app bar shows the sync state', (tester) async {
    await pumpScreen(tester);

    expect(find.byType(SyncStatusIndicator), findsOneWidget);
  });

  testWidgets('an error offers a retry that reloads', (tester) async {
    var loads = 0;
    await tester.pumpApp(
      const CalendarScreen(),
      overrides: overrides(() {
        loads++;
        return loads == 1 ? Stream.error(const StorageFailure('db')) : Stream.value(octoberTotals);
      }),
    );
    await tester.pumpAndSettle();
    expect(findText(l10n.errorStorage), findsOneWidget);

    await tester.tap(findText(l10n.commonRetry));
    await tester.pumpAndSettle();

    expect(findText(r'-$13'), findsOneWidget);
  });

  testWidgets('pulling the calendar syncs now', (tester) async {
    final trigger = FakeSyncTrigger();
    await pumpScreen(tester, extra: [trigger.providerOverride]);

    await tester.fling(findText('15'), const Offset(0, 500), 1000);
    await tester.pumpAndSettle();

    expect(trigger.immediate, 1);
  });

  testWidgets('fits a small phone at 1.5x text', (tester) async {
    tester.view
      ..physicalSize = const Size(320, 640)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpApp(
      const MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(1.5)),
        child: CalendarScreen(),
      ),
      overrides: overrides(() => Stream.value(octoberTotals)),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
