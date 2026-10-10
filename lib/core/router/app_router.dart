import 'package:expense_tracker/core/router/app_redirect.dart';
import 'package:expense_tracker/core/router/app_shell.dart';
import 'package:expense_tracker/core/router/auth_status.dart';
import 'package:expense_tracker/core/router/routes.dart';
import 'package:expense_tracker/features/auth/presentation/screens/login_screen.dart';
import 'package:expense_tracker/features/auth/presentation/screens/splash_screen.dart';
import 'package:expense_tracker/features/budget/presentation/screens/budget_screen.dart';
import 'package:expense_tracker/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:expense_tracker/features/settings/presentation/screens/settings_screen.dart';
import 'package:expense_tracker/features/transactions/presentation/screens/transactions_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

/// The app router. This file is the routing composition root: the only core file allowed to
/// import feature screens (ARCHITECTURE §3).
@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  final authStatus = ValueNotifier(ref.read(authStatusControllerProvider));
  ref.listen(authStatusControllerProvider, (_, next) => authStatus.value = next);

  final router = GoRouter(
    initialLocation: Routes.dashboardPath,
    refreshListenable: authStatus,
    redirect: (context, state) =>
        appRedirect(status: authStatus.value, location: state.matchedLocation),
    routes: [
      GoRoute(
        name: Routes.splash,
        path: Routes.splashPath,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        name: Routes.login,
        path: Routes.loginPath,
        builder: (context, state) => const LoginScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: Routes.dashboard,
                path: Routes.dashboardPath,
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: Routes.transactions,
                path: Routes.transactionsPath,
                builder: (context, state) => const TransactionsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: Routes.budget,
                path: Routes.budgetPath,
                builder: (context, state) => const BudgetScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: Routes.settings,
                path: Routes.settingsPath,
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  ref.onDispose(() {
    authStatus.dispose();
    router.dispose();
  });
  return router;
}
