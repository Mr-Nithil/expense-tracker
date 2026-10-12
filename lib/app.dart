import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/l10n/generated/app_localizations.dart';
import 'package:expense_tracker/core/l10n/locale_controller.dart';
import 'package:expense_tracker/core/router/app_router.dart';
import 'package:expense_tracker/core/services/local_notification_service.dart';
import 'package:expense_tracker/core/sync/sync_scheduler.dart';
import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/core/theme/theme_mode_controller.dart';
import 'package:expense_tracker/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:expense_tracker/features/auth/presentation/widgets/auth_link_error_listener.dart';
import 'package:expense_tracker/features/budget/presentation/providers/budget_alert_watcher.dart';
import 'package:expense_tracker/features/reminders/presentation/providers/reminder_scheduler.dart';
import 'package:expense_tracker/notification_tap_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Starts the session → router binding for the app's lifetime.
    ref.watch(authStatusBindingProvider);
    // Automatic sync while signed in (start, resume, connectivity).
    ref.watch(syncSchedulerProvider);
    // Local notifications: time zone, plugin, channels (never asks for permission here).
    ref.watch(notificationSetupProvider);
    // This device's reminder notifications follow its reminders (incl. changes from sync).
    ref.watch(reminderSchedulerProvider);
    // Budget alerts at 80% / 100% (when the user turned them on).
    ref.watch(budgetAlertWatcherProvider);
    // A tapped notification opens its screen (held until signed in and onboarded).
    ref.watch(notificationTapRouterProvider);
    return MaterialApp.router(
      onGenerateTitle: (context) => context.l10n.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ref.watch(themeModeControllerProvider).value ?? ThemeMode.system,
      locale: ref.watch(localeControllerProvider),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: ref.watch(routerProvider),
      // Inside the app's localizations and scaffold messenger, above every route.
      builder: (context, child) => AuthLinkErrorListener(child: child!),
    );
  }
}
