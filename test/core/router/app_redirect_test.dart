import 'package:expense_tracker/core/router/app_redirect.dart';
import 'package:expense_tracker/core/router/auth_status.dart';
import 'package:expense_tracker/core/router/routes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  String? redirect(AuthStatus status, String location) =>
      appRedirect(status: status, location: location);

  group('while the session is restoring', () {
    test('everything goes to splash', () {
      expect(redirect(AuthStatus.unknown, Routes.dashboardPath), Routes.splashPath);
      expect(redirect(AuthStatus.unknown, Routes.loginPath), Routes.splashPath);
    });

    test('splash stays', () {
      expect(redirect(AuthStatus.unknown, Routes.splashPath), isNull);
    });
  });

  group('signed out', () {
    test('app routes go to login', () {
      expect(redirect(AuthStatus.signedOut, Routes.dashboardPath), Routes.loginPath);
      expect(redirect(AuthStatus.signedOut, Routes.settingsPath), Routes.loginPath);
      expect(redirect(AuthStatus.signedOut, Routes.splashPath), Routes.loginPath);
    });

    test('login stays', () {
      expect(redirect(AuthStatus.signedOut, Routes.loginPath), isNull);
    });
  });

  group('signed in', () {
    test('auth routes go to the dashboard', () {
      expect(redirect(AuthStatus.signedIn, Routes.loginPath), Routes.dashboardPath);
      expect(redirect(AuthStatus.signedIn, Routes.splashPath), Routes.dashboardPath);
    });

    test('app routes stay', () {
      for (final path in [
        Routes.dashboardPath,
        Routes.transactionsPath,
        Routes.budgetPath,
        Routes.settingsPath,
      ]) {
        expect(redirect(AuthStatus.signedIn, path), isNull, reason: path);
      }
    });
  });
}
