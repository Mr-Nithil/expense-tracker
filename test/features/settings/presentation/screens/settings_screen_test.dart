import 'package:expense_tracker/core/db/database_provider.dart';
import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/l10n/generated/app_localizations_en.dart';
import 'package:expense_tracker/core/sync/sync_status.dart';
import 'package:expense_tracker/features/auth/data/logout_repository_provider.dart';
import 'package:expense_tracker/features/auth/domain/logout_repository.dart';
import 'package:expense_tracker/features/profile/data/profile_repository_provider.dart';
import 'package:expense_tracker/features/profile/domain/entities/profile.dart';
import 'package:expense_tracker/features/profile/domain/profile_repository.dart';
import 'package:expense_tracker/features/settings/presentation/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fake_notification_service.dart';
import '../../../../helpers/fake_sync_trigger.dart';
import '../../../../helpers/pump_app.dart';
import '../../../../helpers/test_database.dart';

class _MockLogoutRepository extends Mock implements LogoutRepository {}

class _MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  setUpAll(() => registerFallbackValue(AppThemeMode.system));

  final l10n = AppLocalizationsEn();

  late _MockLogoutRepository repository;
  late FakeSyncTrigger trigger;
  late _MockProfileRepository profiles;
  var syncInfo = const SyncStatusInfo(SyncIndicator.synced);

  setUp(() {
    repository = _MockLogoutRepository();
    trigger = FakeSyncTrigger();
    profiles = _MockProfileRepository();
    when(() => profiles.setThemeMode(any())).thenAnswer(
      (_) async => const Result.success(Profile(id: 'u1', themeMode: AppThemeMode.dark)),
    );
    syncInfo = const SyncStatusInfo(SyncIndicator.synced);
    when(() => repository.logout()).thenAnswer((_) async => Result.ok);
  });

  Future<void> pumpSettings(WidgetTester tester, {int pending = 0}) async {
    when(
      () => repository.pendingChangesCount(),
    ).thenAnswer((_) async => Result.success(pending));
    await tester.pumpApp(
      const SettingsScreen(),
      overrides: [
        databaseProvider.overrideWithValue(createTestDatabase()),
        logoutRepositoryProvider.overrideWithValue(repository),
        syncStatusProvider.overrideWith((ref) => Stream.value(syncInfo)),
        trigger.providerOverride,
        profileRepositoryProvider.overrideWithValue(profiles),
      ],
    );
    await tester.pumpAndSettle();
  }

  Finder dialog() => find.byType(AlertDialog);
  Finder inDialog(String text) => find.descendant(of: dialog(), matching: find.text(text));

  /// Settings is taller than the test screen: build [finder] and scroll it fully into view.
  Future<void> reveal(WidgetTester tester, Finder finder) async {
    await tester.scrollUntilVisible(finder, 200);
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
  }

  Future<void> tapLogout(WidgetTester tester) async {
    final logout = find.widgetWithText(FilledButton, l10n.settingsLogout);
    await reveal(tester, logout);
    await tester.tap(logout);
    await tester.pumpAndSettle();
  }

  testWidgetsBothThemes('shows the account section', (tester, brightness) async {
    when(() => repository.pendingChangesCount()).thenAnswer((_) async => const Result.success(0));
    await tester.pumpApp(
      const SettingsScreen(),
      brightness: brightness,
      overrides: [
        databaseProvider.overrideWithValue(createTestDatabase()),
        logoutRepositoryProvider.overrideWithValue(repository),
        syncStatusProvider.overrideWith((ref) => Stream.value(syncInfo)),
        trigger.providerOverride,
        profileRepositoryProvider.overrideWithValue(profiles),
      ],
    );
    await tester.pumpAndSettle();

    await reveal(tester, find.text(l10n.settingsManageLabel));
    expect(find.text(l10n.categoriesTitle), findsOneWidget);
    await reveal(tester, find.widgetWithText(FilledButton, l10n.settingsLogout));
    expect(find.text(l10n.settingsAccountLabel), findsOneWidget);
  });

  testWidgets('with nothing pending, asks a plain confirmation and logs out', (tester) async {
    await pumpSettings(tester);

    await tapLogout(tester);
    expect(inDialog(l10n.settingsLogoutConfirmMessage), findsOneWidget);

    await tester.tap(inDialog(l10n.settingsLogout));
    await tester.pumpAndSettle();

    verify(() => repository.logout()).called(1);
  });

  testWidgets('with pending changes, warns that they will be lost', (tester) async {
    await pumpSettings(tester, pending: 3);

    await tapLogout(tester);

    expect(inDialog(l10n.settingsLogoutPendingMessage(3)), findsOneWidget);
    await tester.tap(inDialog(l10n.settingsLogoutAnyway));
    await tester.pumpAndSettle();

    verify(() => repository.logout()).called(1);
  });

  testWidgets('cancel keeps the user signed in', (tester) async {
    await pumpSettings(tester, pending: 1);

    await tapLogout(tester);
    await tester.tap(inDialog(l10n.commonCancel));
    await tester.pumpAndSettle();

    expect(dialog(), findsNothing);
    verifyNever(() => repository.logout());
  });

  testWidgets('if the pending count fails, falls back to the plain confirmation', (tester) async {
    await pumpSettings(tester);
    when(
      () => repository.pendingChangesCount(),
    ).thenAnswer((_) async => const Result.failure(StorageFailure('db')));

    await tapLogout(tester);
    expect(inDialog(l10n.settingsLogoutConfirmMessage), findsOneWidget);

    await tester.tap(inDialog(l10n.settingsLogout));
    await tester.pumpAndSettle();
    verify(() => repository.logout()).called(1);
  });

  group('sync section', () {
    testWidgets('shows the state as a sentence', (tester) async {
      syncInfo = const SyncStatusInfo(SyncIndicator.pending, pendingCount: 3);
      await pumpSettings(tester);

      await reveal(tester, find.text(l10n.syncStatusPending(3)));
      expect(find.text(l10n.settingsSyncLabel), findsOneWidget);
      expect(find.text(l10n.syncStatusPending(3)), findsOneWidget);
    });

    testWidgets('Sync now syncs', (tester) async {
      await pumpSettings(tester);

      await reveal(tester, find.text(l10n.syncNow));
      await tester.tap(find.text(l10n.syncNow));
      await tester.pumpAndSettle();

      expect(trigger.immediate, 1);
    });
  });

  group('theme', () {
    testWidgets('choosing Dark saves it on the profile', (tester) async {
      await pumpSettings(tester);

      await tester.tap(find.text(l10n.settingsThemeDark));
      await tester.pumpAndSettle();

      verify(() => profiles.setThemeMode(AppThemeMode.dark)).called(1);
    });

    testWidgets('a failed save says why', (tester) async {
      when(
        () => profiles.setThemeMode(any()),
      ).thenAnswer((_) async => const Result.failure(StorageFailure('db')));
      await pumpSettings(tester);

      await tester.tap(find.text(l10n.settingsThemeDark));
      await tester.pumpAndSettle();

      expect(find.text(l10n.errorStorage), findsOneWidget);
    });
  });

  group('budget alerts switch', () {
    late FakeNotificationService notifications;

    Future<void> pumpWithAlerts(WidgetTester tester) async {
      notifications = FakeNotificationService();
      when(() => repository.pendingChangesCount()).thenAnswer((_) async => const Result.success(0));
      await tester.pumpApp(
        const SettingsScreen(),
        overrides: [
          databaseProvider.overrideWithValue(createTestDatabase()),
          logoutRepositoryProvider.overrideWithValue(repository),
          syncStatusProvider.overrideWith((ref) => Stream.value(syncInfo)),
          trigger.providerOverride,
          profileRepositoryProvider.overrideWithValue(profiles),
          notifications.providerOverride,
        ],
      );
      await tester.pumpAndSettle();
    }

    Finder alertsSwitch() => find.widgetWithText(SwitchListTile, l10n.settingsBudgetAlerts);

    Future<void> flip(WidgetTester tester) async {
      await tester.tap(alertsSwitch());
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pumpAndSettle();
    }

    testWidgets('is off until turned on; turning on asks for permission', (tester) async {
      await pumpWithAlerts(tester);
      expect(tester.widget<SwitchListTile>(alertsSwitch()).value, isFalse);

      await flip(tester);

      expect(tester.widget<SwitchListTile>(alertsSwitch()).value, isTrue);
      expect(notifications.permissionRequests, 1);
      expect(find.text(l10n.settingsBudgetAlertsPermissionDenied), findsNothing);
    });

    testWidgets('a refused permission is explained; the choice stays saved', (tester) async {
      await pumpWithAlerts(tester);
      notifications.permissionGranted = false;

      await flip(tester);

      expect(find.text(l10n.settingsBudgetAlertsPermissionDenied), findsOneWidget);
      expect(tester.widget<SwitchListTile>(alertsSwitch()).value, isTrue);
    });
  });
}
