import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_si.dart';

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
  static const List<Locale> supportedLocales = <Locale>[Locale('en'), Locale('si')];

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

  /// Splash screen line while the first sync on this device downloads the user's data
  ///
  /// In en, this message translates to:
  /// **'Getting your data…'**
  String get authSplashSyncing;

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

  /// Button and tooltip that open the sheet to add a budget for the shown month
  ///
  /// In en, this message translates to:
  /// **'Add budget'**
  String get budgetAdd;

  /// Budget alert notification body; both pre-formatted money
  ///
  /// In en, this message translates to:
  /// **'{spent} of {limit} spent this month.'**
  String budgetAlertBody(String spent, String limit);

  /// Budget alert notification title at 100% or more; name is the category name or 'Overall budget'
  ///
  /// In en, this message translates to:
  /// **'{name}: limit reached'**
  String budgetAlertExceededTitle(String name);

  /// Budget alert notification title from 80%; name is the category name or 'Overall budget'
  ///
  /// In en, this message translates to:
  /// **'{name}: {percent}% used'**
  String budgetAlertWarningTitle(String name, int percent);

  /// Section header above the per-category budgets on the budget screen
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get budgetCategoriesHeader;

  /// Snackbar after copying last month's budgets; count is how many were added (budgets the month already had are kept)
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Nothing new to copy from last month.} =1{Copied 1 budget from last month.} other{Copied {count} budgets from last month.}}'**
  String budgetCopied(int count);

  /// Action that copies the previous month's budgets into the shown month
  ///
  /// In en, this message translates to:
  /// **'Copy last month\'s budgets'**
  String get budgetCopyPrevious;

  /// Empty state message of the budget screen when the month has no budgets
  ///
  /// In en, this message translates to:
  /// **'Set a monthly limit to see how your spending is tracking.'**
  String get budgetEmptyMessage;

  /// Empty state title of the budget screen; month is pre-formatted, e.g. October 2026
  ///
  /// In en, this message translates to:
  /// **'No budgets for {month}'**
  String budgetEmptyTitle(String month);

  /// Budget form: option for a budget on one expense category
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get budgetFormCategory;

  /// Title of the sheet that edits a budget
  ///
  /// In en, this message translates to:
  /// **'Edit budget'**
  String get budgetFormEditTitle;

  /// Label of the budget amount field
  ///
  /// In en, this message translates to:
  /// **'Monthly limit'**
  String get budgetFormLimitLabel;

  /// Title of the sheet that adds a budget
  ///
  /// In en, this message translates to:
  /// **'New budget'**
  String get budgetFormNewTitle;

  /// Budget form: no expense category is left without a budget
  ///
  /// In en, this message translates to:
  /// **'Every expense category already has a budget this month.'**
  String get budgetFormNoCategoriesLeft;

  /// Budget form: option for the overall budget (all expenses)
  ///
  /// In en, this message translates to:
  /// **'Overall'**
  String get budgetFormOverall;

  /// Budget form: explains what the overall budget counts
  ///
  /// In en, this message translates to:
  /// **'Covers all your expenses this month.'**
  String get budgetFormOverallHint;

  /// Budget form button that removes the budget being edited
  ///
  /// In en, this message translates to:
  /// **'Remove budget'**
  String get budgetFormRemove;

  /// How far spending exceeds a budget; amount is pre-formatted money
  ///
  /// In en, this message translates to:
  /// **'{amount} over'**
  String budgetOver(String amount);

  /// Shown in the overall budget card when only category budgets are set
  ///
  /// In en, this message translates to:
  /// **'Set an overall limit to track all your spending this month.'**
  String get budgetOverallEmptyMessage;

  /// Title of the overall budget card when no overall budget is set
  ///
  /// In en, this message translates to:
  /// **'No overall budget'**
  String get budgetOverallEmptyTitle;

  /// Title of the card with the month's overall budget (all expenses)
  ///
  /// In en, this message translates to:
  /// **'Overall budget'**
  String get budgetOverallTitle;

  /// Share of a budget spent so far, as a whole percent (can exceed 100)
  ///
  /// In en, this message translates to:
  /// **'{percent}% used'**
  String budgetPercentUsed(int percent);

  /// Body of the dialog that confirms removing a budget
  ///
  /// In en, this message translates to:
  /// **'Your transactions stay as they are.'**
  String get budgetRemoveConfirmMessage;

  /// Title of the dialog that confirms removing a budget
  ///
  /// In en, this message translates to:
  /// **'Remove this budget?'**
  String get budgetRemoveConfirmTitle;

  /// What is left of a budget; amount is pre-formatted money
  ///
  /// In en, this message translates to:
  /// **'{amount} left'**
  String budgetRemaining(String amount);

  /// Spent so far against a budget's limit; both are pre-formatted money, e.g. $250.00 of $500.00
  ///
  /// In en, this message translates to:
  /// **'{spent} of {limit}'**
  String budgetSpentOfLimit(String spent, String limit);

  /// Budget state label when spending reached or passed the limit (100% or more)
  ///
  /// In en, this message translates to:
  /// **'Limit reached'**
  String get budgetStatusExceeded;

  /// Budget state label when spending reached 80% of the limit
  ///
  /// In en, this message translates to:
  /// **'Close to limit'**
  String get budgetStatusWarning;

  /// Title of the budget tab and its bottom navigation label
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get budgetTitle;

  /// Screen reader label of a calendar day without transactions; date is pre-formatted, e.g. October 5, 2026
  ///
  /// In en, this message translates to:
  /// **'{date}: no transactions'**
  String calendarDayEmpty(String date);

  /// Screen reader label of a calendar day; amount is the day's net (income minus expenses), pre-formatted and signed
  ///
  /// In en, this message translates to:
  /// **'{date}: {amount}'**
  String calendarDayLabel(String date, String amount);

  /// Day pop-up: the day's income minus expenses
  ///
  /// In en, this message translates to:
  /// **'Net'**
  String get calendarDayNet;

  /// Calendar: the selected day has no transactions; date is pre-formatted, e.g. Monday, October 5, 2026
  ///
  /// In en, this message translates to:
  /// **'No transactions on {date}.'**
  String calendarNoTransactionsOn(String date);

  /// Title of the calendar screen
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendarTitle;

  /// Button in the edit-category sheet (and its confirm action) that archives the category
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get categoryFormArchive;

  /// Label above the color picker in the category sheet
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get categoryFormColorLabel;

  /// Screen-reader label of one color in the category color picker
  ///
  /// In en, this message translates to:
  /// **'Color {index} of {count}'**
  String categoryFormColorOption(int index, int count);

  /// Title of the category sheet when editing
  ///
  /// In en, this message translates to:
  /// **'Edit category'**
  String get categoryFormEditTitle;

  /// Label above the icon picker in the category sheet
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get categoryFormIconLabel;

  /// Screen-reader label of one icon in the category icon picker
  ///
  /// In en, this message translates to:
  /// **'Icon {index} of {count}'**
  String categoryFormIconOption(int index, int count);

  /// Label of the name field in the category sheet
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get categoryFormNameLabel;

  /// Title of the category sheet when adding
  ///
  /// In en, this message translates to:
  /// **'New category'**
  String get categoryFormNewTitle;

  /// Label above the expense/income toggle in the category sheet
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get categoryFormTypeLabel;

  /// Message of the dialog that confirms archiving a category
  ///
  /// In en, this message translates to:
  /// **'It won\'t be offered for new transactions. Transactions that already use it keep it.'**
  String get categoryArchiveConfirmMessage;

  /// Title of the dialog that confirms archiving a category
  ///
  /// In en, this message translates to:
  /// **'Archive “{name}”?'**
  String categoryArchiveConfirmTitle(String name);

  /// Shown on a transaction or row whose category was archived
  ///
  /// In en, this message translates to:
  /// **'Archived category'**
  String get categoryArchivedLabel;

  /// Screen-reader label and tooltip of a category chip whose category was archived
  ///
  /// In en, this message translates to:
  /// **'{name} (archived)'**
  String categoryChipArchived(String name);

  /// Name of a default category seeded for new users (stored as data, editable)
  ///
  /// In en, this message translates to:
  /// **'Bills'**
  String get categoryDefaultBills;

  /// Name of a default category seeded for new users (stored as data, editable)
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get categoryDefaultEducation;

  /// Name of a default category seeded for new users (stored as data, editable)
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get categoryDefaultEntertainment;

  /// Name of a default category seeded for new users (stored as data, editable)
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get categoryDefaultFood;

  /// Name of a default category seeded for new users (stored as data, editable)
  ///
  /// In en, this message translates to:
  /// **'Freelance'**
  String get categoryDefaultFreelance;

  /// Name of a default category seeded for new users (stored as data, editable)
  ///
  /// In en, this message translates to:
  /// **'Gifts'**
  String get categoryDefaultGifts;

  /// Name of a default category seeded for new users (stored as data, editable)
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get categoryDefaultHealth;

  /// Name of a default category seeded for new users (stored as data, editable)
  ///
  /// In en, this message translates to:
  /// **'Investments'**
  String get categoryDefaultInvestments;

  /// Name of a default category seeded for new users (stored as data, editable)
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryDefaultOther;

  /// Name of a default category seeded for new users (stored as data, editable)
  ///
  /// In en, this message translates to:
  /// **'Other income'**
  String get categoryDefaultOtherIncome;

  /// Name of a default category seeded for new users (stored as data, editable)
  ///
  /// In en, this message translates to:
  /// **'Salary'**
  String get categoryDefaultSalary;

  /// Name of a default category seeded for new users (stored as data, editable)
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get categoryDefaultShopping;

  /// Name of a default category seeded for new users (stored as data, editable)
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get categoryDefaultTransport;

  /// Floating button / tooltip on the categories screen that opens the new-category sheet
  ///
  /// In en, this message translates to:
  /// **'Add category'**
  String get categoriesAdd;

  /// Empty state message of a category list tab
  ///
  /// In en, this message translates to:
  /// **'Add a category to start sorting your transactions.'**
  String get categoriesEmptyMessage;

  /// Empty state title of a category list tab
  ///
  /// In en, this message translates to:
  /// **'No categories yet'**
  String get categoriesEmptyTitle;

  /// Title of the categories screen and its settings entry
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categoriesTitle;

  /// Shown when a transaction's category can't be found on this device (e.g. not synced yet)
  ///
  /// In en, this message translates to:
  /// **'Unknown category'**
  String get categoryUnknown;

  /// Filter option that shows everything (e.g. both expense and income)
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get commonAll;

  /// Generic cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

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

  /// Tooltip/label of an action that edits the item shown
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// The expense type (transactions, categories); used as a tab or toggle label
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get commonExpense;

  /// The income type (transactions, categories); used as a tab or toggle label
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get commonIncome;

  /// Separator between the items of a short inline list, e.g. weekday names in a reminder schedule (Mon, Thu)
  ///
  /// In en, this message translates to:
  /// **', '**
  String get commonListSeparator;

  /// Accessibility label for a loading indicator
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get commonLoading;

  /// Tooltip of the month selector's forward arrow
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get commonNextMonth;

  /// Tooltip of the month selector's back arrow
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get commonPreviousMonth;

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

  /// Relative day label, e.g. in a list header
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get commonToday;

  /// Snackbar action that reverts the last change
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get commonUndo;

  /// Relative day label, e.g. in a list header
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get commonYesterday;

  /// Dashboard card: the month's income minus expenses
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get dashboardBalance;

  /// Dashboard budgets section when the month has no budgets; month is pre-formatted, e.g. October 2026
  ///
  /// In en, this message translates to:
  /// **'No budgets for {month}.'**
  String dashboardBudgetsEmpty(String month);

  /// Dashboard budgets section action that opens the Budget tab on that month
  ///
  /// In en, this message translates to:
  /// **'Set a budget'**
  String get dashboardBudgetsSet;

  /// Title of the dashboard section with the month's budget progress
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get dashboardBudgetsTitle;

  /// Dashboard goals section when the user has no goals
  ///
  /// In en, this message translates to:
  /// **'No savings goals yet.'**
  String get dashboardGoalsEmpty;

  /// Dashboard goals section: how many goals have reached their target
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 goal reached} other{{count} goals reached}}'**
  String dashboardGoalsReached(int count);

  /// Dashboard goals section action that opens the Goals tab
  ///
  /// In en, this message translates to:
  /// **'Set a goal'**
  String get dashboardGoalsSet;

  /// Dashboard goals section: saved across all goals of their combined targets; both pre-formatted
  ///
  /// In en, this message translates to:
  /// **'Saved {saved} of {target}'**
  String dashboardGoalsTotal(String saved, String target);

  /// Screen reader label of a day in the dashboard spending heatmap; date and amount are pre-formatted
  ///
  /// In en, this message translates to:
  /// **'{date}: spent {amount}'**
  String dashboardHeatmapDay(String date, String amount);

  /// Screen reader label of a day without expenses in the dashboard spending heatmap; date is pre-formatted
  ///
  /// In en, this message translates to:
  /// **'{date}: no spending'**
  String dashboardHeatmapDayNone(String date);

  /// Start of the dashboard spending heatmap key (light shades = less spent)
  ///
  /// In en, this message translates to:
  /// **'Less'**
  String get dashboardHeatmapLess;

  /// End of the dashboard spending heatmap key (dark shades = more spent)
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get dashboardHeatmapMore;

  /// Title of the dashboard section that shades each day of the month by how much was spent
  ///
  /// In en, this message translates to:
  /// **'Daily spending'**
  String get dashboardHeatmapTitle;

  /// Dashboard recent-transactions section when the month has none; month is pre-formatted, e.g. October 2026
  ///
  /// In en, this message translates to:
  /// **'No transactions in {month} yet.'**
  String dashboardRecentEmpty(String month);

  /// Title of the dashboard section with the month's latest transactions
  ///
  /// In en, this message translates to:
  /// **'Recent transactions'**
  String get dashboardRecentTitle;

  /// Dashboard spending-by-category section when the month has no expenses; month is pre-formatted, e.g. October 2026
  ///
  /// In en, this message translates to:
  /// **'No expenses in {month}.'**
  String dashboardSpendingEmpty(String month);

  /// Dashboard spending-by-category row that groups the smaller categories together (not called 'Other', which is also a default category name)
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 more category} other{{count} more categories}}'**
  String dashboardSpendingOther(int count);

  /// A category's share of the month's spending, as a whole percent
  ///
  /// In en, this message translates to:
  /// **'{percent}%'**
  String dashboardSpendingPercent(int percent);

  /// A category's share of the month's spending when it rounds to 0 but is not zero
  ///
  /// In en, this message translates to:
  /// **'<1%'**
  String get dashboardSpendingPercentTiny;

  /// Title of the dashboard section that breaks the month's expenses down by category
  ///
  /// In en, this message translates to:
  /// **'Spending by category'**
  String get dashboardSpendingTitle;

  /// Title of the dashboard tab and its bottom navigation label
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardTitle;

  /// Developer-only (debug builds): title of the screen previewing the mascot, loaders, progress bars and plants, and its row in Settings
  ///
  /// In en, this message translates to:
  /// **'Design gallery'**
  String get designGalleryTitle;

  /// Amount field error when the value is zero or can't be read
  ///
  /// In en, this message translates to:
  /// **'Enter an amount greater than 0.'**
  String get errorAmountInvalid;

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

  /// Budget form: the chosen category was archived
  ///
  /// In en, this message translates to:
  /// **'This category is archived. Choose another one.'**
  String get errorBudgetCategoryArchived;

  /// Budget form: the chosen category is an income category
  ///
  /// In en, this message translates to:
  /// **'Budgets can only be set for expense categories.'**
  String get errorBudgetCategoryNotExpense;

  /// Budget form: no category chosen for a category budget, or it no longer exists
  ///
  /// In en, this message translates to:
  /// **'Choose a category.'**
  String get errorBudgetCategoryRequired;

  /// Budget error: the month is too far ahead (or before 2000)
  ///
  /// In en, this message translates to:
  /// **'Budgets can be set up to {months} months ahead.'**
  String errorBudgetMonthOutOfRange(int months);

  /// Category name field error: an active category of the same type already uses the name
  ///
  /// In en, this message translates to:
  /// **'You already have a category with this name.'**
  String get errorCategoryNameTaken;

  /// Saving a category failed because its type changed while transactions use it
  ///
  /// In en, this message translates to:
  /// **'This category is used by transactions, so its type can\'t be changed.'**
  String get errorCategoryTypeLocked;

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

  /// Add-money form: the date is in the future (or before 2000)
  ///
  /// In en, this message translates to:
  /// **'Choose a date that isn\'t in the future.'**
  String get errorGoalContributionDateOutOfRange;

  /// Goal form: the deadline is before 2000 or too far ahead
  ///
  /// In en, this message translates to:
  /// **'Choose a deadline within the next {years} years.'**
  String errorGoalDeadlineOutOfRange(int years);

  /// Add money or undo failed because the goal was deleted (e.g. on another device)
  ///
  /// In en, this message translates to:
  /// **'This goal no longer exists.'**
  String get errorGoalNotFound;

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

  /// Reminder form: monthly repeat without a day
  ///
  /// In en, this message translates to:
  /// **'Choose a day of the month.'**
  String get errorReminderDayOfMonthRequired;

  /// Reminder form: weekly repeat without any weekday
  ///
  /// In en, this message translates to:
  /// **'Choose at least one day.'**
  String get errorReminderWeekdaysRequired;

  /// Shown for StorageFailure
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save on this device. Please try again.'**
  String get errorStorage;

  /// Transaction form: the chosen category was archived
  ///
  /// In en, this message translates to:
  /// **'This category is archived. Choose another one.'**
  String get errorTransactionCategoryArchived;

  /// Transaction form: the category's type differs from the transaction's (expense/income)
  ///
  /// In en, this message translates to:
  /// **'Choose a category of this type.'**
  String get errorTransactionCategoryMismatch;

  /// Transaction form: no category selected, or it no longer exists
  ///
  /// In en, this message translates to:
  /// **'Choose a category.'**
  String get errorTransactionCategoryRequired;

  /// Transaction form: the date is outside the allowed range
  ///
  /// In en, this message translates to:
  /// **'Choose a date from 2000 up to a year from today.'**
  String get errorTransactionDateOutOfRange;

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

  /// Add-money form: label of the amount field
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get goalContributionAmountLabel;

  /// Add-money form: section header above the date
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get goalContributionDateLabel;

  /// Snackbar after removing a contribution from a goal's history (with Undo)
  ///
  /// In en, this message translates to:
  /// **'Contribution removed'**
  String get goalContributionDeleted;

  /// Add-money form: label of the note field
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get goalContributionNoteLabel;

  /// Body of the dialog that confirms deleting a goal
  ///
  /// In en, this message translates to:
  /// **'Its history will be deleted too.'**
  String get goalDeleteConfirmMessage;

  /// Title of the dialog that confirms deleting a goal
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"?'**
  String goalDeleteConfirmTitle(String name);

  /// Goal detail: the target has been saved
  ///
  /// In en, this message translates to:
  /// **'Goal reached'**
  String get goalDetailCompleted;

  /// Goal detail: action that deletes the goal
  ///
  /// In en, this message translates to:
  /// **'Delete goal'**
  String get goalDetailDelete;

  /// Goal detail: section header above the contributions
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get goalDetailHistory;

  /// Goal detail: the goal has no contributions
  ///
  /// In en, this message translates to:
  /// **'No money added yet.'**
  String get goalDetailHistoryEmpty;

  /// Goal detail: shown when the goal no longer exists
  ///
  /// In en, this message translates to:
  /// **'It may have been deleted on another device.'**
  String get goalDetailMissingMessage;

  /// Goal detail: title shown when the goal no longer exists
  ///
  /// In en, this message translates to:
  /// **'Goal not found'**
  String get goalDetailMissingTitle;

  /// Goal detail: monthly amount needed to reach the target by the deadline; both pre-formatted
  ///
  /// In en, this message translates to:
  /// **'Save {amount} a month to reach it by {date}.'**
  String goalDetailNeededPerMonth(String amount, String date);

  /// Goal detail: the goal is not reached and its deadline is in the past; date pre-formatted
  ///
  /// In en, this message translates to:
  /// **'The deadline ({date}) has passed.'**
  String goalDetailOverdue(String date);

  /// Goal detail: what is still to save; amount is pre-formatted money
  ///
  /// In en, this message translates to:
  /// **'{amount} to go'**
  String goalDetailRemaining(String amount);

  /// Goal form: button/tooltip that removes the optional deadline
  ///
  /// In en, this message translates to:
  /// **'Remove deadline'**
  String get goalFormClearDeadline;

  /// Goal form: section header above the color choices
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get goalFormColorLabel;

  /// Goal form: section header above the deadline date
  ///
  /// In en, this message translates to:
  /// **'Deadline (optional)'**
  String get goalFormDeadlineLabel;

  /// Title of the sheet that edits a goal
  ///
  /// In en, this message translates to:
  /// **'Edit goal'**
  String get goalFormEditTitle;

  /// Goal form: section header above the icon choices
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get goalFormIconLabel;

  /// Goal form: label of the name field
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get goalFormNameLabel;

  /// Title of the sheet that adds a goal
  ///
  /// In en, this message translates to:
  /// **'New goal'**
  String get goalFormNewTitle;

  /// Goal form: shown on the date button when the goal has no deadline
  ///
  /// In en, this message translates to:
  /// **'No deadline'**
  String get goalFormNoDeadline;

  /// Goal form: label of the amount to save
  ///
  /// In en, this message translates to:
  /// **'Target amount'**
  String get goalFormTargetLabel;

  /// Button and tooltip that open the sheet to add a goal
  ///
  /// In en, this message translates to:
  /// **'Add goal'**
  String get goalsAdd;

  /// Goal detail: button and sheet title for adding a contribution
  ///
  /// In en, this message translates to:
  /// **'Add money'**
  String get goalsAddMoney;

  /// Goal list: the goal's target has been reached
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get goalsCompleted;

  /// Goal list: the goal's deadline; date is pre-formatted, e.g. Jun 1, 2027
  ///
  /// In en, this message translates to:
  /// **'By {date}'**
  String goalsDeadline(String date);

  /// Empty state message of the goals tab
  ///
  /// In en, this message translates to:
  /// **'Set a savings goal and see how close you are.'**
  String get goalsEmptyMessage;

  /// Empty state title of the goals tab
  ///
  /// In en, this message translates to:
  /// **'No goals yet'**
  String get goalsEmptyTitle;

  /// Goal list subtitle: the saved/target text, then the deadline or 'Completed'
  ///
  /// In en, this message translates to:
  /// **'{amounts} · {status}'**
  String goalsListSubtitle(String amounts, String status);

  /// Share of a goal's target saved, as a whole percent (can exceed 100)
  ///
  /// In en, this message translates to:
  /// **'{percent}%'**
  String goalsPercent(int percent);

  /// Saved so far against a goal's target; both are pre-formatted money, e.g. $500.00 of $1,500.00
  ///
  /// In en, this message translates to:
  /// **'{saved} of {target}'**
  String goalsSavedOfTarget(String saved, String target);

  /// Title of the goals tab and its bottom navigation label
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get goalsTitle;

  /// The name of THIS file's language written in that language (e.g. 'Deutsch' for German), shown in the language picker. Not the word 'English'.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageNativeName;

  /// Lock screen: the system blocked fingerprint/face after too many tries
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Use your PIN.'**
  String get lockBiometricLockedOut;

  /// Reason shown by the system fingerprint/face prompt on the lock screen
  ///
  /// In en, this message translates to:
  /// **'Unlock the app to see your finances'**
  String get lockBiometricReason;

  /// Lock screen: biometrics can't be used right now
  ///
  /// In en, this message translates to:
  /// **'Fingerprint or face unlock isn\'t available. Use your PIN.'**
  String get lockBiometricUnavailable;

  /// Lock screen link that starts PIN recovery
  ///
  /// In en, this message translates to:
  /// **'Forgot PIN?'**
  String get lockForgotPin;

  /// After PIN recovery, above the new-PIN step
  ///
  /// In en, this message translates to:
  /// **'PIN removed. Choose a new one to keep the app locked.'**
  String get lockRecoveryDone;

  /// PIN recovery: explains the password check; email is the account email
  ///
  /// In en, this message translates to:
  /// **'Enter the password of {email}. The PIN is then removed and you can choose a new one.'**
  String lockRecoveryMessage(String email);

  /// PIN recovery: finish without choosing a new PIN (the lock is turned off)
  ///
  /// In en, this message translates to:
  /// **'Turn app lock off'**
  String get lockRecoverySkip;

  /// PIN recovery confirm button
  ///
  /// In en, this message translates to:
  /// **'Remove PIN'**
  String get lockRecoverySubmit;

  /// PIN recovery sheet title
  ///
  /// In en, this message translates to:
  /// **'Forgot your PIN?'**
  String get lockRecoveryTitle;

  /// Lock screen title
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN'**
  String get lockTitle;

  /// Lock screen button (icon) that shows the fingerprint/face prompt
  ///
  /// In en, this message translates to:
  /// **'Unlock with fingerprint or face'**
  String get lockUseBiometrics;

  /// Lock screen error after a wrong PIN
  ///
  /// In en, this message translates to:
  /// **'Wrong PIN. Try again.'**
  String get lockWrongPin;

  /// Android notification channel name (system settings) for budget threshold alerts
  ///
  /// In en, this message translates to:
  /// **'Budget alerts'**
  String get notificationsChannelBudgetAlerts;

  /// Android notification channel description for budget alerts
  ///
  /// In en, this message translates to:
  /// **'When a budget is close to or over its limit.'**
  String get notificationsChannelBudgetAlertsDescription;

  /// Android notification channel name (system settings) for the user's reminders
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get notificationsChannelReminders;

  /// Android notification channel description for reminders
  ///
  /// In en, this message translates to:
  /// **'Reminders you set in the app.'**
  String get notificationsChannelRemindersDescription;

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

  /// Password strength meter level 3 of 5
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get passwordStrengthGood;

  /// Password strength meter level 4 of 5
  ///
  /// In en, this message translates to:
  /// **'Great'**
  String get passwordStrengthGreat;

  /// Screen-reader summary of the password strength meter; level is one of the meter labels
  ///
  /// In en, this message translates to:
  /// **'Password strength: {level}'**
  String passwordStrengthLabel(String level);

  /// Password strength meter: characters still missing to reach the minimum length
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 more} other{{count} more}}'**
  String passwordStrengthMore(int count);

  /// Password strength meter level 2 of 5 (long enough, simple)
  ///
  /// In en, this message translates to:
  /// **'Okay'**
  String get passwordStrengthOkay;

  /// Password strength meter level 5 of 5
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get passwordStrengthStrong;

  /// Second step when choosing a PIN
  ///
  /// In en, this message translates to:
  /// **'Enter the PIN again'**
  String get pinConfirmTitle;

  /// Asked before changing or turning off the PIN
  ///
  /// In en, this message translates to:
  /// **'Enter your current PIN'**
  String get pinCurrentTitle;

  /// PIN pad backspace button (screen reader / tooltip)
  ///
  /// In en, this message translates to:
  /// **'Delete last digit'**
  String get pinDeleteDigit;

  /// Choosing a PIN: the second entry differs
  ///
  /// In en, this message translates to:
  /// **'The PINs don\'t match. Choose a PIN again.'**
  String get pinMismatch;

  /// Screen reader text of the PIN dots
  ///
  /// In en, this message translates to:
  /// **'{entered} of {total} digits entered'**
  String pinProgress(int entered, int total);

  /// Choosing a PIN: required number of digits
  ///
  /// In en, this message translates to:
  /// **'Use {length} digits.'**
  String pinSetHint(int length);

  /// First step when choosing a PIN
  ///
  /// In en, this message translates to:
  /// **'Choose a PIN'**
  String get pinSetTitle;

  /// Body of the dialog that confirms deleting a reminder
  ///
  /// In en, this message translates to:
  /// **'It won\'t remind you any more.'**
  String get reminderDeleteConfirmMessage;

  /// Title of the dialog that confirms deleting a reminder
  ///
  /// In en, this message translates to:
  /// **'Delete \"{title}\"?'**
  String reminderDeleteConfirmTitle(String title);

  /// Reminder schedule: daily; time is pre-formatted for the locale, e.g. 8:30 PM
  ///
  /// In en, this message translates to:
  /// **'Every day at {time}'**
  String reminderEveryDay(String time);

  /// Reminder form: explains what happens to days 29-31 in shorter months
  ///
  /// In en, this message translates to:
  /// **'Short months use their last day.'**
  String get reminderFormDayOfMonthHint;

  /// Reminder form: label of the day picker for monthly reminders
  ///
  /// In en, this message translates to:
  /// **'Day of the month'**
  String get reminderFormDayOfMonthLabel;

  /// Reminder form: section header above the weekday choices
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get reminderFormDaysLabel;

  /// Reminder form: button that deletes the reminder being edited
  ///
  /// In en, this message translates to:
  /// **'Delete reminder'**
  String get reminderFormDelete;

  /// Title of the sheet that edits a reminder
  ///
  /// In en, this message translates to:
  /// **'Edit reminder'**
  String get reminderFormEditTitle;

  /// Title of the sheet that adds a reminder
  ///
  /// In en, this message translates to:
  /// **'New reminder'**
  String get reminderFormNewTitle;

  /// Reminder form: section header above daily/weekly/monthly
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get reminderFormRepeatLabel;

  /// Reminder form: section header above the time
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get reminderFormTimeLabel;

  /// Reminder form: hint in the title field
  ///
  /// In en, this message translates to:
  /// **'e.g. Log today\'s expenses'**
  String get reminderFormTitleHint;

  /// Reminder form: label of the title field
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get reminderFormTitleLabel;

  /// Reminder schedule: monthly; time is pre-formatted
  ///
  /// In en, this message translates to:
  /// **'Monthly on day {day} at {time}'**
  String reminderMonthly(int day, String time);

  /// Reminder repeat option
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get reminderRepeatDaily;

  /// Reminder repeat option
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get reminderRepeatMonthly;

  /// Reminder repeat option
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get reminderRepeatWeekly;

  /// Screen reader label of a reminder's on/off switch
  ///
  /// In en, this message translates to:
  /// **'{title} on'**
  String reminderSwitchLabel(String title);

  /// Reminder schedule: weekly; days is a pre-formatted list like Mon, Thu; time pre-formatted
  ///
  /// In en, this message translates to:
  /// **'{days} at {time}'**
  String reminderWeekly(String days, String time);

  /// Button and tooltip that open the sheet to add a reminder
  ///
  /// In en, this message translates to:
  /// **'Add reminder'**
  String get remindersAdd;

  /// Empty state message of the reminders screen
  ///
  /// In en, this message translates to:
  /// **'Add one for a regular nudge, like logging today\'s expenses.'**
  String get remindersEmptyMessage;

  /// Empty state title of the reminders screen
  ///
  /// In en, this message translates to:
  /// **'No reminders yet'**
  String get remindersEmptyTitle;

  /// Snackbar when the user turns a reminder on but the OS notification permission is denied
  ///
  /// In en, this message translates to:
  /// **'Notifications are off for this app. Allow them in system settings to get reminders.'**
  String get remindersPermissionDenied;

  /// Title of the reminders screen and its row in Settings
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get remindersTitle;

  /// Settings section header for account actions (log out)
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAccountLabel;

  /// Settings switch that turns the PIN lock on or off
  ///
  /// In en, this message translates to:
  /// **'App lock'**
  String get settingsAppLock;

  /// Settings: description under the app lock switch
  ///
  /// In en, this message translates to:
  /// **'Ask for a PIN to open the app'**
  String get settingsAppLockDescription;

  /// Snackbar after turning the app lock off
  ///
  /// In en, this message translates to:
  /// **'App lock is off'**
  String get settingsAppLockOff;

  /// Snackbar after turning the app lock on
  ///
  /// In en, this message translates to:
  /// **'App lock is on'**
  String get settingsAppLockOn;

  /// Settings: how long the app may be in the background before it locks; also the picker title
  ///
  /// In en, this message translates to:
  /// **'Auto-lock'**
  String get settingsAutoLock;

  /// Auto-lock option
  ///
  /// In en, this message translates to:
  /// **'{minutes, plural, =1{After 1 minute} other{After {minutes} minutes}}'**
  String settingsAutoLockAfterMinutes(int minutes);

  /// Auto-lock option
  ///
  /// In en, this message translates to:
  /// **'After {seconds} seconds'**
  String settingsAutoLockAfterSeconds(int seconds);

  /// Auto-lock option: as soon as the app leaves the screen
  ///
  /// In en, this message translates to:
  /// **'Immediately'**
  String get settingsAutoLockImmediately;

  /// Settings switch for biometric unlock
  ///
  /// In en, this message translates to:
  /// **'Unlock with fingerprint or face'**
  String get settingsBiometrics;

  /// Settings: why the biometric switch is off/disabled
  ///
  /// In en, this message translates to:
  /// **'Set up a fingerprint or face on this phone to use it here.'**
  String get settingsBiometricsUnavailable;

  /// Settings row that changes the PIN
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get settingsChangePin;

  /// Snackbar after changing the PIN
  ///
  /// In en, this message translates to:
  /// **'PIN changed'**
  String get settingsPinChanged;

  /// Settings section header for the app lock
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get settingsSecurityLabel;

  /// Settings switch that turns budget threshold notifications on or off on this device
  ///
  /// In en, this message translates to:
  /// **'Budget alerts'**
  String get settingsBudgetAlerts;

  /// Settings: explains the budget alerts switch
  ///
  /// In en, this message translates to:
  /// **'Alert me at 80% and 100% of a budget.'**
  String get settingsBudgetAlertsDescription;

  /// Snackbar when budget alerts are turned on but the OS notification permission is denied
  ///
  /// In en, this message translates to:
  /// **'Notifications are off for this app. Allow them in system settings to get budget alerts.'**
  String get settingsBudgetAlertsPermissionDenied;

  /// Settings row label for the user's currency
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get settingsCurrency;

  /// Settings: explains why the currency is read-only
  ///
  /// In en, this message translates to:
  /// **'Chosen when you set up the app. It can\'t be changed, so all your amounts stay in one currency.'**
  String get settingsCurrencyLocked;

  /// Settings: the user's currency, e.g. USD ($)
  ///
  /// In en, this message translates to:
  /// **'{code} ({symbol})'**
  String settingsCurrencyValue(String code, String symbol);

  /// Title of the dialog that picks the app language
  ///
  /// In en, this message translates to:
  /// **'Choose a language'**
  String get settingsLanguageChoose;

  /// Language option that follows the phone's language setting
  ///
  /// In en, this message translates to:
  /// **'Device language'**
  String get settingsLanguageDevice;

  /// Settings section header and accessibility label of the app language picker
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageLabel;

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

  /// Settings section header for data the user manages (categories, later budgets)
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get settingsManageLabel;

  /// Settings section header for notification settings
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotificationsLabel;

  /// Settings section header for the user's name, email and currency
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get settingsProfileLabel;

  /// Settings section header for the sync status and the Sync now button
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get settingsSyncLabel;

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

  /// Button that starts a sync right away
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get syncNow;

  /// Sync indicator: the last sync failed for a reason other than the connection
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t sync. We\'ll keep trying.'**
  String get syncStatusError;

  /// Sync indicator: no connection (or the server can't be reached)
  ///
  /// In en, this message translates to:
  /// **'Offline. Changes will sync when you\'re back online.'**
  String get syncStatusOffline;

  /// Sync indicator: local changes not on the server yet
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 change waiting to sync} other{{count} changes waiting to sync}}'**
  String syncStatusPending(int count);

  /// Sync indicator: everything is on the server
  ///
  /// In en, this message translates to:
  /// **'All changes synced'**
  String get syncStatusSynced;

  /// Sync indicator: a sync is running
  ///
  /// In en, this message translates to:
  /// **'Syncing…'**
  String get syncStatusSyncing;

  /// Snackbar after deleting a transaction (with an Undo action)
  ///
  /// In en, this message translates to:
  /// **'Transaction deleted'**
  String get transactionDeleted;

  /// Label of the note on the transaction detail page
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get transactionDetailNoteLabel;

  /// Title of the transaction detail page
  ///
  /// In en, this message translates to:
  /// **'Transaction'**
  String get transactionDetailTitle;

  /// Label of the amount field in the transaction sheet
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get transactionFormAmountLabel;

  /// Label above the category picker in the transaction sheet
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get transactionFormCategoryLabel;

  /// Label of the date picker button in the transaction sheet
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get transactionFormDateLabel;

  /// Title of the transaction sheet when editing
  ///
  /// In en, this message translates to:
  /// **'Edit transaction'**
  String get transactionFormEditTitle;

  /// Title of the transaction sheet when adding
  ///
  /// In en, this message translates to:
  /// **'New transaction'**
  String get transactionFormNewTitle;

  /// Shown in the transaction sheet's category picker when the type has no active categories
  ///
  /// In en, this message translates to:
  /// **'No categories of this type yet. Add one in Settings → Categories.'**
  String get transactionFormNoCategories;

  /// Label of the optional note field in the transaction sheet
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get transactionFormNoteLabel;

  /// Detail page message when the transaction doesn't exist (anymore)
  ///
  /// In en, this message translates to:
  /// **'It may have been deleted on this or another device.'**
  String get transactionNotFoundMessage;

  /// Detail page title when the transaction doesn't exist (anymore)
  ///
  /// In en, this message translates to:
  /// **'Transaction not found'**
  String get transactionNotFoundTitle;

  /// Floating button / tooltip that opens the new-transaction sheet
  ///
  /// In en, this message translates to:
  /// **'Add transaction'**
  String get transactionsAdd;

  /// Empty state message of the transaction list
  ///
  /// In en, this message translates to:
  /// **'Tap + to add your first one.'**
  String get transactionsEmptyMessage;

  /// Action that removes the type and category filters on the transaction list
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get transactionsClearFilters;

  /// Empty state title of the transaction list; month is pre-formatted, e.g. October 2026
  ///
  /// In en, this message translates to:
  /// **'No transactions in {month}'**
  String transactionsEmptyTitle(String month);

  /// Category filter button when no category is chosen
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get transactionsFilterAllCategories;

  /// Title of the sheet that picks a category filter
  ///
  /// In en, this message translates to:
  /// **'Filter by category'**
  String get transactionsFilterCategoryTitle;

  /// Tooltip of the button that removes the category filter
  ///
  /// In en, this message translates to:
  /// **'Clear category filter'**
  String get transactionsFilterClearCategory;

  /// Empty state message when filters hide every transaction of the month
  ///
  /// In en, this message translates to:
  /// **'Try another month or clear the filters.'**
  String get transactionsNoMatchesMessage;

  /// Empty state title when filters hide every transaction of the month
  ///
  /// In en, this message translates to:
  /// **'No matching transactions'**
  String get transactionsNoMatchesTitle;

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
  bool isSupported(Locale locale) => <String>['en', 'si'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'si':
      return AppLocalizationsSi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
