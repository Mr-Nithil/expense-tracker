// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Sinhala Sinhalese (`si`).
class AppLocalizationsSi extends AppLocalizations {
  AppLocalizationsSi([String locale = 'si']) : super(locale);

  @override
  String get appTitle => 'වියදම් ලුහුබැඳීම';

  @override
  String get authConfirmationResent =>
      'තහවුරු කිරීමේ විද්‍යුත් තැපෑල යැව්වා. ඔබේ එන ලිපි පරීක්ෂා කරන්න.';

  @override
  String get authConfirmPasswordLabel => 'මුරපදය තහවුරු කරන්න';

  @override
  String get authDisplayNameLabel => 'නම (අත්‍යවශ්‍ය නොවේ)';

  @override
  String get authEmailLabel => 'විද්‍යුත් තැපෑල';

  @override
  String get authForgotPasswordBackToLogin => 'පුරනය වීමට ආපසු';

  @override
  String authForgotPasswordSentMessage(String email) {
    return '$email සඳහා ගිණුමක් ඇත්නම්, ඔබේ මුරපදය යළි සැකසීමට සබැඳියක් අපි යැව්වෙමු.';
  }

  @override
  String get authForgotPasswordSentTitle => 'ඔබේ විද්‍යුත් තැපෑල පරීක්ෂා කරන්න';

  @override
  String get authForgotPasswordSubmit => 'යළි සැකසීමේ සබැඳිය යවන්න';

  @override
  String get authForgotPasswordSubtitle =>
      'ඔබේ ගිණුමේ විද්‍යුත් තැපෑල ඇතුළත් කරන්න. මුරපදය යළි සැකසීමට අපි සබැඳියක් එවන්නෙමු.';

  @override
  String get authForgotPasswordTitle => 'මුරපදය යළි සකසන්න';

  @override
  String get authHidePassword => 'මුරපදය සඟවන්න';

  @override
  String get authLoginForgotPassword => 'මුරපදය අමතකද?';

  @override
  String get authLoginGoToSignUp => 'අලුත්ද? ගිණුමක් සාදන්න';

  @override
  String get authLoginSubmit => 'පුරනය වන්න';

  @override
  String get authLoginSubtitle => 'නැවත සාදරයෙන් පිළිගනිමු. දිගටම කරගෙන යාමට පුරනය වන්න.';

  @override
  String get authLoginTitle => 'පුරනය වන්න';

  @override
  String get authPasswordLabel => 'මුරපදය';

  @override
  String get authNewPasswordLabel => 'නව මුරපදය';

  @override
  String authPasswordHint(int minLength) {
    final intl.NumberFormat minLengthNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String minLengthString = minLengthNumberFormat.format(minLength);

    return 'අවම වශයෙන් අක්ෂර $minLengthStringක්';
  }

  @override
  String get authResendConfirmation => 'විද්‍යුත් තැපෑල නැවත යවන්න';

  @override
  String get authResetPasswordCancel => 'අවලංගු කර ඉවත් වන්න';

  @override
  String get authResetPasswordSubmit => 'මුරපදය සුරකින්න';

  @override
  String authResetPasswordSubtitle(String email) {
    return '$email සඳහා නව මුරපදයක් තෝරන්න.';
  }

  @override
  String get authResetPasswordTitle => 'නව මුරපදයක් සකසන්න';

  @override
  String get authShowPassword => 'මුරපදය පෙන්වන්න';

  @override
  String get authSplashSyncing => 'ඔබේ දත්ත ලබා ගනිමින්…';

  @override
  String get authSignUpConfirmEmailSent =>
      'ගිණුම සෑදුවා. එය තහවුරු කිරීමට ඔබේ විද්‍යුත් තැපෑල පරීක්ෂා කර, ඉන්පසු පුරනය වන්න.';

  @override
  String get authSignUpSubmit => 'ගිණුම සාදන්න';

  @override
  String get authSignUpSubtitle => 'ඔබේ සියලු උපාංගවල වියදම් ලුහුබඳින්න.';

  @override
  String get authSignUpTitle => 'ගිණුම සාදන්න';

  @override
  String get budgetAdd => 'අයවැයක් එක් කරන්න';

  @override
  String budgetAlertBody(String spent, String limit) {
    return 'මේ මාසයේ $limitන් $spentක් වියදම් කර ඇත.';
  }

  @override
  String budgetAlertExceededTitle(String name) {
    return '$name: සීමාවට ළඟා විය';
  }

  @override
  String budgetAlertWarningTitle(String name, int percent) {
    final intl.NumberFormat percentNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String percentString = percentNumberFormat.format(percent);

    return '$name: $percentString% භාවිත කර ඇත';
  }

  @override
  String get budgetCategoriesHeader => 'ප්‍රවර්ග';

