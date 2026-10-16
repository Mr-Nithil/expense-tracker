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
    final intl.NumberFormat minLengthNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String minLengthString = minLengthNumberFormat.format(minLength);

    return 'At least $minLengthString characters';
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
  String get authSplashSyncing => 'Getting your data…';

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
  String get budgetAdd => 'Add budget';

  @override
  String budgetAlertBody(String spent, String limit) {
    return '$spent of $limit spent this month.';
  }

  @override
  String budgetAlertExceededTitle(String name) {
    return '$name: limit reached';
  }

  @override
  String budgetAlertWarningTitle(String name, int percent) {
    final intl.NumberFormat percentNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String percentString = percentNumberFormat.format(percent);

    return '$name: $percentString% used';
  }

  @override
  String get budgetCategoriesHeader => 'Categories';

  @override
  String budgetCopied(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Copied $countString budgets from last month.',
      one: 'Copied 1 budget from last month.',
      zero: 'Nothing new to copy from last month.',
    );
    return '$_temp0';
  }

  @override
  String get budgetCopyPrevious => 'Copy last month\'s budgets';

  @override
  String get budgetEmptyMessage => 'Set a monthly limit to see how your spending is tracking.';

  @override
  String budgetEmptyTitle(String month) {
    return 'No budgets for $month';
  }

  @override
  String get budgetFormCategory => 'Category';

  @override
  String get budgetFormEditTitle => 'Edit budget';

  @override
  String get budgetFormLimitLabel => 'Monthly limit';

  @override
  String get budgetFormNewTitle => 'New budget';

  @override
  String get budgetFormNoCategoriesLeft =>
      'Every expense category already has a budget this month.';

  @override
  String get budgetFormOverall => 'Overall';

  @override
  String get budgetFormOverallHint => 'Covers all your expenses this month.';

  @override
  String get budgetFormRemove => 'Remove budget';

  @override
  String budgetOver(String amount) {
    return '$amount over';
  }

  @override
  String get budgetOverallEmptyMessage =>
      'Set an overall limit to track all your spending this month.';

  @override
  String get budgetOverallEmptyTitle => 'No overall budget';

  @override
  String get budgetOverallTitle => 'Overall budget';

  @override
  String budgetPercentUsed(int percent) {
    final intl.NumberFormat percentNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String percentString = percentNumberFormat.format(percent);

    return '$percentString% used';
  }

  @override
  String get budgetRemoveConfirmMessage => 'Your transactions stay as they are.';

  @override
  String get budgetRemoveConfirmTitle => 'Remove this budget?';

  @override
  String budgetRemaining(String amount) {
    return '$amount left';
  }

  @override
  String budgetSpentOfLimit(String spent, String limit) {
    return '$spent of $limit';
  }

  @override
  String get budgetStatusExceeded => 'Limit reached';

  @override
  String get budgetStatusWarning => 'Close to limit';

  @override
  String get budgetTitle => 'Budget';

  @override
  String calendarDayEmpty(String date) {
    return '$date: no transactions';
  }

  @override
  String calendarDayLabel(String date, String amount) {
    return '$date: $amount';
  }

  @override
  String get calendarDayNet => 'Net';

  @override
  String calendarNoTransactionsOn(String date) {
    return 'No transactions on $date.';
  }

  @override
  String get calendarTitle => 'Calendar';

  @override
  String get categoryFormArchive => 'Archive';

  @override
  String get categoryFormColorLabel => 'Color';

  @override
  String categoryFormColorOption(int index, int count) {
    final intl.NumberFormat indexNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String indexString = indexNumberFormat.format(index);
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Color $indexString of $countString';
  }

  @override
  String get categoryFormEditTitle => 'Edit category';

  @override
  String get categoryFormIconLabel => 'Icon';

  @override
  String categoryFormIconOption(int index, int count) {
    final intl.NumberFormat indexNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String indexString = indexNumberFormat.format(index);
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Icon $indexString of $countString';
  }

  @override
  String get categoryFormNameLabel => 'Name';

  @override
  String get categoryFormNewTitle => 'New category';

  @override
  String get categoryFormTypeLabel => 'Type';

  @override
  String get categoryArchiveConfirmMessage =>
      'It won\'t be offered for new transactions. Transactions that already use it keep it.';

  @override
  String categoryArchiveConfirmTitle(String name) {
    return 'Archive “$name”?';
  }

  @override
  String get categoryArchivedLabel => 'Archived category';

  @override
  String categoryChipArchived(String name) {
    return '$name (archived)';
  }

  @override
  String get categoryDefaultBills => 'Bills';

  @override
  String get categoryDefaultEducation => 'Education';

  @override
  String get categoryDefaultEntertainment => 'Entertainment';

  @override
  String get categoryDefaultFood => 'Food';

  @override
  String get categoryDefaultFreelance => 'Freelance';

  @override
  String get categoryDefaultGifts => 'Gifts';

  @override
  String get categoryDefaultHealth => 'Health';

  @override
  String get categoryDefaultInvestments => 'Investments';

  @override
  String get categoryDefaultOther => 'Other';

  @override
  String get categoryDefaultOtherIncome => 'Other income';

  @override
  String get categoryDefaultSalary => 'Salary';

  @override
  String get categoryDefaultShopping => 'Shopping';

  @override
  String get categoryDefaultTransport => 'Transport';

  @override
  String get categoriesAdd => 'Add category';

  @override
  String get categoriesEmptyMessage => 'Add a category to start sorting your transactions.';

  @override
  String get categoriesEmptyTitle => 'No categories yet';

  @override
  String get categoriesTitle => 'Categories';

  @override
  String get categoryUnknown => 'Unknown category';

  @override
  String get commonAll => 'All';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonExpense => 'Expense';

  @override
  String get commonIncome => 'Income';

  @override
  String get commonListSeparator => ', ';

  @override
  String get commonLoading => 'Loading';

  @override
  String get commonNextMonth => 'Next month';

  @override
  String get commonPreviousMonth => 'Previous month';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonSave => 'Save';

  @override
  String get commonSeeAll => 'See all';

  @override
  String get commonToday => 'Today';

  @override
  String get commonUndo => 'Undo';

  @override
  String get commonYesterday => 'Yesterday';

  @override
  String get dashboardBalance => 'Balance';

  @override
  String dashboardBudgetsEmpty(String month) {
    return 'No budgets for $month.';
  }

  @override
  String get dashboardBudgetsSet => 'Set a budget';

  @override
  String get dashboardBudgetsTitle => 'Budgets';

  @override
  String get dashboardGoalsEmpty => 'No savings goals yet.';

  @override
  String dashboardGoalsReached(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString goals reached',
      one: '1 goal reached',
    );
    return '$_temp0';
  }

  @override
  String get dashboardGoalsSet => 'Set a goal';

  @override
  String dashboardGoalsTotal(String saved, String target) {
    return 'Saved $saved of $target';
  }

  @override
  String dashboardHeatmapDay(String date, String amount) {
    return '$date: spent $amount';
  }

  @override
  String dashboardHeatmapDayNone(String date) {
    return '$date: no spending';
  }

  @override
  String get dashboardHeatmapLess => 'Less';

  @override
  String get dashboardHeatmapMore => 'More';

  @override
  String get dashboardHeatmapTitle => 'Daily spending';

  @override
  String dashboardRecentEmpty(String month) {
    return 'No transactions in $month yet.';
  }

  @override
  String get dashboardRecentTitle => 'Recent transactions';

  @override
  String dashboardSpendingEmpty(String month) {
    return 'No expenses in $month.';
  }

  @override
  String dashboardSpendingOther(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString more categories',
      one: '1 more category',
    );
    return '$_temp0';
  }

  @override
  String dashboardSpendingPercent(int percent) {
    final intl.NumberFormat percentNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String percentString = percentNumberFormat.format(percent);

    return '$percentString%';
  }

  @override
  String get dashboardSpendingPercentTiny => '<1%';

  @override
  String get dashboardSpendingTitle => 'Spending by category';

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get designGalleryTitle => 'Design gallery';

  @override
  String get errorAmountInvalid => 'Enter an amount greater than 0.';

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
  String get errorBudgetCategoryArchived => 'This category is archived. Choose another one.';

  @override
  String get errorBudgetCategoryNotExpense => 'Budgets can only be set for expense categories.';

  @override
  String get errorBudgetCategoryRequired => 'Choose a category.';

  @override
  String errorBudgetMonthOutOfRange(int months) {
    final intl.NumberFormat monthsNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String monthsString = monthsNumberFormat.format(months);

    return 'Budgets can be set up to $monthsString months ahead.';
  }

  @override
  String get errorCategoryNameTaken => 'You already have a category with this name.';

  @override
  String get errorCategoryTypeLocked =>
      'This category is used by transactions, so its type can\'t be changed.';

  @override
  String get errorEmailInvalid => 'Enter a valid email address.';

  @override
  String get errorFieldRequired => 'This field is required.';

  @override
  String get errorGoalContributionDateOutOfRange => 'Choose a date that isn\'t in the future.';

  @override
  String errorGoalDeadlineOutOfRange(int years) {
    final intl.NumberFormat yearsNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String yearsString = yearsNumberFormat.format(years);

    return 'Choose a deadline within the next $yearsString years.';
  }

  @override
  String get errorGoalNotFound => 'This goal no longer exists.';

  @override
  String get errorNetwork => 'Can\'t reach the server. Check your connection and try again.';

  @override
  String get errorNotFound => 'We couldn\'t find that item. It may have been deleted.';

  @override
  String get errorPasswordMismatch => 'Passwords don\'t match.';

  @override
  String errorPasswordTooShort(int minLength) {
    final intl.NumberFormat minLengthNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String minLengthString = minLengthNumberFormat.format(minLength);

    return 'Use at least $minLengthString characters.';
  }

  @override
  String get errorReminderDayOfMonthRequired => 'Choose a day of the month.';

  @override
  String get errorReminderWeekdaysRequired => 'Choose at least one day.';

  @override
  String get errorStorage => 'Couldn\'t save on this device. Please try again.';

  @override
  String get errorTransactionCategoryArchived => 'This category is archived. Choose another one.';

  @override
  String get errorTransactionCategoryMismatch => 'Choose a category of this type.';

  @override
  String get errorTransactionCategoryRequired => 'Choose a category.';

  @override
  String get errorTransactionDateOutOfRange => 'Choose a date from 2000 up to a year from today.';

  @override
  String get errorUnexpected => 'Something went wrong. Please try again.';

  @override
  String get errorValidation => 'Please check the highlighted fields.';

  @override
  String get goalContributionAmountLabel => 'Amount';

  @override
  String get goalContributionDateLabel => 'Date';

  @override
  String get goalContributionDeleted => 'Contribution removed';

  @override
  String get goalContributionNoteLabel => 'Note (optional)';

  @override
  String get goalDeleteConfirmMessage => 'Its history will be deleted too.';

  @override
  String goalDeleteConfirmTitle(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get goalDetailCompleted => 'Goal reached';

  @override
  String get goalDetailDelete => 'Delete goal';

  @override
  String get goalDetailHistory => 'History';

  @override
  String get goalDetailHistoryEmpty => 'No money added yet.';

  @override
  String get goalDetailMissingMessage => 'It may have been deleted on another device.';

  @override
  String get goalDetailMissingTitle => 'Goal not found';

  @override
  String goalDetailNeededPerMonth(String amount, String date) {
    return 'Save $amount a month to reach it by $date.';
  }

  @override
  String goalDetailOverdue(String date) {
    return 'The deadline ($date) has passed.';
  }

  @override
  String goalDetailRemaining(String amount) {
    return '$amount to go';
  }

  @override
  String get goalFormClearDeadline => 'Remove deadline';

  @override
  String get goalFormColorLabel => 'Color';

  @override
  String get goalFormDeadlineLabel => 'Deadline (optional)';

  @override
  String get goalFormEditTitle => 'Edit goal';

  @override
  String get goalFormIconLabel => 'Icon';

  @override
  String get goalFormNameLabel => 'Name';

  @override
  String get goalFormNewTitle => 'New goal';

  @override
  String get goalFormNoDeadline => 'No deadline';

  @override
  String get goalFormTargetLabel => 'Target amount';

  @override
  String get goalsAdd => 'Add goal';

  @override
  String get goalsAddMoney => 'Add money';

  @override
  String get goalsCompleted => 'Completed';

  @override
  String goalsDeadline(String date) {
    return 'By $date';
  }

  @override
  String get goalsEmptyMessage => 'Set a savings goal and see how close you are.';

  @override
  String get goalsEmptyTitle => 'No goals yet';

  @override
  String goalsListSubtitle(String amounts, String status) {
    return '$amounts · $status';
  }

  @override
  String goalsPercent(int percent) {
    final intl.NumberFormat percentNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String percentString = percentNumberFormat.format(percent);

    return '$percentString%';
  }

  @override
  String goalsSavedOfTarget(String saved, String target) {
    return '$saved of $target';
  }

  @override
  String get goalsTitle => 'Goals';

  @override
  String get languageNativeName => 'English';

  @override
  String get lockBiometricLockedOut => 'Too many attempts. Use your PIN.';

  @override
  String get lockBiometricReason => 'Unlock the app to see your finances';

  @override
  String get lockBiometricUnavailable =>
      'Fingerprint or face unlock isn\'t available. Use your PIN.';

  @override
  String get lockForgotPin => 'Forgot PIN?';

  @override
  String get lockRecoveryDone => 'PIN removed. Choose a new one to keep the app locked.';

  @override
  String lockRecoveryMessage(String email) {
    return 'Enter the password of $email. The PIN is then removed and you can choose a new one.';
  }

  @override
  String get lockRecoverySkip => 'Turn app lock off';

  @override
  String get lockRecoverySubmit => 'Remove PIN';

  @override
  String get lockRecoveryTitle => 'Forgot your PIN?';

  @override
  String get lockTitle => 'Enter your PIN';

  @override
  String get lockUseBiometrics => 'Unlock with fingerprint or face';

  @override
  String get lockWrongPin => 'Wrong PIN. Try again.';

  @override
  String get notificationsChannelBudgetAlerts => 'Budget alerts';

  @override
  String get notificationsChannelBudgetAlertsDescription =>
      'When a budget is close to or over its limit.';

  @override
  String get notificationsChannelReminders => 'Reminders';

  @override
  String get notificationsChannelRemindersDescription => 'Reminders you set in the app.';

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
  String get passwordStrengthGood => 'Good';

  @override
  String get passwordStrengthGreat => 'Great';

  @override
  String passwordStrengthLabel(String level) {
    return 'Password strength: $level';
  }

  @override
  String passwordStrengthMore(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString more',
      one: '1 more',
    );
    return '$_temp0';
  }

  @override
  String get passwordStrengthOkay => 'Okay';

  @override
  String get passwordStrengthStrong => 'Strong';

  @override
  String get pinConfirmTitle => 'Enter the PIN again';

  @override
  String get pinCurrentTitle => 'Enter your current PIN';

  @override
  String get pinDeleteDigit => 'Delete last digit';

  @override
  String get pinMismatch => 'The PINs don\'t match. Choose a PIN again.';

  @override
  String pinProgress(int entered, int total) {
    final intl.NumberFormat enteredNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String enteredString = enteredNumberFormat.format(entered);
    final intl.NumberFormat totalNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return '$enteredString of $totalString digits entered';
  }

  @override
  String pinSetHint(int length) {
    final intl.NumberFormat lengthNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String lengthString = lengthNumberFormat.format(length);

    return 'Use $lengthString digits.';
  }

  @override
  String get pinSetTitle => 'Choose a PIN';

  @override
  String get reminderDeleteConfirmMessage => 'It won\'t remind you any more.';

  @override
  String reminderDeleteConfirmTitle(String title) {
    return 'Delete \"$title\"?';
  }

  @override
  String reminderEveryDay(String time) {
    return 'Every day at $time';
  }

  @override
  String get reminderFormDayOfMonthHint => 'Short months use their last day.';

  @override
  String get reminderFormDayOfMonthLabel => 'Day of the month';

  @override
  String get reminderFormDaysLabel => 'Days';

  @override
  String get reminderFormDelete => 'Delete reminder';

  @override
  String get reminderFormEditTitle => 'Edit reminder';

  @override
  String get reminderFormNewTitle => 'New reminder';

  @override
  String get reminderFormRepeatLabel => 'Repeat';

  @override
  String get reminderFormTimeLabel => 'Time';

  @override
  String get reminderFormTitleHint => 'e.g. Log today\'s expenses';

  @override
  String get reminderFormTitleLabel => 'Title';

  @override
  String reminderMonthly(int day, String time) {
    final intl.NumberFormat dayNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String dayString = dayNumberFormat.format(day);

    return 'Monthly on day $dayString at $time';
  }

  @override
  String get reminderRepeatDaily => 'Daily';

  @override
  String get reminderRepeatMonthly => 'Monthly';

  @override
  String get reminderRepeatWeekly => 'Weekly';

  @override
  String reminderSwitchLabel(String title) {
    return '$title on';
  }

  @override
  String reminderWeekly(String days, String time) {
    return '$days at $time';
  }

  @override
  String get remindersAdd => 'Add reminder';

  @override
  String get remindersEmptyMessage =>
      'Add one for a regular nudge, like logging today\'s expenses.';

  @override
  String get remindersEmptyTitle => 'No reminders yet';

  @override
  String get remindersPermissionDenied =>
      'Notifications are off for this app. Allow them in system settings to get reminders.';

  @override
  String get remindersTitle => 'Reminders';

  @override
  String get settingsAccountLabel => 'Account';

  @override
  String get settingsAppLock => 'App lock';

  @override
  String get settingsAppLockDescription => 'Ask for a PIN to open the app';

  @override
  String get settingsAppLockOff => 'App lock is off';

  @override
  String get settingsAppLockOn => 'App lock is on';

  @override
  String get settingsAutoLock => 'Auto-lock';

  @override
  String settingsAutoLockAfterMinutes(int minutes) {
    final intl.NumberFormat minutesNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String minutesString = minutesNumberFormat.format(minutes);

    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: 'After $minutesString minutes',
      one: 'After 1 minute',
    );
    return '$_temp0';
  }

  @override
  String settingsAutoLockAfterSeconds(int seconds) {
    final intl.NumberFormat secondsNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String secondsString = secondsNumberFormat.format(seconds);

    return 'After $secondsString seconds';
  }

  @override
  String get settingsAutoLockImmediately => 'Immediately';

  @override
  String get settingsBiometrics => 'Unlock with fingerprint or face';

  @override
  String get settingsBiometricsUnavailable =>
      'Set up a fingerprint or face on this phone to use it here.';

  @override
  String get settingsChangePin => 'Change PIN';

  @override
  String get settingsPinChanged => 'PIN changed';

  @override
  String get settingsSecurityLabel => 'Security';

  @override
  String get settingsBudgetAlerts => 'Budget alerts';

  @override
  String get settingsBudgetAlertsDescription => 'Alert me at 80% and 100% of a budget.';

  @override
  String get settingsBudgetAlertsPermissionDenied =>
      'Notifications are off for this app. Allow them in system settings to get budget alerts.';

  @override
  String get settingsCurrency => 'Currency';

  @override
  String get settingsCurrencyLocked =>
      'Chosen when you set up the app. It can\'t be changed, so all your amounts stay in one currency.';

  @override
  String settingsCurrencyValue(String code, String symbol) {
    return '$code ($symbol)';
  }

  @override
  String get settingsLanguageChoose => 'Choose a language';

  @override
  String get settingsLanguageDevice => 'Device language';

  @override
  String get settingsLanguageLabel => 'Language';

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
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$countString changes on this device haven\'t synced yet. If you log out now, they will be lost.',
      one: '1 change on this device hasn\'t synced yet. If you log out now, it will be lost.',
    );
    return '$_temp0';
  }

  @override
  String get settingsManageLabel => 'Manage';

  @override
  String get settingsNotificationsLabel => 'Notifications';

  @override
  String get settingsProfileLabel => 'Profile';

  @override
  String get settingsSyncLabel => 'Sync';

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
  String get syncNow => 'Sync now';

  @override
  String get syncStatusError => 'Couldn\'t sync. We\'ll keep trying.';

  @override
  String get syncStatusOffline => 'Offline. Changes will sync when you\'re back online.';

  @override
  String syncStatusPending(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString changes waiting to sync',
      one: '1 change waiting to sync',
    );
    return '$_temp0';
  }

  @override
  String get syncStatusSynced => 'All changes synced';

  @override
  String get syncStatusSyncing => 'Syncing…';

  @override
  String get transactionDeleted => 'Transaction deleted';

  @override
  String get transactionDetailNoteLabel => 'Note';

  @override
  String get transactionDetailTitle => 'Transaction';

  @override
  String get transactionFormAmountLabel => 'Amount';

  @override
  String get transactionFormCategoryLabel => 'Category';

  @override
  String get transactionFormDateLabel => 'Date';

  @override
  String get transactionFormEditTitle => 'Edit transaction';

  @override
  String get transactionFormNewTitle => 'New transaction';

  @override
  String get transactionFormNoCategories =>
      'No categories of this type yet. Add one in Settings → Categories.';

  @override
  String get transactionFormNoteLabel => 'Note (optional)';

  @override
  String get transactionNotFoundMessage => 'It may have been deleted on this or another device.';

  @override
  String get transactionNotFoundTitle => 'Transaction not found';

  @override
  String get transactionsAdd => 'Add transaction';

  @override
  String get transactionsEmptyMessage => 'Tap + to add your first one.';

  @override
  String get transactionsClearFilters => 'Clear filters';

  @override
  String transactionsEmptyTitle(String month) {
    return 'No transactions in $month';
  }

  @override
  String get transactionsFilterAllCategories => 'All categories';

  @override
  String get transactionsFilterCategoryTitle => 'Filter by category';

  @override
  String get transactionsFilterClearCategory => 'Clear category filter';

  @override
  String get transactionsNoMatchesMessage => 'Try another month or clear the filters.';

  @override
  String get transactionsNoMatchesTitle => 'No matching transactions';

  @override
  String get transactionsTitle => 'Transactions';
}
