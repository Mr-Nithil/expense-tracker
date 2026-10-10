/// Route names and paths. Navigate by name: `context.goNamed(Routes.dashboard)`.
///
/// Never write path strings in widgets.
abstract final class Routes {
  static const splash = 'splash';
  static const splashPath = '/splash';

  static const login = 'login';
  static const loginPath = '/login';

  static const dashboard = 'dashboard';
  static const dashboardPath = '/';

  static const transactions = 'transactions';
  static const transactionsPath = '/transactions';

  static const budget = 'budget';
  static const budgetPath = '/budget';

  static const settings = 'settings';
  static const settingsPath = '/settings';

  /// Routes reachable without a session.
  static const authPaths = {splashPath, loginPath};
}
