import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/l10n/generated/app_localizations_en.dart';
import 'package:expense_tracker/core/router/routes.dart';
import 'package:expense_tracker/core/utils/clock.dart';
import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/features/calendar/presentation/providers/calendar_providers.dart';
import 'package:expense_tracker/features/dashboard/presentation/widgets/dashboard_heatmap_section.dart';
import 'package:expense_tracker/features/transactions/domain/entities/day_totals.dart';
import 'package:expense_tracker/features/transactions/presentation/providers/transactions_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  final l10n = AppLocalizationsEn();
  final october = DateTime(2026, 10);

  DayTotals day(int dayOfMonth, int expense, {int income = 0}) => DayTotals(
    date: DateTime(2026, 10, dayOfMonth),
    income: Money(income),
    expense: Money(expense),
  );

  final totals = {
    for (final d in [day(1, 1000), day(5, 10000), day(9, 5000), day(12, 0, income: 90000)])
      d.date: d,
  };

  /// The section on a dashboard route, and a calendar route that shows the calendar's state.
  Future<void> pump(
    WidgetTester tester,
    Stream<Map<DateTime, DayTotals>> Function() stream, {
    Brightness brightness = Brightness.light,
  }) => tester.pumpRouterApp(
    initialLocation: Routes.dashboardPath,
    brightness: brightness,
    overrides: [
      clockProvider.overrideWithValue(FixedClock(DateTime(2026, 11, 3, 9))),
      monthDailyTotalsProvider(october).overrideWith((ref) => stream()),
    ],
    routes: [
      GoRoute(
        name: Routes.dashboard,
        path: Routes.dashboardPath,
        builder: (_, _) => Scaffold(
          body: SingleChildScrollView(
            child: DashboardHeatmapSection(month: october, currencyCode: 'USD'),
          ),
        ),
        routes: [
          GoRoute(
            name: Routes.calendar,
            path: Routes.calendarPath.substring(1),
            builder: (_, _) => Consumer(
              builder: (_, ref, _) => Text('calendar ${ref.watch(calendarControllerProvider)}'),
            ),
          ),
        ],
      ),
    ],
  );

  Color colorOfDay(WidgetTester tester, String dateLabel) {
    final cell = find.bySemanticsLabel(RegExp('^${RegExp.escape(dateLabel)}:'));
    final box = tester.widget<DecoratedBox>(
      find.descendant(of: cell, matching: find.byType(DecoratedBox)),
    );
    return (box.decoration as BoxDecoration).color!;
  }

  Color keyColor(WidgetTester tester, int level) {
    final box = tester.widget<Container>(find.byKey(ValueKey('heatmap-key-$level')));
    return (box.decoration! as BoxDecoration).color!;
  }

  testWidgetsBothThemes('shades each day by spending, matching the key', (
    tester,
    brightness,
  ) async {
    final handle = tester.ensureSemantics();
    await pump(tester, () => Stream.value(totals), brightness: brightness);

    expect(find.text(l10n.dashboardHeatmapTitle), findsOneWidget);
    expect(find.text(l10n.dashboardHeatmapLess), findsOneWidget);
    expect(find.text(l10n.dashboardHeatmapMore), findsOneWidget);
    // Max day is $100: $10 → level 1, $50 → 2, $100 → 4; income-only and empty days → 0.
    expect(colorOfDay(tester, 'Thursday, October 1, 2026'), keyColor(tester, 1));
    expect(colorOfDay(tester, 'Friday, October 9, 2026'), keyColor(tester, 2));
    expect(colorOfDay(tester, 'Monday, October 5, 2026'), keyColor(tester, 4));
    expect(colorOfDay(tester, 'Monday, October 12, 2026'), keyColor(tester, 0));
    expect(colorOfDay(tester, 'Tuesday, October 6, 2026'), keyColor(tester, 0));
    handle.dispose();
  });

  testWidgets('every day of the month is read out with what was spent', (tester) async {
    final handle = tester.ensureSemantics();
    await pump(tester, () => Stream.value(totals));

    expect(
      find.bySemanticsLabel(l10n.dashboardHeatmapDay('Monday, October 5, 2026', r'$100.00')),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(l10n.dashboardHeatmapDayNone('Tuesday, October 6, 2026')),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel(RegExp(r'October \d+, 2026:')), findsNWidgets(31));
    handle.dispose();
  });

  testWidgets('the first day sits under its weekday (Sunday-first in en_US)', (tester) async {
    await pump(tester, () => Stream.value(totals));

    // October 1, 2026 is a Thursday: the 5th column when weeks start on Sunday.
    final headers = find.text('T');
    expect(headers, findsNWidgets(2));
    final thursdayX = tester.getCenter(headers.last).dx;
    final firstDay = find.bySemanticsLabel(RegExp('^Thursday, October 1, 2026:'));
    expect(tester.getCenter(firstDay).dx, moreOrLessEquals(thursdayX, epsilon: 1));
  });

  testWidgets('tapping a day opens the calendar on that day', (tester) async {
    await pump(tester, () => Stream.value(totals));

    await tester.tap(find.bySemanticsLabel(RegExp('^Friday, October 9, 2026:')));
    await tester.pumpAndSettle();

    expect(
      find.text('calendar ${(month: october, selectedDay: DateTime(2026, 10, 9))}'),
      findsOneWidget,
    );
  });

  testWidgets('See all opens the calendar on this month', (tester) async {
    await pump(tester, () => Stream.value(totals));

    await tester.tap(find.text(l10n.commonSeeAll));
    await tester.pumpAndSettle();

    // Today (Nov 3) isn't in October, so nothing is selected.
    expect(find.text('calendar ${(month: october, selectedDay: null)}'), findsOneWidget);
  });

  testWidgets('days are buttons for screen readers', (tester) async {
    final handle = tester.ensureSemantics();
    await pump(tester, () => Stream.value(totals));

    expect(
      tester.getSemantics(find.bySemanticsLabel(RegExp('^Friday, October 9, 2026:'))),
      isSemantics(isButton: true),
    );
    handle.dispose();
  });

  testWidgets('an error offers a retry that reloads', (tester) async {
    var loads = 0;
    await pump(tester, () {
      loads++;
      return loads == 1 ? Stream.error(const StorageFailure('db')) : Stream.value(totals);
    });
    expect(find.text(l10n.errorStorage), findsOneWidget);

    await tester.tap(find.text(l10n.commonRetry));
    await tester.pumpAndSettle();

    expect(find.text(l10n.dashboardHeatmapLess), findsOneWidget);
  });

  testWidgets('fits a small phone at 1.5x text', (tester) async {
    tester.view
      ..physicalSize = const Size(320, 640)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpApp(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
        child: SingleChildScrollView(
          child: DashboardHeatmapSection(month: october, currencyCode: 'USD'),
        ),
      ),
      overrides: [monthDailyTotalsProvider(october).overrideWith((ref) => Stream.value(totals))],
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
