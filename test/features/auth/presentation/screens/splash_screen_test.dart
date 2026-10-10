import 'package:expense_tracker/core/l10n/generated/app_localizations_en.dart';
import 'package:expense_tracker/features/auth/presentation/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  final l10n = AppLocalizationsEn();

  testWidgetsBothThemes('shows the app name and a loading indicator', (tester, brightness) async {
    await tester.pumpApp(const SplashScreen(), brightness: brightness);

    expect(find.text(l10n.appTitle), findsOneWidget);
    expect(find.byIcon(Icons.account_balance_wallet_outlined), findsOneWidget);
    expect(find.bySemanticsLabel(l10n.commonLoading), findsOneWidget);
  });
}
