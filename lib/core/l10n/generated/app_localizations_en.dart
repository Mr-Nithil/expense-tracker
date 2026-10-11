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
  String get budgetCategoriesHeader => 'Categories';

  @override
  String budgetCopied(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Copied $count budgets from last month.',
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
    return '$percent% used';
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
    return 'Color $index of $count';
  }

  @override
  String get categoryFormEditTitle => 'Edit category';

  @override
  String get categoryFormIconLabel => 'Icon';

  @override
  String categoryFormIconOption(int index, int count) {
    return 'Icon $index of $count';
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
  String get commonComingSoonMessage => 'This screen is still being built.';

  @override
  String get commonComingSoonTitle => 'Coming soon';

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
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count more categories',
      one: '1 more category',
    );
    return '$_temp0';
  }

  @override
  String dashboardSpendingPercent(int percent) {
    return '$percent%';
  }

  @override
  String get dashboardSpendingPercentTiny => '<1%';

  @override
  String get dashboardSpendingTitle => 'Spending by category';

  @override
  String get dashboardTitle => 'Dashboard';

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
    return 'Budgets can be set up to $months months ahead.';
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
  String get settingsCurrency => 'Currency';

  @override
  String get settingsCurrencyLocked =>
      'Chosen when you set up the app. It can\'t be changed, so all your amounts stay in one currency.';

  @override
  String settingsCurrencyValue(String code, String symbol) {
    return '$code ($symbol)';
  }

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
  String get settingsManageLabel => 'Manage';

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
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count changes waiting to sync',
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
