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

  testWidgets('fits a small phone at 1.5x text', (tester) async {
    tester.view
      ..physicalSize = const Size(320, 640)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpApp(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
        child: MonthSelector(month: DateTime(2026, 9), onChanged: (_) {}),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('September 2026'), findsOneWidget);
  });

  testWidgets('announces the month as a live region', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpSelector(tester, DateTime(2026, 10));

    final node = tester.getSemantics(find.text('October 2026'));
    expect(node.label, 'October 2026');
    expect(node.flagsCollection.isLiveRegion, isTrue);
    handle.dispose();
  });
}
