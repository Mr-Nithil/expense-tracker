// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Expense Tracker';

  @override
  String get authConfirmationResent => 'Confirmation email sent. Check your inbox.';

  @override
  String get authConfirmPasswordLabel => 'Confirm password';

  @override
  String get authDisplayNameLabel => 'Name (optional)';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authForgotPasswordBackToLogin => 'Back to sign in';

  @override
  String authForgotPasswordSentMessage(String email) {
    return 'If an account exists for $email, we\'ve sent a link to reset your password.';
  }

  @override
  String get authForgotPasswordSentTitle => 'Check your email';

  @override
  String get authForgotPasswordSubmit => 'Send reset link';

  @override
  String get authForgotPasswordSubtitle =>
      'Enter your account email and we\'ll send you a link to reset your password.';

  @override
  String get authForgotPasswordTitle => 'Reset password';

  @override
  String get authHidePassword => 'Hide password';

  @override
  String get authLoginForgotPassword => 'Forgot password?';

  @override
  String get authLoginGoToSignUp => 'New here? Create an account';

  @override
  String get authLoginSubmit => 'Sign in';

  @override
  String get authLoginSubtitle => 'Welcome back. Sign in to continue.';

  @override
  String get authLoginTitle => 'Sign in';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authNewPasswordLabel => 'New password';

  @override
  String authPasswordHint(int minLength) {
    return 'At least $minLength characters';
  }

  @override
  String get authResendConfirmation => 'Resend email';

  @override
  String get authResetPasswordCancel => 'Cancel and sign out';

  @override
  String get authResetPasswordSubmit => 'Save password';

  @override
  String authResetPasswordSubtitle(String email) {
    return 'Choose a new password for $email.';
  }

  @override
  String get authResetPasswordTitle => 'Set a new password';

  @override
  String get authShowPassword => 'Show password';

  @override
  String get authSignUpConfirmEmailSent =>
      'Account created. Check your email to confirm it, then sign in.';

  @override
  String get authSignUpSubmit => 'Create account';

  @override
  String get authSignUpSubtitle => 'Track your spending across all your devices.';

  @override
  String get authSignUpTitle => 'Create account';

  @override
  String get budgetTitle => 'Budget';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonComingSoonMessage => 'This screen is still being built.';

  @override
  String get commonComingSoonTitle => 'Coming soon';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonLoading => 'Loading';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonSave => 'Save';

  @override
  String get commonSeeAll => 'See all';

  @override
  String get commonUndo => 'Undo';

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get errorAuth => 'Authentication failed. Please sign in again.';

  @override
  String get errorAuthEmailExists =>
      'An account with this email already exists. Try signing in instead.';

  @override
  String get errorAuthEmailNotConfirmed =>
      'Please confirm your email first. Check your inbox for the link.';

  @override
  String get errorAuthInvalidCredentials => 'Incorrect email or password.';

  @override
  String get errorAuthLinkExpired =>
      'This link has expired or was already used. Please request a new one.';

  @override
  String get errorAuthLinkInvalid =>
      'This link can\'t be used here. Open it on the device where you requested it, or request a new one.';

  @override
  String get errorAuthRateLimited => 'Too many attempts. Please wait a moment and try again.';

  @override
  String get errorAuthSamePassword => 'Your new password must be different from the old one.';

  @override
  String get errorAuthWeakPassword => 'This password is too weak. Choose a stronger one.';

  @override
  String get errorEmailInvalid => 'Enter a valid email address.';

  @override
  String get errorFieldRequired => 'This field is required.';

  @override
  String get errorNetwork => 'Can\'t reach the server. Check your connection and try again.';

  @override
  String get errorNotFound => 'We couldn\'t find that item. It may have been deleted.';

  @override
  String get errorPasswordMismatch => 'Passwords don\'t match.';

  @override
  String errorPasswordTooShort(int minLength) {
    return 'Use at least $minLength characters.';
  }

  @override
  String get errorStorage => 'Couldn\'t save on this device. Please try again.';

  @override
  String get errorUnexpected => 'Something went wrong. Please try again.';

  @override
  String get errorValidation => 'Please check the highlighted fields.';

  @override
  String get onboardingContinue => 'Continue';

  @override
  String onboardingCurrencyExample(String amount) {
    return 'e.g. $amount';
  }

  @override
  String onboardingCurrencySuggestedExample(String amount) {
    return 'Suggested · e.g. $amount';
  }

  @override
  String get onboardingSubtitle =>
      'All amounts in the app use this currency. It can\'t be changed later.';

  @override
  String get onboardingTitle => 'Choose your currency';

  @override
  String get settingsAccountLabel => 'Account';

  @override
  String get settingsLogout => 'Log out';

  @override
  String get settingsLogoutAnyway => 'Log out anyway';

  @override
  String get settingsLogoutConfirmMessage =>
      'You\'ll need to sign in again to use the app on this device.';

  @override
  String get settingsLogoutConfirmTitle => 'Log out?';

  @override
  String settingsLogoutPendingMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count changes on this device haven\'t synced yet. If you log out now, they will be lost.',
      one: '1 change on this device hasn\'t synced yet. If you log out now, it will be lost.',
    );
    return '$_temp0';
  }

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeLabel => 'Theme';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get transactionsTitle => 'Transactions';
}
