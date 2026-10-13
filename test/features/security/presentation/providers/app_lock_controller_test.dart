import 'package:expense_tracker/core/services/biometric_service.dart';
import 'package:expense_tracker/core/session/session.dart';
import 'package:expense_tracker/core/utils/clock.dart';
import 'package:expense_tracker/features/security/domain/entities/lock_settings.dart';
import 'package:expense_tracker/features/security/presentation/providers/app_lock_controller.dart';
import 'package:expense_tracker/features/security/presentation/providers/lock_settings_controller.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fake_biometric_service.dart';
import '../../../../helpers/fake_secure_storage.dart';
import '../../../../helpers/test_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeSecureStorage storage;
  late FakeBiometricService biometrics;
  late FixedClock clock;
  late ProviderContainer container;

  setUp(() {
    storage = FakeSecureStorage();
    biometrics = FakeBiometricService();
    clock = FixedClock(DateTime(2026, 10, 12, 9));
    container = createTestContainer(
      overrides: [
        storage.providerOverride,
        fastSecurityRepositoryOverride(storage),
        biometrics.providerOverride,
        clockProvider.overrideWithValue(clock),
      ],
    );
    container.listen(appLockControllerProvider, (_, _) {});
  });

  LockSettingsController settings() => container.read(lockSettingsControllerProvider.notifier);
  AppLockController lock() => container.read(appLockControllerProvider.notifier);
  AppLockStatus status() => container.read(appLockControllerProvider);

  /// Signs in and waits for the lock settings to load.
  Future<void> signIn([String userId = 'u1']) async {
    container.read(sessionProvider.notifier).set(SessionUser(userId: userId));
    await container.read(lockSettingsControllerProvider.future);
    await pumpEventQueue();
  }

  /// Sets a PIN as user u1 on an earlier run, then "restarts" the app with it.
  Future<void> restartWithPin(String pin, {LockTimeout? timeout, bool biometrics = false}) async {
    await signIn();
    await settings().setPin(pin);
    if (timeout != null) await settings().setTimeout(timeout);
    if (biometrics) await settings().setBiometricsEnabled(enabled: true);
    container.read(sessionProvider.notifier).set(null);
    await pumpEventQueue();
    await signIn();
  }

  test('without a PIN the app is unlocked', () async {
    await signIn();
    expect(status(), AppLockStatus.unlocked);
  });

  test('checks the settings before deciding', () async {
    container.read(sessionProvider.notifier).set(const SessionUser(userId: 'u1'));
    expect(status(), AppLockStatus.checking);
    await container.read(lockSettingsControllerProvider.future);
    await pumpEventQueue();
    expect(status(), AppLockStatus.unlocked);
  });

  test('a start with a PIN is locked; only the right PIN unlocks', () async {
    await restartWithPin('2468');
    expect(status(), AppLockStatus.locked);

    expect((await lock().unlockWithPin('1357')).valueOrNull, isFalse);
    expect(status(), AppLockStatus.locked);

    expect((await lock().unlockWithPin('2468')).valueOrNull, isTrue);
    expect(status(), AppLockStatus.unlocked);
  });

  test('turning the lock on does not lock the app being used', () async {
    await signIn();
    await settings().setPin('2468');
    expect(status(), AppLockStatus.unlocked);
  });

  test('settings that cannot be read keep it locked', () async {
    storage.failWith = PlatformException(code: 'keystore');
    container.read(sessionProvider.notifier).set(const SessionUser(userId: 'u1'));
    await expectLater(container.read(lockSettingsControllerProvider.future), throwsA(anything));
    await pumpEventQueue();

    expect(status(), AppLockStatus.locked);
  });

  group('back from the background', () {
    Future<void> unlockedWithTimeout(LockTimeout timeout) async {
      await restartWithPin('2468', timeout: timeout);
      await lock().unlockWithPin('2468');
    }

    test('locks after the timeout, not before', () async {
      await unlockedWithTimeout(LockTimeout.minute1);

      lock().handleHidden();
      clock.advance(const Duration(seconds: 59));
      lock().handleShown();
      expect(status(), AppLockStatus.unlocked);

      lock().handleHidden();
      clock.advance(const Duration(minutes: 1));
      lock().handleShown();
      expect(status(), AppLockStatus.locked);
    });

    test('"Immediately" locks every time', () async {
      await unlockedWithTimeout(LockTimeout.immediately);

      lock().handleHidden();
      lock().handleShown();

      expect(status(), AppLockStatus.locked);
    });

    test('the default is 30 seconds', () async {
      await unlockedWithTimeout(LockTimeout.fallback);

      lock().handleHidden();
      clock.advance(const Duration(seconds: 30));
      lock().handleShown();

      expect(status(), AppLockStatus.locked);
    });

    test('without a PIN it never locks', () async {
      await signIn();

      lock().handleHidden();
      clock.advance(const Duration(hours: 1));
      lock().handleShown();

      expect(status(), AppLockStatus.unlocked);
    });

    test('the real lifecycle events drive it', () async {
      await unlockedWithTimeout(LockTimeout.immediately);
      final binding = TestWidgetsFlutterBinding.instance;

      binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      expect(status(), AppLockStatus.unlocked, reason: 'a system dialog is not leaving the app');

      binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      expect(status(), AppLockStatus.locked);
    });
  });

  group('biometrics', () {
    test('unlock when turned on and recognized', () async {
      await restartWithPin('2468', biometrics: true);

      expect(await lock().unlockWithBiometrics(reason: 'Unlock'), BiometricOutcome.success);
      expect(status(), AppLockStatus.unlocked);
      expect(biometrics.reasons, ['Unlock']);
    });

    test('a cancelled or failed prompt keeps it locked', () async {
      await restartWithPin('2468', biometrics: true);
      biometrics.outcome = BiometricOutcome.cancelled;

      expect(await lock().unlockWithBiometrics(reason: 'Unlock'), BiometricOutcome.cancelled);
      expect(status(), AppLockStatus.locked);
    });

    test('are not offered when turned off', () async {
      await restartWithPin('2468');

      expect(await lock().unlockWithBiometrics(reason: 'Unlock'), BiometricOutcome.unavailable);
      expect(biometrics.reasons, isEmpty);
      expect(status(), AppLockStatus.locked);
    });
  });

  test('removing the PIN (e.g. recovery) unlocks', () async {
    await restartWithPin('2468');

    await settings().removePin();

    expect(status(), AppLockStatus.unlocked);
  });

  test('another user on this phone starts without the lock', () async {
    await restartWithPin('2468');
    container.read(sessionProvider.notifier).set(null);
    await pumpEventQueue();

    await signIn('u2');

    expect(status(), AppLockStatus.unlocked);
  });
}
