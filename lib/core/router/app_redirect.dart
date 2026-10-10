import 'package:expense_tracker/core/router/auth_status.dart';
import 'package:expense_tracker/core/router/routes.dart';

/// Router redirect rules, evaluated top to bottom (ARCHITECTURE §9).
///
/// Returns the path to redirect to, or `null` to stay on [location].
/// Onboarding (M1.8) and app lock (M7.5) rules are added here later.
String? appRedirect({required AuthStatus status, required String location}) {
  final isAuthRoute = Routes.authPaths.contains(location);

  return switch (status) {
    AuthStatus.unknown => location == Routes.splashPath ? null : Routes.splashPath,
    AuthStatus.signedOut => location == Routes.loginPath ? null : Routes.loginPath,
    AuthStatus.signedIn => isAuthRoute ? Routes.dashboardPath : null,
  };
}
