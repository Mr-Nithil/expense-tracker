import 'package:expense_tracker/app.dart';
import 'package:expense_tracker/core/db/database_provider.dart';
import 'package:expense_tracker/core/l10n/generated/app_localizations_en.dart';
import 'package:expense_tracker/core/router/auth_status.dart';
import 'package:expense_tracker/core/theme/theme_mode_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_database.dart';

void main() {
  final l10n = AppLocalizationsEn();

  Future<ProviderContainer> pumpApp(WidgetTester tester) async {
    final container = createTestContainer();
    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const App()));
    await tester.pumpAndSettle();
    return container;
  }

  NavigationBar navBar(WidgetTester tester) => tester.widget(find.byType(NavigationBar));

  testWidgets('opens on the dashboard tab', (tester) async {
    await pumpApp(tester);

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(navBar(tester).selectedIndex, 0);
    expect(find.widgetWithText(AppBar, l10n.dashboardTitle), findsOneWidget);
  });

  testWidgets('bottom navigation switches between the four tabs', (tester) async {
    await pumpApp(tester);

    final tabs = [
      l10n.transactionsTitle,
      l10n.budgetTitle,
      l10n.settingsTitle,
      l10n.dashboardTitle,
    ];
    for (final (index, title) in tabs.indexed) {
      await tester.tap(find.descendant(of: find.byType(NavigationBar), matching: find.text(title)));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, title), findsOneWidget);
      expect(navBar(tester).selectedIndex, (index + 1) % 4);
    }
  });

  testWidgets('signing out redirects to login, signing in returns to the app', (tester) async {
    final container = await pumpApp(tester);

    container.read(authStatusControllerProvider.notifier).set(AuthStatus.signedOut);
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, l10n.authLoginTitle), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    container.read(authStatusControllerProvider.notifier).set(AuthStatus.signedIn);
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('theme picker in settings switches to dark mode and persists it', (tester) async {
    final container = await pumpApp(tester);

    await tester.tap(
      find.descendant(of: find.byType(NavigationBar), matching: find.text(l10n.settingsTitle)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.settingsThemeDark));
    await tester.pumpAndSettle();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
    final stored = await tester.runAsync(
      () =>
          container.read(databaseProvider).appSettingsDao.getValue(ThemeModeController.settingsKey),
    );
    expect(stored, 'dark');
  });
}
