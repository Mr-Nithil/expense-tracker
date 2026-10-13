import 'package:expense_tracker/core/router/auth_status.dart';
import 'package:expense_tracker/core/router/onboarding_status.dart';
import 'package:expense_tracker/core/router/routes.dart';

/// Router redirect rules, evaluated top to bottom (ARCHITECTURE §9).
///
/// Returns the path to redirect to, or `null` to stay on [location].
/// The app lock is not a redirect: `AppLockGate` (security feature) covers the whole app above the
/// router, so locking keeps the navigation state (M7.5, ARCHITECTURE §9).
String? appRedirect({
  required AuthStatus status,
  required OnboardingStatus onboarding,
  required String location,
}) {
  final isAuthRoute = Routes.authPaths.contains(location);

  return switch (status) {
    AuthStatus.unknown => location == Routes.splashPath ? null : Routes.splashPath,
    AuthStatus.signedOut => Routes.signedOutPaths.contains(location) ? null : Routes.loginPath,
    // Before onboarding: a reset link must not be a way to skip setting the new password.
    AuthStatus.passwordRecovery =>
      location == Routes.resetPasswordPath ? null : Routes.resetPasswordPath,
    AuthStatus.signedIn => switch (onboarding) {
      OnboardingStatus.unknown => location == Routes.splashPath ? null : Routes.splashPath,
      OnboardingStatus.required => location == Routes.onboardingPath ? null : Routes.onboardingPath,
      OnboardingStatus.complete =>
        isAuthRoute || location == Routes.onboardingPath ? Routes.dashboardPath : null,
    },
  };
}
