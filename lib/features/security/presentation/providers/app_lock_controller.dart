import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/services/biometric_service.dart';
import 'package:expense_tracker/core/services/local_biometric_service.dart';
import 'package:expense_tracker/core/session/session.dart';
import 'package:expense_tracker/core/utils/clock.dart';
import 'package:expense_tracker/features/security/domain/entities/lock_settings.dart';
import 'package:expense_tracker/features/security/presentation/providers/lock_settings_controller.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show ProviderListenableSelect;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_lock_controller.g.dart';

enum AppLockStatus {
  /// The lock settings are still loading: show nothing yet.
  checking,
  locked,
  unlocked,
}

/// Whether the app is locked right now (M7.4).
///
/// Locks on a cold start when a PIN is set, and when the app comes back after being hidden for at
/// least the chosen timeout ("Immediately" = every time). Hide/show (not inactive) is used, so a
/// biometric prompt or the notification shade never locks it. Fails closed: settings that can't
/// be read keep it locked (recovery still works). Only a correct PIN or biometrics unlock it;
/// turning the PIN off (Settings or recovery) unlocks too.
@Riverpod(keepAlive: true)
class AppLockController extends _$AppLockController {
  DateTime? _hiddenAt;

  @override
  AppLockStatus build() {
    // A new user starts over.
    ref.watch(sessionProvider.select((user) => user?.userId));
    _hiddenAt = null;
    final listener = AppLifecycleListener(onHide: handleHidden, onShow: handleShown);
    ref.onDispose(listener.dispose);
    ref.listen(lockSettingsControllerProvider, (_, next) => _apply(next));
    return _initial(ref.read(lockSettingsControllerProvider));
  }

  static AppLockStatus _initial(AsyncValue<LockSettings> settings) => switch (settings) {
    AsyncData(:final value) => value.pinEnabled ? AppLockStatus.locked : AppLockStatus.unlocked,
    AsyncError() => AppLockStatus.locked,
    _ => AppLockStatus.checking,
  };

  void _apply(AsyncValue<LockSettings> settings) {
    if (state == AppLockStatus.checking) {
      state = _initial(settings);
    } else if (settings case AsyncData(value: LockSettings(pinEnabled: false))) {
      state = AppLockStatus.unlocked;
    }
  }

  LockSettings? get _settings => ref.read(lockSettingsControllerProvider).value;

  @visibleForTesting
  void handleHidden() => _hiddenAt = ref.read(clockProvider).now();

  @visibleForTesting
  void handleShown() {
    final hiddenAt = _hiddenAt;
    _hiddenAt = null;
    final settings = _settings;
    if (hiddenAt == null || state != AppLockStatus.unlocked || settings == null) return;
    if (!settings.pinEnabled) return;
    if (ref.read(clockProvider).now().difference(hiddenAt) >= settings.timeout.duration) {
      state = AppLockStatus.locked;
    }
  }

  /// Unlocks when [pin] is right. `Success(false)` for a wrong PIN.
  Future<Result<bool>> unlockWithPin(String pin) async {
    final result = await ref.read(lockSettingsControllerProvider.notifier).verifyPin(pin);
    if (result case Success(value: true) when ref.mounted) state = AppLockStatus.unlocked;
    return result;
  }

  /// Shows the system prompt (only when biometric unlock is on) and unlocks on success.
  Future<BiometricOutcome> unlockWithBiometrics({required String reason}) async {
    if (!(_settings?.biometricsEnabled ?? false)) return BiometricOutcome.unavailable;
    final outcome = await ref.read(biometricServiceProvider).authenticate(reason: reason);
    if (outcome == BiometricOutcome.success && ref.mounted) state = AppLockStatus.unlocked;
    return outcome;
  }
}
