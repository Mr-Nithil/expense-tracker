import 'package:expense_tracker/core/l10n/generated/app_localizations.dart';
import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'test_database.dart';

extension PumpApp on WidgetTester {
  /// Pumps [widget] inside a themed, localized [MaterialApp] (en_US) with a [Scaffold].
  Future<void> pumpApp(
    Widget widget, {
    Brightness brightness = Brightness.light,
    List<Override> overrides = const [],
  }) {
    return pumpWidget(
      ProviderScope(
        retry: noAutoRetry,
        overrides: overrides,
        child: MaterialApp(
          theme: brightness == Brightness.light ? AppTheme.light() : AppTheme.dark(),
          locale: const Locale('en', 'US'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: const [Locale('en', 'US'), ...AppLocalizations.supportedLocales],
          home: Scaffold(body: widget),
        ),
      ),
    );
  }
}

extension PumpRouterApp on WidgetTester {
  /// Pumps a themed, localized [MaterialApp.router] with only [routes], for screens that
  /// navigate. Settles before returning.
  Future<void> pumpRouterApp({
    required List<RouteBase> routes,
    required String initialLocation,
    Brightness brightness = Brightness.light,
    List<Override> overrides = const [],
  }) async {
    final router = GoRouter(initialLocation: initialLocation, routes: routes);
    addTearDown(router.dispose);
    await pumpWidget(
      ProviderScope(
        retry: noAutoRetry,
        overrides: overrides,
        child: MaterialApp.router(
          theme: brightness == Brightness.light ? AppTheme.light() : AppTheme.dark(),
          locale: const Locale('en', 'US'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: const [Locale('en', 'US'), ...AppLocalizations.supportedLocales],
          routerConfig: router,
        ),
      ),
    );
    await pumpAndSettle();
  }
}

/// Runs [body] once in light and once in dark theme.
void testWidgetsBothThemes(
  String description,
  Future<void> Function(WidgetTester, Brightness) body,
) {
  for (final brightness in Brightness.values) {
    testWidgets('$description (${brightness.name})', (tester) => body(tester, brightness));
  }
}
