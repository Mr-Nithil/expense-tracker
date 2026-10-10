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
  String get authLoginTitle => 'Sign in';

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
  String get errorAuth => 'Your session has ended. Please sign in again.';

  @override
  String get errorNetwork => 'Can\'t reach the server. Check your connection and try again.';

  @override
  String get errorNotFound => 'We couldn\'t find that item. It may have been deleted.';

  @override
  String get errorStorage => 'Couldn\'t save on this device. Please try again.';

  @override
  String get errorUnexpected => 'Something went wrong. Please try again.';

  @override
  String get errorValidation => 'Please check the highlighted fields.';

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
