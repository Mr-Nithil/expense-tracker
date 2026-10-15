import 'package:expense_tracker/core/l10n/generated/app_localizations.dart';
import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'accessibility.dart';
import 'test_database.dart';

export 'finders.dart';

extension PumpApp on WidgetTester {
  /// Pumps [widget] inside a themed, localized [MaterialApp] ([locale], en_US by default) with a
  /// [Scaffold].
  Future<void> pumpApp(
    Widget widget, {
    Brightness brightness = Brightness.light,
    List<Override> overrides = const [],
    Locale locale = const Locale('en', 'US'),
  }) {
    return pumpWidget(
      ProviderScope(
        retry: noAutoRetry,
        overrides: overrides,
        child: MaterialApp(
          theme: brightness == Brightness.light ? AppTheme.light() : AppTheme.dark(),
          locale: locale,
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
    Locale locale = const Locale('en', 'US'),
  }) async {
    final router = GoRouter(initialLocation: initialLocation, routes: routes);
    addTearDown(router.dispose);
    await pumpWidget(
      ProviderScope(
        retry: noAutoRetry,
        overrides: overrides,
        child: MaterialApp.router(
          theme: brightness == Brightness.light ? AppTheme.light() : AppTheme.dark(),
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: const [Locale('en', 'US'), ...AppLocalizations.supportedLocales],
          routerConfig: router,
        ),
      ),
    );
    await pumpAndSettle();
  }
}

/// Runs [body] once in light and once in dark theme, then checks what it left on screen against
/// the accessibility guidelines (tap targets, labels, text contrast; M9.5).
void testWidgetsBothThemes(
  String description,
  Future<void> Function(WidgetTester, Brightness) body,
) {
  for (final brightness in Brightness.values) {
    testWidgets('$description (${brightness.name})', (tester) async {
      await body(tester, brightness);
      await expectAccessible(tester);
    });
  }
}