  @override
  String budgetCopied(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'පසුගිය මාසයෙන් අයවැය $countStringක් පිටපත් කළා.',
      one: 'පසුගිය මාසයෙන් අයවැයක් පිටපත් කළා.',
      zero: 'පසුගිය මාසයෙන් පිටපත් කිරීමට අලුත් කිසිවක් නැත.',
    );
    return '$_temp0';
  }

  @override
  String get budgetCopyPrevious => 'පසුගිය මාසයේ අයවැය පිටපත් කරන්න';

  @override
  String get budgetEmptyMessage => 'ඔබේ වියදම් ගමන් කරන ආකාරය බැලීමට මාසික සීමාවක් සකසන්න.';

  @override
  String budgetEmptyTitle(String month) {
    return '$month සඳහා අයවැය නැත';
  }

  @override
  String get budgetFormCategory => 'ප්‍රවර්ගය';

  @override
  String get budgetFormEditTitle => 'අයවැය සංස්කරණය කරන්න';

  @override
  String get budgetFormLimitLabel => 'මාසික සීමාව';

  @override
  String get budgetFormNewTitle => 'නව අයවැය';

  @override
  String get budgetFormNoCategoriesLeft => 'මේ මාසයේ සෑම වියදම් ප්‍රවර්ගයකටම දැනටමත් අයවැයක් ඇත.';

  @override
  String get budgetFormOverall => 'සමස්ත';

  @override
  String get budgetFormOverallHint => 'මේ මාසයේ ඔබේ සියලු වියදම් ආවරණය කරයි.';

  @override
  String get budgetFormRemove => 'අයවැය ඉවත් කරන්න';

  @override
  String budgetOver(String amount) {
    return '$amountකින් ඉක්මවා ඇත';
  }

  @override
  String get budgetOverallEmptyMessage =>
      'මේ මාසයේ ඔබේ සියලු වියදම් ලුහුබැඳීමට සමස්ත සීමාවක් සකසන්න.';

  @override
  String get budgetOverallEmptyTitle => 'සමස්ත අයවැයක් නැත';

  @override
  String get budgetOverallTitle => 'සමස්ත අයවැය';

  @override
  String budgetPercentUsed(int percent) {
    final intl.NumberFormat percentNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String percentString = percentNumberFormat.format(percent);

    return '$percentString% භාවිත කර ඇත';
  }

  @override
  String get budgetRemoveConfirmMessage => 'ඔබේ ගනුදෙනු එලෙසම පවතී.';

  @override
  String get budgetRemoveConfirmTitle => 'මෙම අයවැය ඉවත් කරන්නද?';

  @override
  String budgetRemaining(String amount) {
    return '$amount ඉතිරියි';
  }

  @override
  String budgetSpentOfLimit(String spent, String limit) {
    return '$limitන් $spent';
  }

  @override
  String get budgetStatusExceeded => 'සීමාවට ළඟා විය';

  @override
  String get budgetStatusWarning => 'සීමාවට ආසන්නයි';

  @override
  String get budgetTitle => 'අයවැය';

  @override
  String calendarDayEmpty(String date) {
    return '$date: ගනුදෙනු නැත';
  }

  @override
  String calendarDayLabel(String date, String amount) {
    return '$date: $amount';
  }

  @override
  String get calendarDayNet => 'ශුද්ධ';

  @override
  String calendarNoTransactionsOn(String date) {
    return '$date දින ගනුදෙනු නැත.';
  }

  @override
  String get calendarTitle => 'දින දර්ශනය';

  @override
  String get categoryFormArchive => 'සංරක්ෂණය කරන්න';

  @override
  String get categoryFormColorLabel => 'වර්ණය';

  @override
  String categoryFormColorOption(int index, int count) {
    final intl.NumberFormat indexNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String indexString = indexNumberFormat.format(index);
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'වර්ණ $countStringන් $indexString';
  }

  @override
  String get categoryFormEditTitle => 'ප්‍රවර්ගය සංස්කරණය කරන්න';

  @override
  String get categoryFormIconLabel => 'නිරූපකය';

  @override
  String categoryFormIconOption(int index, int count) {
    final intl.NumberFormat indexNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String indexString = indexNumberFormat.format(index);
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'නිරූපක $countStringන් $indexString';
  }

  @override
  String get categoryFormNameLabel => 'නම';

  @override
  String get categoryFormNewTitle => 'නව ප්‍රවර්ගය';

  @override
  String get categoryFormTypeLabel => 'වර්ගය';

  @override
  String get categoryArchiveConfirmMessage =>
      'නව ගනුදෙනු සඳහා එය ලබා නොදේ. දැනටමත් එය භාවිත කරන ගනුදෙනු එය තබා ගනී.';

  @override
  String categoryArchiveConfirmTitle(String name) {
    return '“$name” සංරක්ෂණය කරන්නද?';
  }

  @override
  String get categoryArchivedLabel => 'සංරක්ෂිත ප්‍රවර්ගය';

  @override
  String categoryChipArchived(String name) {
    return '$name (සංරක්ෂිත)';
  }

  @override
  String get categoryDefaultBills => 'බිල්පත්';

  @override
  String get categoryDefaultEducation => 'අධ්‍යාපනය';

  @override
  String get categoryDefaultEntertainment => 'විනෝදාස්වාදය';

  @override
  String get categoryDefaultFood => 'ආහාර';

  @override
  String get categoryDefaultFreelance => 'නිදහස් සේවා';

  @override
  String get categoryDefaultGifts => 'තෑගි';

  @override
  String get categoryDefaultHealth => 'සෞඛ්‍යය';

  @override
  String get categoryDefaultInvestments => 'ආයෝජන';

  @override
  String get categoryDefaultOther => 'වෙනත්';

  @override
  String get categoryDefaultOtherIncome => 'වෙනත් ආදායම්';

  @override
  String get categoryDefaultSalary => 'වැටුප';

  @override
  String get categoryDefaultShopping => 'සාප්පු සවාරි';

  @override
  String get categoryDefaultTransport => 'ප්‍රවාහනය';

  @override
  String get categoriesAdd => 'ප්‍රවර්ගයක් එක් කරන්න';

  @override
  String get categoriesEmptyMessage => 'ඔබේ ගනුදෙනු වර්ග කිරීම ආරම්භ කිරීමට ප්‍රවර්ගයක් එක් කරන්න.';

  @override
  String get categoriesEmptyTitle => 'තවම ප්‍රවර්ග නැත';

  @override
  String get categoriesTitle => 'ප්‍රවර්ග';

  @override
  String get categoryUnknown => 'නොදන්නා ප්‍රවර්ගය';

  @override
  String get commonAll => 'සියල්ල';

  @override
  String get commonCancel => 'අවලංගු කරන්න';

  @override
  String get commonConfirm => 'තහවුරු කරන්න';

  @override
  String get commonDelete => 'මකන්න';

  @override
  String get commonEdit => 'සංස්කරණය';

  @override
  String get commonExpense => 'වියදම';

  @override
  String get commonIncome => 'ආදායම';

  @override
  String get commonListSeparator => ', ';

  @override
  String get commonLoading => 'පූරණය වෙමින්';

  @override
  String get commonNextMonth => 'ඊළඟ මාසය';

  @override
  String get commonPreviousMonth => 'පෙර මාසය';

  @override
  String get commonRetry => 'නැවත උත්සාහ කරන්න';

  @override
  String get commonSave => 'සුරකින්න';

  @override
  String get commonSeeAll => 'සියල්ල බලන්න';

  @override
  String get commonToday => 'අද';

  @override
  String get commonUndo => 'පසුගමනය';

  @override
  String get commonYesterday => 'ඊයේ';

  @override
  String get dashboardBalance => 'ශේෂය';

  @override
  String dashboardBudgetsEmpty(String month) {
    return '$month සඳහා අයවැය නැත.';
  }

  @override
  String get dashboardBudgetsSet => 'අයවැයක් සකසන්න';

  @override
  String get dashboardBudgetsTitle => 'අයවැය';

  @override
  String get dashboardGoalsEmpty => 'තවම ඉතුරුම් ඉලක්ක නැත.';

  @override
  String dashboardGoalsReached(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ඉලක්ක $countStringක් සපුරා ඇත',
      one: 'ඉලක්කයක් සපුරා ඇත',
    );
    return '$_temp0';
  }

  @override
  String get dashboardGoalsSet => 'ඉලක්කයක් සකසන්න';

  @override
  String dashboardGoalsTotal(String saved, String target) {
    return '$targetන් $savedක් ඉතිරි කර ඇත';
  }

  @override
  String dashboardHeatmapDay(String date, String amount) {
    return '$date: $amountක් වියදම් කළා';
  }

  @override
  String dashboardHeatmapDayNone(String date) {
    return '$date: වියදමක් නැත';
  }

  @override
  String get dashboardHeatmapLess => 'අඩු';

  @override
  String get dashboardHeatmapMore => 'වැඩි';

  @override
  String get dashboardHeatmapTitle => 'දෛනික වියදම්';

  @override
  String dashboardRecentEmpty(String month) {
    return '$month තුළ තවම ගනුදෙනු නැත.';
  }

  @override
  String get dashboardRecentTitle => 'මෑත ගනුදෙනු';

  @override
  String dashboardSpendingEmpty(String month) {
    return '$month තුළ වියදම් නැත.';
  }

  @override
  String dashboardSpendingOther(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'තවත් ප්‍රවර්ග $countStringක්',
      one: 'තවත් ප්‍රවර්ගයක්',
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
  String get dashboardSpendingTitle => 'ප්‍රවර්ග අනුව වියදම්';

  @override
  String get dashboardTitle => 'උපකරණ පුවරුව';

  @override
  String get errorAmountInvalid => '0ට වැඩි මුදලක් ඇතුළත් කරන්න.';

  @override
  String get errorAuth => 'සත්‍යාපනය අසාර්ථක විය. කරුණාකර නැවත පුරනය වන්න.';

  @override
  String get errorAuthEmailExists =>
      'මෙම විද්‍යුත් තැපෑල සහිත ගිණුමක් දැනටමත් ඇත. ඒ වෙනුවට පුරනය වීමට උත්සාහ කරන්න.';

  @override
  String get errorAuthEmailNotConfirmed =>
      'කරුණාකර පළමුව ඔබේ විද්‍යුත් තැපෑල තහවුරු කරන්න. සබැඳිය සඳහා ඔබේ එන ලිපි පරීක්ෂා කරන්න.';

  @override
  String get errorAuthInvalidCredentials => 'විද්‍යුත් තැපෑල හෝ මුරපදය වැරදියි.';

  @override
  String get errorAuthLinkExpired =>
      'මෙම සබැඳිය කල් ඉකුත් වී හෝ දැනටමත් භාවිත කර ඇත. කරුණාකර අලුත් එකක් ඉල්ලන්න.';

  @override
  String get errorAuthLinkInvalid =>
      'මෙම සබැඳිය මෙහි භාවිත කළ නොහැක. ඔබ එය ඉල්ලූ උපාංගයේ එය විවෘත කරන්න, නැතහොත් අලුත් එකක් ඉල්ලන්න.';

  @override
  String get errorAuthRateLimited => 'උත්සාහයන් වැඩියි. කරුණාකර මොහොතක් රැඳී නැවත උත්සාහ කරන්න.';

  @override
  String get errorAuthSamePassword => 'ඔබේ නව මුරපදය පැරණි මුරපදයට වඩා වෙනස් විය යුතුය.';

  @override
  String get errorAuthWeakPassword => 'මෙම මුරපදය දුර්වලයි. ශක්තිමත් එකක් තෝරන්න.';

  @override
  String get errorBudgetCategoryArchived => 'මෙම ප්‍රවර්ගය සංරක්ෂිතයි. වෙනත් එකක් තෝරන්න.';

  @override
  String get errorBudgetCategoryNotExpense => 'අයවැය සැකසිය හැක්කේ වියදම් ප්‍රවර්ග සඳහා පමණි.';

  @override
  String get errorBudgetCategoryRequired => 'ප්‍රවර්ගයක් තෝරන්න.';

  @override
  String errorBudgetMonthOutOfRange(int months) {
    final intl.NumberFormat monthsNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String monthsString = monthsNumberFormat.format(months);

    return 'අයවැය සැකසිය හැක්කේ මාස $monthsStringක් ඉදිරියට දක්වා පමණි.';
  }

  @override
  String get errorCategoryNameTaken => 'මෙම නම සහිත ප්‍රවර්ගයක් ඔබට දැනටමත් ඇත.';

  @override
  String get errorCategoryTypeLocked =>
      'මෙම ප්‍රවර්ගය ගනුදෙනු මගින් භාවිත වන නිසා, එහි වර්ගය වෙනස් කළ නොහැක.';

  @override
  String get errorEmailInvalid => 'වලංගු විද්‍යුත් තැපැල් ලිපිනයක් ඇතුළත් කරන්න.';

  @override
  String get errorFieldRequired => 'මෙම ක්ෂේත්‍රය අවශ්‍යයි.';

  @override
  String get errorGoalContributionDateOutOfRange => 'අනාගතයේ නොවන දිනයක් තෝරන්න.';

  @override
  String errorGoalDeadlineOutOfRange(int years) {
    final intl.NumberFormat yearsNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String yearsString = yearsNumberFormat.format(years);

    return 'ඉදිරි වසර $yearsString තුළ අවසන් දිනයක් තෝරන්න.';
  }

  @override
  String get errorGoalNotFound => 'මෙම ඉලක්කය තවදුරටත් නොපවතී.';

  @override
  String get errorNetwork =>
      'සේවාදායකයට ළඟා විය නොහැක. ඔබේ සම්බන්ධතාවය පරීක්ෂා කර නැවත උත්සාහ කරන්න.';

  @override
  String get errorNotFound => 'එම අයිතමය සොයා ගත නොහැකි විය. එය මකා දමා තිබිය හැක.';

  @override
  String get errorPasswordMismatch => 'මුරපද නොගැළපේ.';

  @override
  String errorPasswordTooShort(int minLength) {
    final intl.NumberFormat minLengthNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String minLengthString = minLengthNumberFormat.format(minLength);

    return 'අවම වශයෙන් අක්ෂර $minLengthStringක් භාවිත කරන්න.';
  }

  @override
  String get errorReminderDayOfMonthRequired => 'මාසයේ දිනයක් තෝරන්න.';

  @override
  String get errorReminderWeekdaysRequired => 'අවම වශයෙන් එක් දිනයක් තෝරන්න.';

  @override
  String get errorStorage => 'මෙම උපාංගයේ සුරැකීමට නොහැකි විය. කරුණාකර නැවත උත්සාහ කරන්න.';

  @override
  String get errorTransactionCategoryArchived => 'මෙම ප්‍රවර්ගය සංරක්ෂිතයි. වෙනත් එකක් තෝරන්න.';

  @override
  String get errorTransactionCategoryMismatch => 'මෙම වර්ගයේ ප්‍රවර්ගයක් තෝරන්න.';

  @override
  String get errorTransactionCategoryRequired => 'ප්‍රවර්ගයක් තෝරන්න.';

  @override
  String get errorTransactionDateOutOfRange => '2000 සිට අද සිට වසරක් දක්වා දිනයක් තෝරන්න.';

  @override
  String get errorUnexpected => 'යමක් වැරදී ගියා. කරුණාකර නැවත උත්සාහ කරන්න.';

  @override
  String get errorValidation => 'කරුණාකර ඉස්මතු කළ ක්ෂේත්‍ර පරීක්ෂා කරන්න.';

  @override
  String get goalContributionAmountLabel => 'මුදල';

  @override
  String get goalContributionDateLabel => 'දිනය';

  @override
  String get goalContributionDeleted => 'දායකත්වය ඉවත් කළා';

  @override
  String get goalContributionNoteLabel => 'සටහන (අත්‍යවශ්‍ය නොවේ)';

  @override
  String get goalDeleteConfirmMessage => 'එහි ඉතිහාසයද මැකී යයි.';

  @override
  String goalDeleteConfirmTitle(String name) {
    return '\"$name\" මකන්නද?';
  }

  @override
  String get goalDetailCompleted => 'ඉලක්කය සපුරා ඇත';

  @override
  String get goalDetailDelete => 'ඉලක්කය මකන්න';

  @override
  String get goalDetailHistory => 'ඉතිහාසය';

  @override
  String get goalDetailHistoryEmpty => 'තවම මුදල් එක් කර නැත.';

  @override
  String get goalDetailMissingMessage => 'එය වෙනත් උපාංගයකින් මකා දමා තිබිය හැක.';

  @override
  String get goalDetailMissingTitle => 'ඉලක්කය හමු නොවීය';

  @override
  String goalDetailNeededPerMonth(String amount, String date) {
    return '$date වන විට එයට ළඟා වීමට මසකට $amountක් ඉතිරි කරන්න.';
  }

  @override
  String goalDetailOverdue(String date) {
    return 'අවසන් දිනය ($date) ඉක්මවා ඇත.';
  }

  @override
  String goalDetailRemaining(String amount) {
    return 'තව $amountක් ඉතිරියි';
  }

  @override
  String get goalFormClearDeadline => 'අවසන් දිනය ඉවත් කරන්න';

  @override
  String get goalFormColorLabel => 'වර්ණය';

  @override
  String get goalFormDeadlineLabel => 'අවසන් දිනය (අත්‍යවශ්‍ය නොවේ)';

  @override
  String get goalFormEditTitle => 'ඉලක්කය සංස්කරණය කරන්න';

  @override
  String get goalFormIconLabel => 'නිරූපකය';

  @override
  String get goalFormNameLabel => 'නම';

  @override
  String get goalFormNewTitle => 'නව ඉලක්කය';

  @override
  String get goalFormNoDeadline => 'අවසන් දිනයක් නැත';

  @override
  String get goalFormTargetLabel => 'ඉලක්ක මුදල';

  @override
  String get goalsAdd => 'ඉලක්කයක් එක් කරන්න';

  @override
  String get goalsAddMoney => 'මුදල් එක් කරන්න';

  @override
  String get goalsCompleted => 'සම්පූර්ණයි';

  @override
  String goalsDeadline(String date) {
    return '$date වන විට';
  }

  @override
  String get goalsEmptyMessage => 'ඉතුරුම් ඉලක්කයක් සකසා ඔබ කොතරම් ළඟදැයි බලන්න.';

  @override
  String get goalsEmptyTitle => 'තවම ඉලක්ක නැත';

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
    return '$targetන් $saved';
  }

  @override
  String get goalsTitle => 'ඉලක්ක';

  @override
  String get languageNativeName => 'සිංහල';

  @override
  String get lockBiometricLockedOut => 'උත්සාහයන් වැඩියි. ඔබේ PIN අංකය භාවිත කරන්න.';

  @override
  String get lockBiometricReason => 'ඔබේ මූල්‍ය තොරතුරු බැලීමට යෙදුමේ අගුළු හරින්න';

  @override
  String get lockBiometricUnavailable =>
      'ඇඟිලි සලකුණ හෝ මුහුණ මගින් අගුළු හැරීම ලබා ගත නොහැක. ඔබේ PIN අංකය භාවිත කරන්න.';

  @override
  String get lockForgotPin => 'PIN අංකය අමතකද?';

  @override
  String get lockRecoveryDone => 'PIN අංකය ඉවත් කළා. යෙදුම අගුළු දමා තබා ගැනීමට අලුත් එකක් තෝරන්න.';

  @override
  String lockRecoveryMessage(String email) {
    return '$email ගිණුමේ මුරපදය ඇතුළත් කරන්න. එවිට PIN අංකය ඉවත් වන අතර ඔබට අලුත් එකක් තෝරා ගත හැක.';
  }

  @override
  String get lockRecoverySkip => 'යෙදුම් අගුල අක්‍රිය කරන්න';

  @override
  String get lockRecoverySubmit => 'PIN අංකය ඉවත් කරන්න';

  @override
  String get lockRecoveryTitle => 'ඔබේ PIN අංකය අමතකද?';

  @override
  String get lockTitle => 'ඔබේ PIN අංකය ඇතුළත් කරන්න';

  @override
  String get lockUseBiometrics => 'ඇඟිලි සලකුණ හෝ මුහුණ මගින් අගුළු හරින්න';

  @override
  String get lockWrongPin => 'වැරදි PIN අංකයකි. නැවත උත්සාහ කරන්න.';

  @override
  String get notificationsChannelBudgetAlerts => 'අයවැය අනතුරු ඇඟවීම්';

  @override
  String get notificationsChannelBudgetAlertsDescription =>
      'අයවැයක් එහි සීමාවට ආසන්න වූ විට හෝ ඉක්මවූ විට.';

  @override
  String get notificationsChannelReminders => 'සිහිකැඳවීම්';

  @override
  String get notificationsChannelRemindersDescription => 'ඔබ යෙදුමේ සකසන සිහිකැඳවීම්.';

  @override
  String get onboardingContinue => 'ඉදිරියට';

  @override
  String onboardingCurrencyExample(String amount) {
    return 'උදා. $amount';
  }

  @override
  String onboardingCurrencySuggestedExample(String amount) {
    return 'යෝජිත · උදා. $amount';
  }

  @override
  String get onboardingSubtitle =>
      'යෙදුමේ සියලු මුදල් මෙම මුදල් ඒකකය භාවිත කරයි. එය පසුව වෙනස් කළ නොහැක.';

  @override
  String get onboardingTitle => 'ඔබේ මුදල් ඒකකය තෝරන්න';

  @override
  String get pinConfirmTitle => 'PIN අංකය නැවත ඇතුළත් කරන්න';

  @override
  String get pinCurrentTitle => 'ඔබේ වත්මන් PIN අංකය ඇතුළත් කරන්න';

  @override
  String get pinDeleteDigit => 'අවසන් ඉලක්කම මකන්න';

  @override
  String get pinMismatch => 'PIN අංක නොගැළපේ. නැවත PIN අංකයක් තෝරන්න.';

  @override
  String pinProgress(int entered, int total) {
    final intl.NumberFormat enteredNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String enteredString = enteredNumberFormat.format(entered);
    final intl.NumberFormat totalNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return 'ඉලක්කම් $totalStringන් $enteredStringක් ඇතුළත් කළා';
  }

  @override
  String pinSetHint(int length) {
    final intl.NumberFormat lengthNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String lengthString = lengthNumberFormat.format(length);

    return 'ඉලක්කම් $lengthStringක් භාවිත කරන්න.';
  }

  @override
  String get pinSetTitle => 'PIN අංකයක් තෝරන්න';

  @override
  String get reminderDeleteConfirmMessage => 'එය තවදුරටත් ඔබට සිහිකැඳවන්නේ නැත.';

  @override
  String reminderDeleteConfirmTitle(String title) {
    return '\"$title\" මකන්නද?';
  }

  @override
  String reminderEveryDay(String time) {
    return 'සෑම දිනකම $timeට';
  }

  @override
  String get reminderFormDayOfMonthHint => 'කෙටි මාසවල අවසන් දිනය භාවිත වේ.';

  @override
  String get reminderFormDayOfMonthLabel => 'මාසයේ දිනය';

  @override
  String get reminderFormDaysLabel => 'දින';

  @override
  String get reminderFormDelete => 'සිහිකැඳවීම මකන්න';

  @override
  String get reminderFormEditTitle => 'සිහිකැඳවීම සංස්කරණය කරන්න';

  @override
  String get reminderFormNewTitle => 'නව සිහිකැඳවීම';

  @override
  String get reminderFormRepeatLabel => 'නැවත කිරීම';

  @override
  String get reminderFormTimeLabel => 'වේලාව';

  @override
  String get reminderFormTitleHint => 'උදා. අද වියදම් සටහන් කරන්න';

  @override
  String get reminderFormTitleLabel => 'මාතෘකාව';

  @override
  String reminderMonthly(int day, String time) {
    final intl.NumberFormat dayNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String dayString = dayNumberFormat.format(day);

    return 'මාසිකව $dayString වන දින $timeට';
  }

  @override
  String get reminderRepeatDaily => 'දිනපතා';

  @override
  String get reminderRepeatMonthly => 'මාසිකව';

  @override
  String get reminderRepeatWeekly => 'සතිපතා';

  @override
  String reminderSwitchLabel(String title) {
    return '$title සක්‍රියයි';
  }

  @override
  String reminderWeekly(String days, String time) {
    return '$days $timeට';
  }

  @override
  String get remindersAdd => 'සිහිකැඳවීමක් එක් කරන්න';

  @override
  String get remindersEmptyMessage =>
      'අද වියදම් සටහන් කිරීම වැනි නිතිපතා මතක් කිරීමක් සඳහා එකක් එක් කරන්න.';

  @override
  String get remindersEmptyTitle => 'තවම සිහිකැඳවීම් නැත';

  @override
  String get remindersPermissionDenied =>
      'මෙම යෙදුම සඳහා දැනුම්දීම් අක්‍රියයි. සිහිකැඳවීම් ලබා ගැනීමට පද්ධති සැකසීම්වලින් ඒවාට ඉඩ දෙන්න.';

  @override
  String get remindersTitle => 'සිහිකැඳවීම්';

  @override
  String get settingsAccountLabel => 'ගිණුම';

  @override
  String get settingsAppLock => 'යෙදුම් අගුල';

  @override
  String get settingsAppLockDescription => 'යෙදුම විවෘත කිරීමට PIN අංකයක් ඉල්ලන්න';

  @override
  String get settingsAppLockOff => 'යෙදුම් අගුල අක්‍රියයි';

  @override
  String get settingsAppLockOn => 'යෙදුම් අගුල සක්‍රියයි';

  @override
  String get settingsAutoLock => 'ස්වයංක්‍රීය අගුල';

  @override
  String settingsAutoLockAfterMinutes(int minutes) {
    final intl.NumberFormat minutesNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String minutesString = minutesNumberFormat.format(minutes);

    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: 'මිනිත්තු $minutesStringකට පසු',
      one: 'මිනිත්තු 1කට පසු',
    );
    return '$_temp0';
  }

  @override
  String settingsAutoLockAfterSeconds(int seconds) {
    final intl.NumberFormat secondsNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String secondsString = secondsNumberFormat.format(seconds);

    return 'තත්පර $secondsStringකට පසු';
  }

  @override
  String get settingsAutoLockImmediately => 'වහාම';

  @override
  String get settingsBiometrics => 'ඇඟිලි සලකුණ හෝ මුහුණ මගින් අගුළු හරින්න';

  @override
  String get settingsBiometricsUnavailable =>
      'මෙහි භාවිත කිරීමට මෙම දුරකථනයේ ඇඟිලි සලකුණක් හෝ මුහුණක් සකසන්න.';

  @override
  String get settingsChangePin => 'PIN අංකය වෙනස් කරන්න';

  @override
  String get settingsPinChanged => 'PIN අංකය වෙනස් කළා';

  @override
  String get settingsSecurityLabel => 'ආරක්ෂාව';

  @override
  String get settingsBudgetAlerts => 'අයවැය අනතුරු ඇඟවීම්';

  @override
  String get settingsBudgetAlertsDescription => 'අයවැයක 80% සහ 100% දී මට දැනුම් දෙන්න.';

  @override
  String get settingsBudgetAlertsPermissionDenied =>
      'මෙම යෙදුම සඳහා දැනුම්දීම් අක්‍රියයි. අයවැය අනතුරු ඇඟවීම් ලබා ගැනීමට පද්ධති සැකසීම්වලින් ඒවාට ඉඩ දෙන්න.';

  @override
  String get settingsCurrency => 'මුදල් ඒකකය';

  @override
  String get settingsCurrencyLocked =>
      'යෙදුම සකසන විට තෝරා ගත්තා. ඔබේ සියලු මුදල් එකම මුදල් ඒකකයක පවතින පරිදි එය වෙනස් කළ නොහැක.';

  @override
  String settingsCurrencyValue(String code, String symbol) {
    return '$code ($symbol)';
  }

  @override
  String get settingsLanguageChoose => 'භාෂාවක් තෝරන්න';

  @override
  String get settingsLanguageDevice => 'උපාංගයේ භාෂාව';

  @override
  String get settingsLanguageLabel => 'භාෂාව';

  @override
  String get settingsLogout => 'ඉවත් වන්න';

  @override
  String get settingsLogoutAnyway => 'කෙසේ වෙතත් ඉවත් වන්න';

  @override
  String get settingsLogoutConfirmMessage =>
      'මෙම උපාංගයේ යෙදුම භාවිත කිරීමට ඔබට නැවත පුරනය වීමට සිදු වේ.';

  @override
  String get settingsLogoutConfirmTitle => 'ඉවත් වන්නද?';

  @override
  String settingsLogoutPendingMessage(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'මෙම උපාංගයේ වෙනස්කම් $countStringක් තවම සමමුහුර්ත වී නැත. ඔබ දැන් ඉවත් වුවහොත්, ඒවා නැති වේ.',
      one: 'මෙම උපාංගයේ එක් වෙනස්කමක් තවම සමමුහුර්ත වී නැත. ඔබ දැන් ඉවත් වුවහොත්, එය නැති වේ.',
    );
    return '$_temp0';
  }

  @override
  String get settingsManageLabel => 'කළමනාකරණය';

  @override
  String get settingsNotificationsLabel => 'දැනුම්දීම්';

  @override
  String get settingsProfileLabel => 'පැතිකඩ';

  @override
  String get settingsSyncLabel => 'සමමුහුර්තය';

  @override
  String get settingsThemeDark => 'අඳුරු';

  @override
  String get settingsThemeLabel => 'තේමාව';

  @override
  String get settingsThemeLight => 'ආලෝකමත්';

  @override
  String get settingsThemeSystem => 'පද්ධතිය';

  @override
  String get settingsTitle => 'සැකසීම්';

  @override
  String get syncNow => 'දැන් සමමුහුර්ත කරන්න';

  @override
  String get syncStatusError => 'සමමුහුර්ත කළ නොහැකි විය. අපි දිගටම උත්සාහ කරන්නෙමු.';

  @override
  String get syncStatusOffline => 'නොබැඳි. ඔබ නැවත සබැඳි වූ විට වෙනස්කම් සමමුහුර්ත වේ.';

  @override
  String syncStatusPending(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'වෙනස්කම් $countStringක් සමමුහුර්ත වීමට රැඳී ඇත',
      one: 'එක් වෙනස්කමක් සමමුහුර්ත වීමට රැඳී ඇත',
    );
    return '$_temp0';
  }

  @override
  String get syncStatusSynced => 'සියලු වෙනස්කම් සමමුහුර්තයි';

  @override
  String get syncStatusSyncing => 'සමමුහුර්ත වෙමින්…';

  @override
  String get transactionDeleted => 'ගනුදෙනුව මැකුවා';

  @override
  String get transactionDetailNoteLabel => 'සටහන';

  @override
  String get transactionDetailTitle => 'ගනුදෙනුව';

  @override
  String get transactionFormAmountLabel => 'මුදල';

  @override
  String get transactionFormCategoryLabel => 'ප්‍රවර්ගය';

  @override
  String get transactionFormDateLabel => 'දිනය';

  @override
  String get transactionFormEditTitle => 'ගනුදෙනුව සංස්කරණය කරන්න';

  @override
  String get transactionFormNewTitle => 'නව ගනුදෙනුව';

  @override
  String get transactionFormNoCategories =>
      'තවම මෙම වර්ගයේ ප්‍රවර්ග නැත. සැකසීම් → ප්‍රවර්ග තුළ එකක් එක් කරන්න.';

  @override
  String get transactionFormNoteLabel => 'සටහන (අත්‍යවශ්‍ය නොවේ)';

  @override
  String get transactionNotFoundMessage => 'එය මෙම හෝ වෙනත් උපාංගයකින් මකා දමා තිබිය හැක.';

  @override
  String get transactionNotFoundTitle => 'ගනුදෙනුව හමු නොවීය';

  @override
  String get transactionsAdd => 'ගනුදෙනුවක් එක් කරන්න';

  @override
  String get transactionsEmptyMessage => 'ඔබේ පළමු එක එක් කිරීමට + තට්ටු කරන්න.';

  @override
  String get transactionsClearFilters => 'පෙරහන් ඉවත් කරන්න';

  @override
  String transactionsEmptyTitle(String month) {
    return '$month තුළ ගනුදෙනු නැත';
  }

  @override
  String get transactionsFilterAllCategories => 'සියලු ප්‍රවර්ග';

  @override
  String get transactionsFilterCategoryTitle => 'ප්‍රවර්ගය අනුව පෙරහන් කරන්න';

  @override
  String get transactionsFilterClearCategory => 'ප්‍රවර්ග පෙරහන ඉවත් කරන්න';

  @override
  String get transactionsNoMatchesMessage => 'වෙනත් මාසයක් උත්සාහ කරන්න හෝ පෙරහන් ඉවත් කරන්න.';

  @override
  String get transactionsNoMatchesTitle => 'ගැළපෙන ගනුදෙනු නැත';

  @override
  String get transactionsTitle => 'ගනුදෙනු';
}
