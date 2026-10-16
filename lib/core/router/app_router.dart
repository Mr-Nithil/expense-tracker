import 'package:expense_tracker/core/router/app_redirect.dart';
import 'package:expense_tracker/core/router/app_shell.dart';
import 'package:expense_tracker/core/router/auth_status.dart';
import 'package:expense_tracker/core/router/onboarding_status.dart';
import 'package:expense_tracker/core/router/routes.dart';
import 'package:expense_tracker/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:expense_tracker/features/auth/presentation/screens/login_screen.dart';
import 'package:expense_tracker/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:expense_tracker/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:expense_tracker/features/auth/presentation/screens/splash_screen.dart';
import 'package:expense_tracker/features/budget/presentation/screens/budget_screen.dart';
import 'package:expense_tracker/features/categories/presentation/screens/categories_screen.dart';
import 'package:expense_tracker/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:expense_tracker/features/goals/presentation/screens/goal_detail_screen.dart';
import 'package:expense_tracker/features/goals/presentation/screens/goals_screen.dart';
import 'package:expense_tracker/features/profile/presentation/screens/onboarding_screen.dart';
import 'package:expense_tracker/features/reminders/presentation/screens/reminders_screen.dart';
import 'package:expense_tracker/features/settings/presentation/screens/design_gallery_screen.dart';
import 'package:expense_tracker/features/settings/presentation/screens/settings_screen.dart';
import 'package:expense_tracker/features/transactions/presentation/screens/transaction_detail_screen.dart';
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

  // Loading (including a reload after the user changed) counts as unknown → splash.
  OnboardingStatus onboardingOf(AsyncValue<OnboardingStatus> value) =>
      value.isLoading ? OnboardingStatus.unknown : value.value ?? OnboardingStatus.unknown;
  final onboarding = ValueNotifier(onboardingOf(ref.read(onboardingStatusProvider)));
  ref.listen(onboardingStatusProvider, (_, next) => onboarding.value = onboardingOf(next));

  final router = GoRouter(
    initialLocation: Routes.dashboardPath,
    refreshListenable: Listenable.merge([authStatus, onboarding]),
    redirect: (context, state) => appRedirect(
      status: authStatus.value,
      onboarding: onboarding.value,
      location: state.matchedLocation,
    ),
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
      GoRoute(
        name: Routes.signUp,
        path: Routes.signUpPath,
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        name: Routes.forgotPassword,
        path: Routes.forgotPasswordPath,
        builder: (context, state) => ForgotPasswordScreen(initialEmail: state.extra as String?),
      ),
      GoRoute(
        name: Routes.resetPassword,
        path: Routes.resetPasswordPath,
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      GoRoute(
        name: Routes.onboarding,
        path: Routes.onboardingPath,
        builder: (context, state) => const OnboardingScreen(),
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
                routes: [
                  GoRoute(
                    name: Routes.transactionDetail,
                    // Relative to transactions: the full path is Routes.transactionDetailPath.
                    path: ':${Routes.transactionIdParam}',
                    builder: (context, state) => TransactionDetailScreen(
                      id: state.pathParameters[Routes.transactionIdParam]!,
                    ),
                  ),
                ],
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
                name: Routes.goals,
                path: Routes.goalsPath,
                builder: (context, state) => const GoalsScreen(),
                routes: [
                  GoRoute(
                    name: Routes.goalDetail,
                    // Relative to goals: the full path is Routes.goalDetailPath.
                    path: ':${Routes.goalIdParam}',
                    builder: (context, state) =>
                        GoalDetailScreen(id: state.pathParameters[Routes.goalIdParam]!),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: Routes.settings,
                path: Routes.settingsPath,
                builder: (context, state) => const SettingsScreen(),
                routes: [
                  GoRoute(
                    name: Routes.categories,
                    // Relative to settings: the full path is Routes.categoriesPath.
                    path: Routes.categoriesPath.substring(Routes.settingsPath.length + 1),
                    builder: (context, state) => const CategoriesScreen(),
                  ),
                  GoRoute(
                    name: Routes.reminders,
                    // Relative to settings: the full path is Routes.remindersPath.
                    path: Routes.remindersPath.substring(Routes.settingsPath.length + 1),
                    builder: (context, state) => const RemindersScreen(),
                  ),
                  if (kDebugMode)
                    GoRoute(
                      name: Routes.designGallery,
                      // Relative to settings: the full path is Routes.designGalleryPath.
                      path: Routes.designGalleryPath.substring(Routes.settingsPath.length + 1),
                      builder: (context, state) => const DesignGalleryScreen(),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );

  ref.onDispose(() {
    authStatus.dispose();
    onboarding.dispose();
    router.dispose();
  });
  return router;
}
