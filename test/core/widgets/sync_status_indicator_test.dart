import 'package:expense_tracker/core/l10n/generated/app_localizations_en.dart';
import 'package:expense_tracker/core/sync/sync_status.dart';
import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/core/widgets/sprout_loader.dart';
import 'package:expense_tracker/core/widgets/sync_status_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  final l10n = AppLocalizationsEn();

  Future<void> pumpIndicator(
    WidgetTester tester,
    SyncIndicator indicator, {
    int pending = 0,
    VoidCallback? onPressed,
    Brightness brightness = Brightness.light,
  }) => tester.pumpApp(
    SyncStatusIndicator(indicator: indicator, pendingCount: pending, onPressed: onPressed),
    brightness: brightness,
  );

  testWidgetsBothThemes('each state has its icon and sentence', (tester, brightness) async {
    final cases = {
      SyncIndicator.synced: (Icons.cloud_done_outlined, l10n.syncStatusSynced),
      SyncIndicator.offline: (Icons.cloud_off_outlined, l10n.syncStatusOffline),
      SyncIndicator.error: (Icons.sync_problem, l10n.syncStatusError),
    };
    for (final MapEntry(key: indicator, value: (icon, text)) in cases.entries) {
      await pumpIndicator(tester, indicator, brightness: brightness);
      expect(find.byIcon(icon), findsOneWidget, reason: '$indicator');
      expect(find.byTooltip(text), findsOneWidget, reason: '$indicator');
    }
  });

  testWidgets('syncing shows a spinner', (tester) async {
    await pumpIndicator(tester, SyncIndicator.syncing);

    expect(find.byType(SproutLoader), findsOneWidget);
    expect(find.byTooltip(l10n.syncStatusSyncing), findsOneWidget);
  });

  testWidgets('pending shows the count', (tester) async {
    await pumpIndicator(tester, SyncIndicator.pending, pending: 3);

    expect(findText('3'), findsOneWidget);
    expect(find.byTooltip(l10n.syncStatusPending(3)), findsOneWidget);
  });

  testWidgets('an error uses the error color', (tester) async {
    await pumpIndicator(tester, SyncIndicator.error);

    final icon = tester.widget<Icon>(find.byIcon(Icons.sync_problem));
    expect(icon.color, AppTheme.light().colorScheme.error);
  });

  testWidgets('tapping calls back', (tester) async {
    var taps = 0;
    await pumpIndicator(tester, SyncIndicator.synced, onPressed: () => taps++);

    await tester.tap(find.byType(SyncStatusIndicator));
    expect(taps, 1);
  });
}
