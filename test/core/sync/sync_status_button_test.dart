import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/l10n/generated/app_localizations_en.dart';
import 'package:expense_tracker/core/sync/sync_status.dart';
import 'package:expense_tracker/core/sync/sync_status_button.dart';
import 'package:expense_tracker/core/widgets/sync_status_indicator.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_sync_trigger.dart';
import '../../helpers/pump_app.dart';

void main() {
  final l10n = AppLocalizationsEn();

  late FakeSyncTrigger trigger;

  setUp(() => trigger = FakeSyncTrigger());

  Future<void> pumpButton(WidgetTester tester, SyncStatusInfo info) async {
    await tester.pumpApp(
      const SyncStatusButton(),
      overrides: [
        syncStatusProvider.overrideWith((ref) => Stream.value(info)),
        trigger.providerOverride,
      ],
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows the live state', (tester) async {
    await pumpButton(tester, const SyncStatusInfo(SyncIndicator.pending, pendingCount: 2));

    final indicator = tester.widget<SyncStatusIndicator>(find.byType(SyncStatusIndicator));
    expect(indicator.indicator, SyncIndicator.pending);
    expect(indicator.pendingCount, 2);
  });

  testWidgets('tapping syncs now', (tester) async {
    await pumpButton(tester, const SyncStatusInfo(SyncIndicator.synced));

    await tester.tap(find.byType(SyncStatusIndicator));
    await tester.pumpAndSettle();

    expect(trigger.immediate, 1);
  });

  testWidgets('a failed sync says why', (tester) async {
    trigger.nowResult = const Result.failure(NetworkFailure('offline'));
    await pumpButton(tester, const SyncStatusInfo(SyncIndicator.pending, pendingCount: 1));

    await tester.tap(find.byType(SyncStatusIndicator));
    await tester.pumpAndSettle();

    expect(find.text(l10n.errorNetwork), findsOneWidget);
  });
}
