/// Route names and paths. Navigate by name: `context.goNamed(Routes.dashboard)`.
///
/// Never write path strings in widgets.
abstract final class Routes {
  static const splash = 'splash';
  static const splashPath = '/splash';

  static const login = 'login';
  static const loginPath = '/login';

  static const signUp = 'signUp';
  static const signUpPath = '/sign-up';

  static const forgotPassword = 'forgotPassword';
  static const forgotPasswordPath = '/forgot-password';

  static const resetPassword = 'resetPassword';
  static const resetPasswordPath = '/reset-password';

  static const onboarding = 'onboarding';
  static const onboardingPath = '/onboarding';

  static const dashboard = 'dashboard';
  static const dashboardPath = '/';

  static const transactions = 'transactions';
  static const transactionsPath = '/transactions';

  static const budget = 'budget';
  static const budgetPath = '/budget';

  static const settings = 'settings';
  static const settingsPath = '/settings';

  /// Routes of the auth flow. A signed-in user is sent from these to the dashboard.
  static const authPaths = {
    splashPath,
    loginPath,
    signUpPath,
    forgotPasswordPath,
    resetPasswordPath,
  };

  /// Routes a signed-out user may stay on. Everything else redirects to login.
  static const signedOutPaths = {loginPath, signUpPath, forgotPasswordPath};
}
