import 'package:expense_tracker/core/l10n/generated/app_localizations_en.dart';
import 'package:expense_tracker/core/sync/initial_sync.dart';
import 'package:expense_tracker/features/auth/presentation/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/accessibility.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  final l10n = AppLocalizationsEn();

  Future<void> pumpSplash(
    WidgetTester tester,
    InitialSyncStatus status, {
    Brightness brightness = Brightness.light,
  }) => tester.pumpApp(
    const SplashScreen(),
    brightness: brightness,
    overrides: [initialSyncProvider.overrideWith(() => _FixedInitialSync(status))],
  );

  testWidgetsBothThemes('shows the app name and a loading indicator', (tester, brightness) async {
    await pumpSplash(tester, InitialSyncStatus.idle, brightness: brightness);

    expect(find.text(l10n.appTitle), findsOneWidget);
    expect(find.byIcon(Icons.account_balance_wallet_outlined), findsOneWidget);
    expect(find.bySemanticsLabel(l10n.commonLoading), findsOneWidget);
    expect(find.text(l10n.authSplashSyncing), findsNothing);
  });

  testWidgetsBothThemes('says it is getting the data during the first pull', (
    tester,
    brightness,
  ) async {
    await pumpSplash(tester, InitialSyncStatus.running, brightness: brightness);

    expect(find.text(l10n.authSplashSyncing), findsOneWidget);
  });

  testWidgets('no message once the first pull is done', (tester) async {
    await pumpSplash(tester, InitialSyncStatus.done);

    expect(find.text(l10n.authSplashSyncing), findsNothing);
  });

  group('accessibility (M9.5)', () {
    testWidgetsBothThemes('meets the guidelines', (tester, brightness) async {
      await pumpSplash(tester, InitialSyncStatus.running, brightness: brightness);
      await expectAccessible(tester);
    });

    testWidgets('large text (2x) fits', (tester) async {
      useTextScale(tester, 2);
      await pumpSplash(tester, InitialSyncStatus.running);
      await tester.pump();
    });
  });
}

class _FixedInitialSync extends InitialSync {
  _FixedInitialSync(this._status);

  final InitialSyncStatus _status;

  @override
  InitialSyncStatus build() => _status;
}
