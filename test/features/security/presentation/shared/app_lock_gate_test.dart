import 'dart:async';
import 'dart:convert';

import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/l10n/generated/app_localizations.dart';
import 'package:expense_tracker/core/l10n/generated/app_localizations_en.dart';
import 'package:expense_tracker/core/services/biometric_service.dart';
import 'package:expense_tracker/core/session/session.dart';
import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/core/utils/clock.dart';
import 'package:expense_tracker/features/security/data/pin_hasher.dart';
import 'package:expense_tracker/features/security/data/security_repository_impl.dart';
import 'package:expense_tracker/features/security/domain/entities/lock_settings.dart';
import 'package:expense_tracker/features/security/presentation/providers/app_lock_controller.dart';
import 'package:expense_tracker/features/security/presentation/providers/lock_settings_controller.dart';
import 'package:expense_tracker/features/security/presentation/screens/lock_screen.dart';
import 'package:expense_tracker/features/security/presentation/shared/app_lock_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../../helpers/accessibility.dart';
import '../../../../helpers/fake_auth_repository.dart';
import '../../../../helpers/fake_biometric_service.dart';
import '../../../../helpers/fake_secure_storage.dart';
import '../../../../helpers/test_database.dart';

void main() {
  final l10n = AppLocalizationsEn();
  const pin = '2468';

  late FakeSecureStorage storage;
  late FakeBiometricService biometrics;
  late FakeAuthRepository auth;
  late ProviderContainer container;

  ProviderContainer newContainer() => createTestContainer(
    overrides: [
      storage.providerOverride,
      fastSecurityRepositoryOverride(storage),
      biometrics.providerOverride,
      auth.providerOverride,
      clockProvider.overrideWithValue(FixedClock(DateTime(2026, 10, 12))),
    ],
  );

  /// Sets the lock up in an earlier "session", so the app starts locked like after a restart.
  Future<void> seed({bool withBiometrics = false, LockTimeout? timeout}) async {
    final earlier = newContainer();
    earlier.read(sessionProvider.notifier).set(const SessionUser(userId: 'u1'));
    final settings = earlier.read(lockSettingsControllerProvider.notifier);
    await earlier.read(lockSettingsControllerProvider.future);
    await settings.setPin(pin);
    if (withBiometrics) await settings.setBiometricsEnabled(enabled: true);
    if (timeout != null) await settings.setTimeout(timeout);
    earlier.dispose();
  }

  setUp(() {
    storage = FakeSecureStorage();
    biometrics = FakeBiometricService();
    auth = FakeAuthRepository();
  });

  /// The gate around a page with a text field, like `App` around the router.
  Future<void> pump(WidgetTester tester, {Brightness brightness = Brightness.light}) async {
    container = newContainer();
    container.read(sessionProvider.notifier).set(const SessionUser(userId: 'u1'));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: brightness == Brightness.light ? AppTheme.light() : AppTheme.dark(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => AppLockGate(child: child!),
          home: const Scaffold(body: TextField(key: Key('app-field'))),
        ),
      ),
    );
    await tester.runAsync(() => container.read(lockSettingsControllerProvider.future));
    await tester.pumpAndSettle();
  }

  Future<void> type(WidgetTester tester, String digits) async {
    for (final d in digits.split('')) {
      await tester.tap(find.descendant(of: find.byType(LockScreen), matching: find.text(d)).last);
      await tester.pump();
    }
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pumpAndSettle();
  }

  AppLockStatus status() => container.read(appLockControllerProvider);

  testWidgets('without a PIN the app is not covered', (tester) async {
    await pump(tester);

    expect(find.byType(LockScreen), findsNothing);
    expect(status(), AppLockStatus.unlocked);
  });

  testWidgets('a start with a PIN shows the lock; the right PIN opens the app', (tester) async {
    await seed();
    await pump(tester);

    expect(find.byType(LockScreen), findsOneWidget);
    expect(find.text(l10n.lockTitle), findsOneWidget);
    // The app underneath is hidden from screen readers.
    expect(
      find.bySemanticsLabel(RegExp('.*')),
      isNot(contains(find.byKey(const Key('app-field')))),
    );

    await type(tester, '1357');
    expect(find.text(l10n.lockWrongPin), findsOneWidget);
    expect(status(), AppLockStatus.locked);

    await type(tester, pin);
    expect(find.byType(LockScreen), findsNothing);
    expect(status(), AppLockStatus.unlocked);
  });

  testWidgets('a 6-digit PIN saved before the 4-digit rule still unlocks', (tester) async {
    const hasher = PinHasher(iterations: 10, inBackground: false);
    storage.values[SecurityRepositoryImpl.storageKey] = jsonEncode({
      'owner': 'u1',
      'pinHash': await hasher.hash('123456'),
      'pinLength': 6,
      'biometrics': false,
      'timeout': 'seconds30',
    });
    await pump(tester);

    expect(find.bySemanticsLabel(l10n.pinProgress(0, 6)), findsOneWidget);
    await type(tester, '123456');
    expect(status(), AppLockStatus.unlocked);
  });

  testWidgets('biometrics are offered right away and unlock', (tester) async {
    await seed(withBiometrics: true);
    await pump(tester);

    expect(biometrics.reasons, [l10n.lockBiometricReason]);
    expect(find.byType(LockScreen), findsNothing);
  });

  testWidgets('a biometric lockout says to use the PIN', (tester) async {
    await seed(withBiometrics: true);
    biometrics.outcome = BiometricOutcome.lockedOut;
    await pump(tester);

    expect(find.text(l10n.lockBiometricLockedOut), findsOneWidget);
    await tester.tap(find.byTooltip(l10n.lockUseBiometrics));
    await tester.pumpAndSettle();
    expect(biometrics.reasons, hasLength(2));
  });

  testWidgets('locking keeps what was on screen underneath', (tester) async {
    await seed(timeout: LockTimeout.immediately);
    await pump(tester);
    await type(tester, pin);
    await tester.enterText(find.byKey(const Key('app-field')), 'half-typed note');

    container.read(appLockControllerProvider.notifier)
      ..handleHidden()
      ..handleShown();
    await tester.pumpAndSettle();
    expect(find.byType(LockScreen), findsOneWidget);

    await type(tester, pin);
    expect(find.text('half-typed note'), findsOneWidget);
  });

  testWidgets('Android back while locked leaves the app instead of popping pages', (tester) async {
    await seed(timeout: LockTimeout.immediately);
    final calls = <String>[];
    final messenger = tester.binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      calls.add(call.method);
      return null;
    });
    addTearDown(() => messenger.setMockMethodCallHandler(SystemChannels.platform, null));
    // Like `App`: a router, with the gate in `builder`.
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: Text('first page')),
          routes: [
            GoRoute(
              path: 'second',
              builder: (_, _) => const Scaffold(body: Text('second page')),
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);
    container = newContainer();
    container.read(sessionProvider.notifier).set(const SessionUser(userId: 'u1'));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => AppLockGate(child: child!),
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await type(tester, pin);
    unawaited(router.push('/second'));
    await tester.pumpAndSettle();
    container.read(appLockControllerProvider.notifier)
      ..handleHidden()
      ..handleShown();
    await tester.pumpAndSettle();

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(calls, contains('SystemNavigator.pop'));
    await type(tester, pin);
    expect(find.text('second page'), findsOneWidget);
  });

  group('Forgot PIN', () {
    Future<void> openRecovery(WidgetTester tester) async {
      await seed();
      await pump(tester);
      await tester.tap(find.text(l10n.lockForgotPin));
      await tester.pumpAndSettle();
    }

    testWidgets('the account password lets the user choose a new PIN', (tester) async {
      await openRecovery(tester);
      expect(find.text(l10n.lockRecoveryMessage(testUser.email)), findsOneWidget);

      await tester.enterText(find.byType(TextField).last, 'secret-password');
      await tester.tap(find.text(l10n.lockRecoverySubmit));
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pumpAndSettle();
      expect(auth.confirmedPasswords, ['secret-password']);
      expect(find.textContaining(l10n.lockRecoveryDone), findsOneWidget);

      Future<void> typeInSheet(String digits) async {
        for (final d in digits.split('')) {
          await tester.tap(find.descendant(of: find.byType(BottomSheet), matching: find.text(d)));
          await tester.pump();
        }
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
        await tester.pumpAndSettle();
      }

      await typeInSheet('1357');
      await typeInSheet('1357');

      expect(status(), AppLockStatus.unlocked);
      expect(find.byType(LockScreen), findsNothing);
      final settings = container.read(lockSettingsControllerProvider.notifier);
      expect((await tester.runAsync(() => settings.verifyPin('1357')))?.valueOrNull, isTrue);
      expect((await tester.runAsync(() => settings.verifyPin(pin)))?.valueOrNull, isFalse);
    });

    testWidgets('can also just turn the lock off', (tester) async {
      await openRecovery(tester);
      await tester.enterText(find.byType(TextField).last, 'secret-password');
      await tester.tap(find.text(l10n.lockRecoverySubmit));
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text(l10n.lockRecoverySkip));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.lockRecoverySkip));
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pumpAndSettle();

      expect(status(), AppLockStatus.unlocked);
      expect(container.read(lockSettingsControllerProvider).value?.pinEnabled, isFalse);
    });

    testWidgets('a wrong password keeps it locked and says why', (tester) async {
      auth.confirmPasswordResult = const Result.failure(
        AuthFailure('bad', reason: AuthFailureReason.invalidCredentials),
      );
      await openRecovery(tester);

      await tester.enterText(find.byType(TextField).last, 'wrong');
      await tester.tap(find.text(l10n.lockRecoverySubmit));
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pumpAndSettle();

      expect(find.text(l10n.errorAuthInvalidCredentials), findsOneWidget);
      expect(status(), AppLockStatus.locked);
    });
  });

  group('accessibility (M9.5)', () {
    for (final brightness in Brightness.values) {
      testWidgets('the lock screen meets the guidelines (${brightness.name})', (tester) async {
        await seed(withBiometrics: true);
        biometrics.outcome = BiometricOutcome.cancelled;
        await pump(tester, brightness: brightness);
        await expectAccessible(tester);
      });
    }

    testWidgets('large text (2x) fits', (tester) async {
      useTextScale(tester, 2);
      await seed();
      await pump(tester);
      await scrollThrough(tester);
    });
  });
}
