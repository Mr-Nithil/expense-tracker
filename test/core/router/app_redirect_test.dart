import 'package:expense_tracker/core/router/app_redirect.dart';
import 'package:expense_tracker/core/router/auth_status.dart';
import 'package:expense_tracker/core/router/onboarding_status.dart';
import 'package:expense_tracker/core/router/routes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  String? redirect(
    AuthStatus status,
    String location, {
    OnboardingStatus onboarding = OnboardingStatus.complete,
  }) => appRedirect(status: status, onboarding: onboarding, location: location);

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

    test('unknown locations go to login', () {
      expect(redirect(AuthStatus.signedOut, '/does-not-exist'), Routes.loginPath);
    });

    test('login, sign-up and forgot-password stay', () {
      expect(redirect(AuthStatus.signedOut, Routes.loginPath), isNull);
      expect(redirect(AuthStatus.signedOut, Routes.signUpPath), isNull);
      expect(redirect(AuthStatus.signedOut, Routes.forgotPasswordPath), isNull);
    });
  });

  group('signed in', () {
    test('auth routes go to the dashboard', () {
      expect(redirect(AuthStatus.signedIn, Routes.loginPath), Routes.dashboardPath);
      expect(redirect(AuthStatus.signedIn, Routes.splashPath), Routes.dashboardPath);
      expect(redirect(AuthStatus.signedIn, Routes.signUpPath), Routes.dashboardPath);
      expect(redirect(AuthStatus.signedIn, Routes.forgotPasswordPath), Routes.dashboardPath);
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

  group('signed in, onboarding', () {
    test('while the profile loads, everything waits on splash', () {
      for (final path in [Routes.dashboardPath, Routes.loginPath, Routes.onboardingPath]) {
        expect(
          redirect(AuthStatus.signedIn, path, onboarding: OnboardingStatus.unknown),
          Routes.splashPath,
          reason: path,
        );
      }
      expect(
        redirect(AuthStatus.signedIn, Routes.splashPath, onboarding: OnboardingStatus.unknown),
        isNull,
      );
    });

    test('without a currency, everything goes to onboarding', () {
      for (final path in [Routes.dashboardPath, Routes.settingsPath, Routes.splashPath]) {
        expect(
          redirect(AuthStatus.signedIn, path, onboarding: OnboardingStatus.required),
          Routes.onboardingPath,
          reason: path,
        );
      }
      expect(
        redirect(AuthStatus.signedIn, Routes.onboardingPath, onboarding: OnboardingStatus.required),
        isNull,
      );
    });

    test('once complete, onboarding goes to the dashboard', () {
      expect(redirect(AuthStatus.signedIn, Routes.onboardingPath), Routes.dashboardPath);
    });

    test('signed out never reaches onboarding', () {
      expect(redirect(AuthStatus.signedOut, Routes.onboardingPath), Routes.loginPath);
    });
  });

  group('password recovery', () {
    test('everything goes to reset-password, which stays', () {
      for (final path in [Routes.dashboardPath, Routes.loginPath, Routes.onboardingPath]) {
        expect(
          redirect(AuthStatus.passwordRecovery, path, onboarding: OnboardingStatus.required),
          Routes.resetPasswordPath,
          reason: path,
        );
      }
      expect(redirect(AuthStatus.passwordRecovery, Routes.resetPasswordPath), isNull);
    });

    test('reset-password is not reachable outside recovery', () {
      expect(redirect(AuthStatus.signedIn, Routes.resetPasswordPath), Routes.dashboardPath);
      expect(redirect(AuthStatus.signedOut, Routes.resetPasswordPath), Routes.loginPath);
    });
  });
}
