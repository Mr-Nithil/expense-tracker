import 'package:expense_tracker/core/l10n/generated/app_localizations_en.dart';
import 'package:expense_tracker/core/widgets/month_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  final l10n = AppLocalizationsEn();

  Future<List<DateTime>> pumpSelector(
    WidgetTester tester,
    DateTime month, {
    DateTime? first,
    DateTime? last,
    Brightness brightness = Brightness.light,
  }) async {
    final changes = <DateTime>[];
    await tester.pumpApp(
      MonthSelector(
        month: month,
        firstMonth: first,
        lastMonth: last,
        onChanged: changes.add,
      ),
      brightness: brightness,
    );
    return changes;
  }

  IconButton arrow(WidgetTester tester, IconData icon) =>
      tester.widget(find.widgetWithIcon(IconButton, icon));

  testWidgetsBothThemes('shows the month', (tester, brightness) async {
    await pumpSelector(tester, DateTime(2026, 10, 17), brightness: brightness);
    expect(find.text('October 2026'), findsOneWidget);
    expect(find.byTooltip(l10n.commonPreviousMonth), findsOneWidget);
    expect(find.byTooltip(l10n.commonNextMonth), findsOneWidget);
  });

  testWidgets('steps across a year boundary, reporting first days', (tester) async {
    final changes = await pumpSelector(tester, DateTime(2026));

    await tester.tap(find.byTooltip(l10n.commonPreviousMonth));
    await tester.tap(find.byTooltip(l10n.commonNextMonth));

    expect(changes, [DateTime(2025, 12), DateTime(2026, 2)]);
  });

  testWidgets('arrows are disabled at the bounds', (tester) async {
    await pumpSelector(
      tester,
      DateTime(2026, 10),
      first: DateTime(2026, 10, 20),
      last: DateTime(2026, 10),
    );

    expect(arrow(tester, Icons.chevron_left).onPressed, isNull);
    expect(arrow(tester, Icons.chevron_right).onPressed, isNull);
  });
}
