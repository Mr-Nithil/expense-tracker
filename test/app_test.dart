import 'package:drift/drift.dart' show Value;
import 'package:expense_tracker/app.dart';
import 'package:expense_tracker/core/db/app_database.dart';
import 'package:expense_tracker/core/db/database_provider.dart';
import 'package:expense_tracker/core/db/tables/sync_columns.dart';
import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/l10n/generated/app_localizations_en.dart';
import 'package:expense_tracker/core/services/secure_storage_service.dart';
import 'package:expense_tracker/core/utils/clock.dart';
import 'package:expense_tracker/features/auth/domain/entities/auth_user.dart';
import 'package:expense_tracker/features/categories/domain/services/default_categories.dart';
import 'package:expense_tracker/features/categories/presentation/providers/default_categories_seeder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'helpers/fake_auth_repository.dart';
import 'helpers/fake_connectivity_service.dart';
import 'helpers/fake_sync_gateway.dart';
import 'helpers/test_database.dart';

class _MockSecureStorage extends Mock implements SecureStorageService {}

void main() {
  final l10n = AppLocalizationsEn();

  /// Pumps the whole app. With [onboarded], [testUser] already has a profile with a currency.
  Future<ProviderContainer> pumpApp(
    WidgetTester tester, {
    FakeAuthRepository? auth,
    bool onboarded = true,
  }) async {
    final db = createTestDatabase();
    if (onboarded) {
      final now = DateTime.utc(2026, 10, 10);
      await tester.runAsync(
        () => db.profilesDao.insertProfile(
          ProfilesCompanion.insert(
            id: testUser.id,
            userId: testUser.id,
            createdAt: now,
            updatedAt: now,
            currencyCode: const Value('USD'),
          ),
        ),
      );
    }
    final secureStorage = _MockSecureStorage();
    when(secureStorage.deleteAll).thenAnswer((_) async {});
    final container = createTestContainer(
      db: db,
      overrides: [
        // A fixed date, so "Today", default dates and month labels don't depend on when tests run.
        clockProvider.overrideWithValue(FixedClock(DateTime(2026, 10, 11, 9))),
        (auth ?? FakeAuthRepository()).providerOverride,
        // No network in tests: sync fails like it would offline.
        FakeSyncGateway().providerOverride,
        FakeConnectivityService().providerOverride,
        secureStorageServiceProvider.overrideWithValue(secureStorage),
      ],
    );
    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const App()));
    await tester.pumpAndSettle();
    return container;
  }

  NavigationBar navBar(WidgetTester tester) => tester.widget(find.byType(NavigationBar));

  testWidgets('opens on the dashboard tab', (tester) async {
    await pumpApp(tester);

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(navBar(tester).selectedIndex, 0);
    expect(find.widgetWithText(AppBar, l10n.dashboardTitle), findsOneWidget);
  });

  testWidgets('bottom navigation switches between the four tabs', (tester) async {
    await pumpApp(tester);

    final tabs = [
      l10n.transactionsTitle,
      l10n.budgetTitle,
      l10n.settingsTitle,
      l10n.dashboardTitle,
    ];
    for (final (index, title) in tabs.indexed) {
      await tester.tap(find.descendant(of: find.byType(NavigationBar), matching: find.text(title)));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, title), findsOneWidget);
      expect(navBar(tester).selectedIndex, (index + 1) % 4);
    }
  });

  testWidgets('opens on login when there is no stored session', (tester) async {
    await pumpApp(tester, auth: FakeAuthRepository(currentUser: null));

    expect(find.widgetWithText(AppBar, l10n.authLoginTitle), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('opens offline on the dashboard with a restored session', (tester) async {
    // Restored session from local storage; the first token refresh fails because there is no
    // network, which Supabase reports as a stream error (not a sign-out).
    final auth = FakeAuthRepository();
    await pumpApp(tester, auth: auth);

    auth.emitError(Exception('AuthRetryableFetchException: no network'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, l10n.dashboardTitle), findsOneWidget);
    expect(find.widgetWithText(AppBar, l10n.authLoginTitle), findsNothing);
  });

  testWidgets('signing in through the login form reaches the dashboard', (tester) async {
    await pumpApp(tester, auth: FakeAuthRepository(currentUser: null));

    await tester.enterText(
      find.widgetWithText(TextFormField, l10n.authEmailLabel),
      testUser.email,
    );
    await tester.enterText(find.widgetWithText(TextFormField, l10n.authPasswordLabel), 'secret-pw');
    await tester.tap(find.widgetWithText(FilledButton, l10n.authLoginSubmit));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, l10n.dashboardTitle), findsOneWidget);
  });

  testWidgets('a different user signing in gets their own onboarding state', (tester) async {
    final auth = FakeAuthRepository();
    await pumpApp(tester, auth: auth);
    expect(find.widgetWithText(AppBar, l10n.dashboardTitle), findsOneWidget);

    auth.emit(null);
    await tester.pumpAndSettle();
    // User B has no local profile yet, unlike the onboarded testUser.
    auth.emit(const AuthUser(id: 'user-2', email: 'b@example.com'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, l10n.onboardingTitle), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets(
    'after an involuntary sign-out, a different user does not inherit the local data',
    (tester) async {
      final auth = FakeAuthRepository();
      final container = await pumpApp(tester, auth: auth);
      final dao = container.read(databaseProvider).profilesDao;

      // Supabase signs user A out by itself: nothing is cleared yet.
      auth.emit(null);
      await tester.pumpAndSettle();
      expect(await tester.runAsync(() => dao.getProfile(testUser.id)), isNotNull);

      auth.emit(const AuthUser(id: 'user-2', email: 'b@example.com'));
      await tester.pumpAndSettle();

      expect(await tester.runAsync(() => dao.getProfile(testUser.id)), isNull);
    },
  );

  testWidgets('the same user signing back in keeps their local data', (tester) async {
    final auth = FakeAuthRepository();
    final container = await pumpApp(tester, auth: auth);

    auth.emit(null);
    await tester.pumpAndSettle();
    auth.emit(testUser);
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, l10n.dashboardTitle), findsOneWidget);
    final profile = await tester.runAsync(
      () => container.read(databaseProvider).profilesDao.getProfile(testUser.id),
    );
    expect(profile, isNotNull);
  });

  group('password reset link', () {
    Future<FakeAuthRepository> openResetLink(WidgetTester tester) async {
      final auth = FakeAuthRepository();
      await pumpApp(tester, auth: auth);
      auth.emitRecovery(testUser);
      await tester.pumpAndSettle();
      return auth;
    }

    testWidgets('lands on reset-password instead of the dashboard', (tester) async {
      await openResetLink(tester);

      expect(find.widgetWithText(AppBar, l10n.authResetPasswordTitle), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    });

    testWidgets('saving the new password enters the app', (tester) async {
      await openResetLink(tester);

      await tester.enterText(
        find.widgetWithText(TextFormField, l10n.authNewPasswordLabel),
        'new-password',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, l10n.authConfirmPasswordLabel),
        'new-password',
      );
      await tester.tap(find.widgetWithText(FilledButton, l10n.authResetPasswordSubmit));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(AppBar, l10n.dashboardTitle), findsOneWidget);
    });

    testWidgets('cancel signs out to login', (tester) async {
      await openResetLink(tester);

      await tester.tap(find.text(l10n.authResetPasswordCancel));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(AppBar, l10n.authLoginTitle), findsOneWidget);
    });
  });

  group('failed email links', () {
    testWidgets('an expired link shows a message on the login screen', (tester) async {
      final auth = FakeAuthRepository(currentUser: null);
      await pumpApp(tester, auth: auth);

      auth.emitLinkError(const AuthFailure('link', reason: AuthFailureReason.linkExpired));
      await tester.pumpAndSettle();

      expect(find.text(l10n.errorAuthLinkExpired), findsOneWidget);
      expect(find.widgetWithText(AppBar, l10n.authLoginTitle), findsOneWidget);
    });

    testWidgets('an invalid link inside the app shows a message and stays put', (tester) async {
      final auth = FakeAuthRepository();
      await pumpApp(tester, auth: auth);

      auth.emitLinkError(const AuthFailure('link', reason: AuthFailureReason.linkInvalid));
      await tester.pumpAndSettle();

      expect(find.text(l10n.errorAuthLinkInvalid), findsOneWidget);
      expect(find.widgetWithText(AppBar, l10n.dashboardTitle), findsOneWidget);
    });
  });

  testWidgets('a new user goes through onboarding, then reaches the dashboard', (tester) async {
    final container = await pumpApp(tester, onboarded: false);

    expect(find.widgetWithText(AppBar, l10n.onboardingTitle), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    await tester.tap(find.text(l10n.onboardingContinue));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, l10n.dashboardTitle), findsOneWidget);
    final categories = await tester.runAsync(
      () => container.read(databaseProvider).categoriesDao.watchActive(testUser.id).first,
    );
    expect(categories, hasLength(DefaultCategories.all.length));
  });

  testWidgets('login links to sign-up', (tester) async {
    await pumpApp(tester, auth: FakeAuthRepository(currentUser: null));

    await tester.tap(find.text(l10n.authLoginGoToSignUp));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, l10n.authSignUpTitle), findsOneWidget);
  });

  testWidgets('login links to forgot-password with the typed email', (tester) async {
    await pumpApp(tester, auth: FakeAuthRepository(currentUser: null));

    await tester.enterText(find.widgetWithText(TextFormField, l10n.authEmailLabel), 'me@x.io');
    await tester.tap(find.text(l10n.authLoginForgotPassword));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, l10n.authForgotPasswordTitle), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'me@x.io'), findsOneWidget);
  });

  testWidgets('signing out redirects to login, signing in returns to the app', (tester) async {
    final auth = FakeAuthRepository();
    await pumpApp(tester, auth: auth);

    auth.emit(null);
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, l10n.authLoginTitle), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    auth.emit(testUser);
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.widgetWithText(AppBar, l10n.dashboardTitle), findsOneWidget);
  });

  testWidgets('logging out from settings clears local data and lands on login', (tester) async {
    final container = await pumpApp(tester);

    await tester.tap(
      find.descendant(of: find.byType(NavigationBar), matching: find.text(l10n.settingsTitle)),
    );
    await tester.pumpAndSettle();
    final logout = find.widgetWithText(FilledButton, l10n.settingsLogout);
    // Settings is taller than the test screen: build the button, then scroll it fully into view
    // (clear of the navigation bar).
    await tester.scrollUntilVisible(logout, 200);
    await tester.ensureVisible(logout);
    await tester.pumpAndSettle();
    await tester.tap(logout);
    await tester.pumpAndSettle();
    // The seeded profile has never synced, so the real pending count (1) triggers the warning.
    final dialog = find.byType(AlertDialog);
    expect(
      find.descendant(of: dialog, matching: find.text(l10n.settingsLogoutPendingMessage(1))),
      findsOneWidget,
    );
    await tester.tap(find.descendant(of: dialog, matching: find.text(l10n.settingsLogoutAnyway)));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, l10n.authLoginTitle), findsOneWidget);
    final profile = await tester.runAsync(
      () => container.read(databaseProvider).profilesDao.getProfile(testUser.id),
    );
    expect(profile, isNull);
  });

  testWidgets('settings opens the categories screen with the seeded defaults', (tester) async {
    final container = await pumpApp(tester);
    await tester.runAsync(() => container.read(defaultCategoriesSeederProvider).seed());

    await tester.tap(
      find.descendant(of: find.byType(NavigationBar), matching: find.text(l10n.settingsTitle)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.categoriesTitle));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, l10n.categoriesTitle), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text(l10n.categoryDefaultFood), findsOneWidget);

    await tester.tap(find.text(l10n.commonIncome));
    await tester.pumpAndSettle();
    expect(find.text(l10n.categoryDefaultSalary), findsOneWidget);
  });

  testWidgets('adding a category from the categories screen saves and lists it', (tester) async {
    await pumpApp(tester);
    await tester.tap(
      find.descendant(of: find.byType(NavigationBar), matching: find.text(l10n.settingsTitle)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.categoriesTitle));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip(l10n.categoriesAdd));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, l10n.categoryFormNameLabel),
      'Coffee',
    );
    await tester.ensureVisible(find.text(l10n.commonSave));
    await tester.tap(find.text(l10n.commonSave));
    await tester.pumpAndSettle();

    expect(find.text(l10n.categoryFormNewTitle), findsNothing);
    expect(find.text('Coffee'), findsOneWidget);
  });

  testWidgets('archiving a category hides it but keeps it readable', (tester) async {
    final container = await pumpApp(tester);
    await tester.runAsync(() => container.read(defaultCategoriesSeederProvider).seed());
    await tester.tap(
      find.descendant(of: find.byType(NavigationBar), matching: find.text(l10n.settingsTitle)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.categoriesTitle));
    await tester.pumpAndSettle();

    await tester.tap(find.text(l10n.categoryDefaultFood));
    await tester.pumpAndSettle();
    final archive = find.widgetWithText(TextButton, l10n.categoryFormArchive);
    await tester.ensureVisible(archive);
    await tester.tap(archive);
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(of: find.byType(AlertDialog), matching: find.text(l10n.categoryFormArchive)),
    );
    await tester.pumpAndSettle();

    expect(find.text(l10n.categoryFormEditTitle), findsNothing);
    expect(find.text(l10n.categoryDefaultFood), findsNothing);
    final row = await tester.runAsync(
      () => container
          .read(databaseProvider)
          .categoriesDao
          .getById(testUser.id, DefaultCategories.idFor(testUser.id, 'food')),
    );
    expect(row?.deletedAt, isNotNull);
  });

  testWidgets('adding a transaction from the transactions tab saves it', (tester) async {
    final container = await pumpApp(tester);
    await tester.runAsync(() => container.read(defaultCategoriesSeederProvider).seed());

    await tester.tap(
      find.descendant(of: find.byType(NavigationBar), matching: find.text(l10n.transactionsTitle)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip(l10n.transactionsAdd));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, l10n.transactionFormAmountLabel),
      '12.50',
    );
    await tester.tap(find.text(l10n.categoryDefaultFood));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text(l10n.commonSave));
    await tester.tap(find.text(l10n.commonSave));
    await tester.pumpAndSettle();

    expect(find.text(l10n.transactionFormNewTitle), findsNothing);
    final db = container.read(databaseProvider);
    final rows = await tester.runAsync(() => db.select(db.transactions).get());
    expect(rows, hasLength(1));
    expect(rows!.single.amountMinor, 1250);
    expect(rows.single.type, 'expense');
    expect(rows.single.categoryId, DefaultCategories.idFor(testUser.id, 'food'));

    // The server is unreachable in tests: the indicator says offline, not synced.
    expect(find.byTooltip(l10n.syncStatusOffline), findsOneWidget);

    // The list follows the database: no manual refresh needed.
    expect(find.text(l10n.commonToday), findsOneWidget);
    expect(find.text(r'-$12.50'), findsWidgets);
    expect(find.text(l10n.categoryDefaultFood), findsOneWidget);

    // Month filter: the previous month is empty, the current one shows it again.
    await tester.tap(find.byTooltip(l10n.commonPreviousMonth));
    await tester.pumpAndSettle();
    expect(find.text(l10n.transactionsEmptyTitle('September 2026')), findsOneWidget);
    await tester.tap(find.byTooltip(l10n.commonNextMonth));
    await tester.pumpAndSettle();
    expect(find.text(l10n.categoryDefaultFood), findsOneWidget);

    // Swipe to delete (soft), then Undo restores it.
    await tester.fling(find.text(l10n.categoryDefaultFood), const Offset(-600, 0), 1000);
    await tester.pumpAndSettle();
    expect(find.text(l10n.categoryDefaultFood), findsNothing);
    final deleted = await tester.runAsync(() => db.select(db.transactions).getSingle());
    expect(deleted?.deletedAt, isNotNull);

    await tester.tap(find.text(l10n.commonUndo));
    await tester.pumpAndSettle();
    expect(find.text(l10n.categoryDefaultFood), findsOneWidget);
    final restored = await tester.runAsync(() => db.select(db.transactions).getSingle());
    expect(restored?.deletedAt, isNull);

    // Detail page: tap the row, delete from there, then undo from the list.
    await tester.tap(find.text(l10n.categoryDefaultFood));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, l10n.transactionDetailTitle), findsOneWidget);
    expect(find.text(r'-$12.50'), findsOneWidget);
    await tester.tap(find.byTooltip(l10n.commonDelete));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, l10n.transactionsTitle), findsOneWidget);
    expect(find.text(l10n.transactionDeleted), findsOneWidget);
    expect(find.text(l10n.categoryDefaultFood), findsNothing);
    await tester.tap(find.text(l10n.commonUndo));
    await tester.pumpAndSettle();
    expect(find.text(l10n.categoryDefaultFood), findsOneWidget);
  });

  testWidgets('theme picker in settings switches to dark mode and saves it on the profile', (
    tester,
  ) async {
    final container = await pumpApp(tester);

    await tester.tap(
      find.descendant(of: find.byType(NavigationBar), matching: find.text(l10n.settingsTitle)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.settingsThemeDark));
    await tester.pumpAndSettle();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
    // Stored on the profile (synced), not only on this device.
    final profile = await tester.runAsync(
      () => container.read(databaseProvider).profilesDao.getProfile(testUser.id),
    );
    expect(profile?.themeMode, 'dark');
    expect(profile?.syncStatus, SyncStatus.pending);
  });
}
