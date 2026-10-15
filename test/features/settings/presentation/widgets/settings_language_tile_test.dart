import 'package:drift/drift.dart' show Value;
import 'package:expense_tracker/core/db/app_database.dart';
import 'package:expense_tracker/core/db/tables/sync_columns.dart';
import 'package:expense_tracker/core/l10n/generated/app_localizations.dart';
import 'package:expense_tracker/core/l10n/generated/app_localizations_en.dart';
import 'package:expense_tracker/core/l10n/generated/app_localizations_si.dart';
import 'package:expense_tracker/core/l10n/locale_controller.dart';
import 'package:expense_tracker/core/session/session.dart';
import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/features/settings/presentation/widgets/settings_language_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fake_sync_trigger.dart';
import '../../../../helpers/finders.dart';
import '../../../../helpers/test_database.dart';

void main() {
  const userId = 'u1';
  final en = AppLocalizationsEn();
  final si = AppLocalizationsSi();
  final at = DateTime.utc(2026, 10, 1);

  late AppDatabase db;
  late FakeSyncTrigger trigger;
  late ProviderContainer container;

  setUp(() async {
    db = createTestDatabase();
    trigger = FakeSyncTrigger();
    container = createTestContainer(db: db, syncTrigger: trigger);
    container.read(sessionProvider.notifier).set(const SessionUser(userId: userId));
    await db.profilesDao.insertProfile(
      ProfilesCompanion.insert(
        id: userId,
        userId: userId,
        createdAt: at,
        updatedAt: at,
        currencyCode: const Value('USD'),
        syncStatus: const Value(SyncStatus.synced),
      ),
    );
  });

  Future<ProfileRow?> row() => db.profilesDao.getProfile(userId);

  /// Like `App`: the locale follows `localeControllerProvider`; the device language is English.
  Future<void> pump(WidgetTester tester) async {
    tester.platformDispatcher.localeTestValue = const Locale('en', 'US');
    addTearDown(tester.platformDispatcher.clearLocaleTestValue);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: Consumer(
          builder: (context, ref, _) => MaterialApp(
            theme: AppTheme.light(),
            locale: ref.watch(localeControllerProvider).value,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(body: SettingsLanguageTile()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder inDialog(String text) =>
      find.descendant(of: find.byType(SimpleDialog), matching: findText(text));

  Future<void> choose(WidgetTester tester, String option) async {
    await tester.tap(find.byType(ListTile));
    await tester.pumpAndSettle();
    await tester.tap(inDialog(option));
    await tester.pumpAndSettle();
  }

  testWidgets('without a choice, follows the device and lists every language', (tester) async {
    await pump(tester);

    expect(findText(en.settingsLanguageLabel), findsOneWidget);
    expect(findText(en.settingsLanguageDevice), findsOneWidget);

    await tester.tap(find.byType(ListTile));
    await tester.pumpAndSettle();

    expect(inDialog(en.settingsLanguageChoose), findsOneWidget);
    expect(inDialog(en.settingsLanguageDevice), findsOneWidget);
    expect(inDialog(si.languageNativeName), findsOneWidget);
    // "English" twice: the option and the device language under "Device language".
    expect(inDialog(en.languageNativeName), findsNWidgets(2));
    final device = tester.widget<ListTile>(
      find.ancestor(of: inDialog(en.settingsLanguageDevice), matching: find.byType(ListTile)),
    );
    expect(device.selected, isTrue);
  });

  testWidgets('choosing Sinhala saves it on the profile and switches the app', (tester) async {
    await pump(tester);

    await choose(tester, si.languageNativeName);

    final saved = (await row())!;
    expect(saved.locale, 'si');
    expect(saved.syncStatus, SyncStatus.pending);
    expect(trigger.requests, 1);
    expect(findText(si.settingsLanguageLabel), findsOneWidget);
    expect(findText(si.languageNativeName), findsOneWidget);
  });

  testWidgets('choosing the device language clears the choice', (tester) async {
    await db.profilesDao.updateProfile(userId, const ProfilesCompanion(locale: Value('si')));
    await pump(tester);
    expect(findText(si.settingsLanguageLabel), findsOneWidget);

    await choose(tester, si.settingsLanguageDevice);

    expect((await row())?.locale, isNull);
    expect(findText(en.settingsLanguageLabel), findsOneWidget);
  });

  testWidgets('dismissing or choosing the current language writes nothing', (tester) async {
    await pump(tester);

    await tester.tap(find.byType(ListTile));
    await tester.pumpAndSettle();
    await tester.tapAt(Offset.zero);
    await tester.pumpAndSettle();
    expect(find.byType(SimpleDialog), findsNothing);

    await choose(tester, en.settingsLanguageDevice);

    expect((await row())?.syncStatus, SyncStatus.synced);
    expect(trigger.requests, 0);
  });

  testWidgets('a failed save says why', (tester) async {
    await pump(tester);
    container.read(sessionProvider.notifier).set(null);
    await tester.pumpAndSettle();

    await choose(tester, si.languageNativeName);

    expect(findText(en.errorAuth), findsOneWidget);
  });
}
