import 'package:expense_tracker/core/l10n/generated/app_localizations_en.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/features/calendar/presentation/widgets/calendar_day_cell.dart';
import 'package:expense_tracker/features/transactions/domain/entities/day_totals.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  final l10n = AppLocalizationsEn();
  final day = DateTime(2026, 10, 5);

  DayTotals totals(int income, int expense) =>
      DayTotals(date: day, income: Money(income), expense: Money(expense));

  Future<void> pump(
    WidgetTester tester, {
    DayTotals? dayTotals,
    bool isToday = false,
    bool isSelected = false,
    Brightness brightness = Brightness.light,
  }) => tester.pumpApp(
    Center(
      child: SizedBox(
        width: 45,
        height: 56,
        child: CalendarDayCell(
          day: day,
          totals: dayTotals,
          currencyCode: 'USD',
          isToday: isToday,
          isSelected: isSelected,
        ),
      ),
    ),
    brightness: brightness,
  );

  AppColors colors(WidgetTester tester) =>
      Theme.of(tester.element(find.byType(CalendarDayCell))).extension<AppColors>()!;

  testWidgetsBothThemes('a spending day shows a compact negative net in the expense color', (
    tester,
    brightness,
  ) async {
    await pump(tester, dayTotals: totals(0, 123456), brightness: brightness);

    expect(findText('5'), findsOneWidget);
    final amount = tester.widget<Text>(findText(r'-$1.23K'));
    expect(amount.style?.color, colors(tester).expense);
  });

  testWidgets('an earning day shows a signed positive net in the income color', (tester) async {
    await pump(tester, dayTotals: totals(5000, 500));

    final amount = tester.widget<Text>(findText(r'+$45'));
    expect(amount.style?.color, colors(tester).income);
  });

  testWidgets('a day without transactions shows only its number', (tester) async {
    await pump(tester);

    expect(findText('5'), findsOneWidget);
    expect(find.byType(FittedBox), findsNothing);
  });

  testWidgets('is read out as the date and the exact net', (tester) async {
    final handle = tester.ensureSemantics();
    await pump(tester, dayTotals: totals(0, 123456));

    expect(
      find.bySemanticsLabel(l10n.calendarDayLabel('Monday, October 5, 2026', r'-$1,234.56')),
      findsOneWidget,
    );
    handle.dispose();
  });

  testWidgets('an empty day is read out as having no transactions', (tester) async {
    final handle = tester.ensureSemantics();
    await pump(tester);

    expect(find.bySemanticsLabel(l10n.calendarDayEmpty('Monday, October 5, 2026')), findsOneWidget);
    handle.dispose();
  });

  testWidgets('today is outlined', (tester) async {
    await pump(tester, isToday: true);

    final box = tester.widget<Container>(
      find.descendant(of: find.byType(CalendarDayCell), matching: find.byType(Container)),
    );
    expect(box.decoration, isA<BoxDecoration>());
  });

  testWidgets('the selected day is filled and announced as selected', (tester) async {
    final handle = tester.ensureSemantics();
    await pump(tester, isSelected: true);

    final box = tester.widget<Container>(
      find.descendant(of: find.byType(CalendarDayCell), matching: find.byType(Container)),
    );
    final scheme = Theme.of(tester.element(find.byType(CalendarDayCell))).colorScheme;
    expect((box.decoration! as BoxDecoration).color, scheme.primaryContainer);
    expect(
      tester.getSemantics(find.byType(CalendarDayCell)),
      isSemantics(isSelected: true),
    );
    handle.dispose();
  });
}
