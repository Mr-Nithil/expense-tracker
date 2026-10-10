import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// App name shown in the task switcher and title bar
  ///
  /// In en, this message translates to:
  /// **'Expense Tracker'**
  String get appTitle;

  /// Shown after the sign-up confirmation email was sent again
  ///
  /// In en, this message translates to:
  /// **'Confirmation email sent. Check your inbox.'**
  String get authConfirmationResent;

  /// Label of the field that repeats the new password on sign-up
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get authConfirmPasswordLabel;

  /// Label of the optional display-name field on sign-up
  ///
  /// In en, this message translates to:
  /// **'Name (optional)'**
  String get authDisplayNameLabel;

  /// Label of the email field on the login, sign-up and forgot-password screens
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmailLabel;

  /// Button on the reset-link-sent view that returns to the login screen
  ///
  /// In en, this message translates to:
  /// **'Back to sign in'**
  String get authForgotPasswordBackToLogin;

  /// Shown after requesting a reset link. Neutral on purpose: never reveals whether the email has an account
  ///
  /// In en, this message translates to:
  /// **'If an account exists for {email}, we\'ve sent a link to reset your password.'**
  String authForgotPasswordSentMessage(String email);

  /// Title of the view shown after a reset link was requested
  ///
  /// In en, this message translates to:
  /// **'Check your email'**
  String get authForgotPasswordSentTitle;

  /// Submit button of the forgot-password form
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get authForgotPasswordSubmit;

  /// Intro text above the forgot-password form
  ///
  /// In en, this message translates to:
  /// **'Enter your account email and we\'ll send you a link to reset your password.'**
  String get authForgotPasswordSubtitle;

  /// Title of the forgot-password screen
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get authForgotPasswordTitle;

  /// Tooltip of the button that hides the typed password
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get authHidePassword;

  /// Link on the login screen that opens the forgot-password screen
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get authLoginForgotPassword;

  /// Link on the login screen that opens the sign-up screen
  ///
  /// In en, this message translates to:
  /// **'New here? Create an account'**
  String get authLoginGoToSignUp;

  /// Submit button of the login form
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authLoginSubmit;

  /// Short intro text above the login form
  ///
  /// In en, this message translates to:
  /// **'Welcome back. Sign in to continue.'**
  String get authLoginSubtitle;

  /// Title of the login screen
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authLoginTitle;

  /// Label of the password field
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPasswordLabel;

  /// Label of the new-password field on the reset-password screen
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get authNewPasswordLabel;

  /// Hint inside the new-password field on sign-up
  ///
  /// In en, this message translates to:
  /// **'At least {minLength} characters'**
  String authPasswordHint(int minLength);

  /// Snackbar action that sends the sign-up confirmation email again
  ///
  /// In en, this message translates to:
  /// **'Resend email'**
  String get authResendConfirmation;

  /// Leaves the reset-password screen without changing the password; signs out
  ///
  /// In en, this message translates to:
  /// **'Cancel and sign out'**
  String get authResetPasswordCancel;

  /// Submit button of the reset-password form
  ///
  /// In en, this message translates to:
  /// **'Save password'**
  String get authResetPasswordSubmit;

  /// Intro on the reset-password screen opened from the email link
  ///
  /// In en, this message translates to:
  /// **'Choose a new password for {email}.'**
  String authResetPasswordSubtitle(String email);

  /// Title of the screen opened from a password-reset email link
  ///
  /// In en, this message translates to:
  /// **'Set a new password'**
  String get authResetPasswordTitle;

  /// Tooltip of the button that reveals the typed password
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get authShowPassword;

  /// Shown after sign-up when the account needs email confirmation
  ///
  /// In en, this message translates to:
  /// **'Account created. Check your email to confirm it, then sign in.'**
  String get authSignUpConfirmEmailSent;

  /// Submit button of the sign-up form
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authSignUpSubmit;

  /// Short intro text above the sign-up form
  ///
  /// In en, this message translates to:
  /// **'Track your spending across all your devices.'**
  String get authSignUpSubtitle;

  /// Title of the sign-up screen
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authSignUpTitle;

  /// Title of the budget tab and its bottom navigation label
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get budgetTitle;

  /// Generic cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// Body text of a placeholder screen
  ///
  /// In en, this message translates to:
  /// **'This screen is still being built.'**
  String get commonComingSoonMessage;

  /// Title of a placeholder screen
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get commonComingSoonTitle;

  /// Generic confirm button in dialogs
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get commonConfirm;

  /// Generic delete button
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// Accessibility label for a loading indicator
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get commonLoading;

  /// Button to retry a failed action
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// Generic save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// Section header action that opens the full list
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get commonSeeAll;

  /// Snackbar action that reverts the last change
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get commonUndo;

  /// Title of the dashboard tab and its bottom navigation label
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardTitle;

  /// Shown for AuthFailure with no more specific reason
  ///
  /// In en, this message translates to:
  /// **'Authentication failed. Please sign in again.'**
  String get errorAuth;

  /// Sign-up failed because the email is already registered
  ///
  /// In en, this message translates to:
  /// **'An account with this email already exists. Try signing in instead.'**
  String get errorAuthEmailExists;

  /// Sign-in failed because the email address is not confirmed yet
  ///
  /// In en, this message translates to:
  /// **'Please confirm your email first. Check your inbox for the link.'**
  String get errorAuthEmailNotConfirmed;

  /// Sign-in failed because the email or password is wrong
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password.'**
  String get errorAuthInvalidCredentials;

  /// An email link (confirmation or password reset) expired or was already used
  ///
  /// In en, this message translates to:
  /// **'This link has expired or was already used. Please request a new one.'**
  String get errorAuthLinkExpired;

  /// An email link could not be used, e.g. opened on a different device than the one that requested it
  ///
  /// In en, this message translates to:
  /// **'This link can\'t be used here. Open it on the device where you requested it, or request a new one.'**
  String get errorAuthLinkInvalid;

  /// The auth server rejected the request because of rate limiting
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please wait a moment and try again.'**
  String get errorAuthRateLimited;

  /// Setting a new password failed because it equals the current one
  ///
  /// In en, this message translates to:
  /// **'Your new password must be different from the old one.'**
  String get errorAuthSamePassword;

  /// Sign-up failed because the server rejected the password as weak
  ///
  /// In en, this message translates to:
  /// **'This password is too weak. Choose a stronger one.'**
  String get errorAuthWeakPassword;

  /// Form field error for a malformed email address
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get errorEmailInvalid;

  /// Form field error for an empty required field
  ///
  /// In en, this message translates to:
  /// **'This field is required.'**
  String get errorFieldRequired;

  /// Shown for NetworkFailure
  ///
  /// In en, this message translates to:
  /// **'Can\'t reach the server. Check your connection and try again.'**
  String get errorNetwork;

  /// Shown for NotFoundFailure
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find that item. It may have been deleted.'**
  String get errorNotFound;

  /// Form field error when the confirm-password field differs from the password
  ///
  /// In en, this message translates to:
  /// **'Passwords don\'t match.'**
  String get errorPasswordMismatch;

  /// Form field error when a new password is shorter than the minimum
  ///
  /// In en, this message translates to:
  /// **'Use at least {minLength} characters.'**
  String errorPasswordTooShort(int minLength);

  /// Shown for StorageFailure
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save on this device. Please try again.'**
  String get errorStorage;

  /// Shown for UnexpectedFailure and unknown errors
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorUnexpected;

  /// Shown for ValidationFailure when no field-specific message exists
  ///
  /// In en, this message translates to:
  /// **'Please check the highlighted fields.'**
  String get errorValidation;

  /// Button that saves the chosen currency and finishes onboarding
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onboardingContinue;

  /// Example amount shown under each currency; amount is pre-formatted money
  ///
  /// In en, this message translates to:
  /// **'e.g. {amount}'**
  String onboardingCurrencyExample(String amount);

  /// Line under the currency that matches the device region; amount is pre-formatted money
  ///
  /// In en, this message translates to:
  /// **'Suggested · e.g. {amount}'**
  String onboardingCurrencySuggestedExample(String amount);

  /// Explanation above the currency list on the onboarding screen
  ///
  /// In en, this message translates to:
  /// **'All amounts in the app use this currency. It can\'t be changed later.'**
  String get onboardingSubtitle;

  /// Title of the onboarding (currency selection) screen
  ///
  /// In en, this message translates to:
  /// **'Choose your currency'**
  String get onboardingTitle;

  /// Settings section header for account actions (log out)
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAccountLabel;

  /// Settings button and confirm action that signs the user out of this device
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get settingsLogout;

  /// Confirm action of the logout dialog when unsynced changes would be lost
  ///
  /// In en, this message translates to:
  /// **'Log out anyway'**
  String get settingsLogoutAnyway;

  /// Logout dialog message when everything is synced
  ///
  /// In en, this message translates to:
  /// **'You\'ll need to sign in again to use the app on this device.'**
  String get settingsLogoutConfirmMessage;

  /// Title of the logout confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Log out?'**
  String get settingsLogoutConfirmTitle;

  /// Logout dialog warning when unsynced local changes would be deleted
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 change on this device hasn\'t synced yet. If you log out now, it will be lost.} other{{count} changes on this device haven\'t synced yet. If you log out now, they will be lost.}}'**
  String settingsLogoutPendingMessage(int count);

  /// Theme option: always dark
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// Label of the theme mode setting
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsThemeLabel;

  /// Theme option: always light
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// Theme option: follow the device setting
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// Title of the settings tab and its bottom navigation label
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Title of the transactions tab and its bottom navigation label
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactionsTitle;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
