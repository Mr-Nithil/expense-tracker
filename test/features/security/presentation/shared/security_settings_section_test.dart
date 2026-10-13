import 'package:expense_tracker/core/l10n/generated/app_localizations_en.dart';
import 'package:expense_tracker/core/services/biometric_service.dart';
import 'package:expense_tracker/core/session/session.dart';
import 'package:expense_tracker/features/security/domain/entities/lock_settings.dart';
import 'package:expense_tracker/features/security/presentation/providers/lock_settings_controller.dart';
import 'package:expense_tracker/features/security/presentation/shared/security_settings_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/accessibility.dart';
import '../../../../helpers/fake_auth_repository.dart';
import '../../../../helpers/fake_biometric_service.dart';
import '../../../../helpers/fake_secure_storage.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  final l10n = AppLocalizationsEn();

  late FakeSecureStorage storage;
  late FakeBiometricService biometrics;
  late ProviderContainer container;

  setUp(() {
    storage = FakeSecureStorage();
    biometrics = FakeBiometricService();
  });

  Future<void> pump(WidgetTester tester, {Brightness brightness = Brightness.light}) async {
    await tester.pumpApp(
      const SingleChildScrollView(child: SecuritySettingsSection()),
      brightness: brightness,
      overrides: [
        storage.providerOverride,
        fastSecurityRepositoryOverride(storage),
        biometrics.providerOverride,
        FakeAuthRepository().providerOverride,
      ],
    );
    container = ProviderScope.containerOf(tester.element(find.byType(SecuritySettingsSection)));
    container.read(sessionProvider.notifier).set(const SessionUser(userId: 'u1'));
    await tester.pumpAndSettle();
  }

  LockSettings? settings() => container.read(lockSettingsControllerProvider).value;
  Finder switchOf(String title) => find.widgetWithText(SwitchListTile, title);

  Future<void> type(WidgetTester tester, String digits) async {
    for (final d in digits.split('')) {
      await tester.tap(find.descendant(of: find.byType(BottomSheet), matching: find.text(d)));
      await tester.pump();
    }
    await tester.pumpAndSettle();
  }

  Future<void> turnOn(WidgetTester tester, String pin) async {
    await tester.tap(switchOf(l10n.settingsAppLock));
    await tester.pumpAndSettle();
    await type(tester, pin);
    await type(tester, pin);
  }

  Future<bool> verify(String pin) async =>
      (await container.read(lockSettingsControllerProvider.notifier).verifyPin(pin)).valueOrNull!;

  testWidgets('off: only the app lock switch', (tester) async {
    await pump(tester);

    expect(find.text(l10n.settingsSecurityLabel), findsOneWidget);
    expect(tester.widget<SwitchListTile>(switchOf(l10n.settingsAppLock)).value, isFalse);
    expect(find.text(l10n.settingsChangePin), findsNothing);
    expect(find.text(l10n.settingsAutoLock), findsNothing);
  });

  testWidgets('turning it on chooses and confirms a PIN', (tester) async {
    await pump(tester);

    await turnOn(tester, '2468');

    expect(find.text(l10n.settingsAppLockOn), findsOneWidget);
    expect(settings()?.pinEnabled, isTrue);
    expect(settings()?.pinLength, 4);
    expect(await tester.runAsync(() => verify('2468')), isTrue);
    expect(find.text(l10n.settingsChangePin), findsOneWidget);
    expect(find.text(l10n.settingsAutoLockAfterSeconds(30)), findsOneWidget);
  });

  testWidgets('a different confirmation starts over', (tester) async {
    await pump(tester);
    await tester.tap(switchOf(l10n.settingsAppLock));
    await tester.pumpAndSettle();
    await type(tester, '1234');

    await type(tester, '4321');

    expect(find.text(l10n.pinMismatch), findsOneWidget);
    expect(find.text(l10n.pinSetTitle), findsOneWidget);
    expect(settings()?.pinEnabled, isFalse);
  });

  testWidgets('turning it off needs the current PIN', (tester) async {
    await pump(tester);
    await turnOn(tester, '1234');

    await tester.tap(switchOf(l10n.settingsAppLock));
    await tester.pumpAndSettle();
    expect(find.text(l10n.pinCurrentTitle), findsOneWidget);
    await type(tester, '9999');
    expect(find.text(l10n.lockWrongPin), findsOneWidget);
    expect(settings()?.pinEnabled, isTrue);

    await type(tester, '1234');
    expect(find.text(l10n.settingsAppLockOff), findsOneWidget);
    expect(settings()?.pinEnabled, isFalse);
  });

  testWidgets('changing the PIN asks for the current one first', (tester) async {
    await pump(tester);
    await turnOn(tester, '1234');

    await tester.tap(find.text(l10n.settingsChangePin));
    await tester.pumpAndSettle();
    await type(tester, '1234');
    await type(tester, '5678');
    await type(tester, '5678');

    expect(find.text(l10n.settingsPinChanged), findsOneWidget);
    expect(await tester.runAsync(() => verify('5678')), isTrue);
    expect(await tester.runAsync(() => verify('1234')), isFalse);
  });

  group('biometrics', () {
    testWidgets('turning them on needs one successful scan', (tester) async {
      await pump(tester);
      await turnOn(tester, '1234');

      biometrics.outcome = BiometricOutcome.cancelled;
      await tester.tap(switchOf(l10n.settingsBiometrics));
      await tester.pumpAndSettle();
      expect(settings()?.biometricsEnabled, isFalse);

      biometrics.outcome = BiometricOutcome.success;
      await tester.tap(switchOf(l10n.settingsBiometrics));
      await tester.pumpAndSettle();
      expect(settings()?.biometricsEnabled, isTrue);
      expect(biometrics.reasons, hasLength(2));

      await tester.tap(switchOf(l10n.settingsBiometrics));
      await tester.pumpAndSettle();
      expect(settings()?.biometricsEnabled, isFalse);
    });

    testWidgets('without an enrolled face or fingerprint the switch explains why', (tester) async {
      biometrics.available = false;
      await pump(tester);
      await turnOn(tester, '1234');

      expect(tester.widget<SwitchListTile>(switchOf(l10n.settingsBiometrics)).onChanged, isNull);
      expect(find.text(l10n.settingsBiometricsUnavailable), findsOneWidget);
    });
  });

  testWidgets('auto-lock offers the four choices and saves one', (tester) async {
    await pump(tester);
    await turnOn(tester, '1234');

    await tester.tap(find.text(l10n.settingsAutoLock));
    await tester.pumpAndSettle();
    for (final label in [
      l10n.settingsAutoLockImmediately,
      l10n.settingsAutoLockAfterMinutes(1),
      l10n.settingsAutoLockAfterMinutes(5),
    ]) {
      expect(
        find.descendant(of: find.byType(SimpleDialog), matching: find.text(label)),
        findsOneWidget,
      );
    }
    await tester.tap(find.text(l10n.settingsAutoLockAfterMinutes(5)));
    await tester.pumpAndSettle();

    expect(settings()?.timeout, LockTimeout.minutes5);
    expect(find.text(l10n.settingsAutoLockAfterMinutes(5)), findsOneWidget);
  });

  group('accessibility (M9.5)', () {
    testWidgetsBothThemes('meets the guidelines', (tester, brightness) async {
      await pump(tester, brightness: brightness);
      await turnOn(tester, '1234');
      await expectAccessible(tester);
      await tester.tap(find.text(l10n.settingsChangePin));
      await tester.pumpAndSettle();
      await expectAccessible(tester);
    });

    testWidgets('large text (2x) fits', (tester) async {
      useTextScale(tester, 2);
      await pump(tester);
      await turnOn(tester, '1234');
      await scrollThrough(tester);
    });
  });
}
