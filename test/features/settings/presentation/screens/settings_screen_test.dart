import 'package:expense_tracker/core/db/database_provider.dart';
import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/l10n/generated/app_localizations_en.dart';
import 'package:expense_tracker/features/auth/data/logout_repository_provider.dart';
import 'package:expense_tracker/features/auth/domain/logout_repository.dart';
import 'package:expense_tracker/features/settings/presentation/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/pump_app.dart';
import '../../../../helpers/test_database.dart';

class _MockLogoutRepository extends Mock implements LogoutRepository {}

void main() {
  final l10n = AppLocalizationsEn();

  late _MockLogoutRepository repository;

  setUp(() {
    repository = _MockLogoutRepository();
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
      ],
    );
    await tester.pumpAndSettle();
  }

  Finder dialog() => find.byType(AlertDialog);
  Finder inDialog(String text) => find.descendant(of: dialog(), matching: find.text(text));

  Future<void> tapLogout(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(FilledButton, l10n.settingsLogout));
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
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text(l10n.settingsAccountLabel), findsOneWidget);
    expect(find.text(l10n.settingsManageLabel), findsOneWidget);
    expect(find.text(l10n.categoriesTitle), findsOneWidget);
    expect(find.widgetWithText(FilledButton, l10n.settingsLogout), findsOneWidget);
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
}
