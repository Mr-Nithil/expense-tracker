import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/l10n/failure_l10n.dart';
import 'package:expense_tracker/core/l10n/generated/app_localizations.dart';
import 'package:expense_tracker/core/services/biometric_service.dart';
import 'package:expense_tracker/core/services/local_biometric_service.dart';
import 'package:expense_tracker/core/widgets/app_switch.dart';
import 'package:expense_tracker/core/widgets/section_header.dart';
import 'package:expense_tracker/features/security/domain/entities/lock_settings.dart';
import 'package:expense_tracker/features/security/presentation/providers/lock_settings_controller.dart';
import 'package:expense_tracker/features/security/presentation/widgets/pin_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Settings → "Security" (M7.6): app lock (PIN), change PIN, biometric unlock and auto-lock.
/// Shows nothing until the settings load.
class SecuritySettingsSection extends ConsumerWidget {
  const SecuritySettingsSection({super.key});

  /// e.g. "After 30 seconds".
  static String timeoutLabel(AppLocalizations l10n, LockTimeout timeout) => switch (timeout) {
    LockTimeout.immediately => l10n.settingsAutoLockImmediately,
    LockTimeout.seconds30 => l10n.settingsAutoLockAfterSeconds(30),
    LockTimeout.minute1 => l10n.settingsAutoLockAfterMinutes(1),
    LockTimeout.minutes5 => l10n.settingsAutoLockAfterMinutes(5),
  };

  static void _report(BuildContext context, Result<Object?> result, String success) {
    if (!context.mounted) return;
    context.showSnack(switch (result) {
      Success() => success,
      Failure(:final failure) => failure.toL10n(context),
    });
  }

  Future<void> _setLock(BuildContext context, WidgetRef ref, {required bool on}) async {
    final l10n = context.l10n;
    if (on) {
      if (await PinSheet.setUp(context) && context.mounted) {
        context.showSnack(l10n.settingsAppLockOn);
      }
      return;
    }
    if (!await PinSheet.verify(context) || !context.mounted) return;
    final result = await ref.read(lockSettingsControllerProvider.notifier).removePin();
    if (context.mounted) _report(context, result, l10n.settingsAppLockOff);
  }

  Future<void> _changePin(BuildContext context) async {
    final l10n = context.l10n;
    if (await PinSheet.change(context) && context.mounted) {
      context.showSnack(l10n.settingsPinChanged);
    }
  }

  /// Turning biometrics on needs one successful scan, so the user knows it works.
  Future<void> _setBiometrics(BuildContext context, WidgetRef ref, {required bool on}) async {
    final l10n = context.l10n;
    final settings = ref.read(lockSettingsControllerProvider.notifier);
    if (on) {
      final outcome = await ref
          .read(biometricServiceProvider)
          .authenticate(reason: l10n.lockBiometricReason);
      if (!context.mounted) return;
      switch (outcome) {
        case BiometricOutcome.success:
          break;
        case BiometricOutcome.lockedOut:
          return context.showSnack(l10n.lockBiometricLockedOut);
        case BiometricOutcome.unavailable:
          return context.showSnack(l10n.settingsBiometricsUnavailable);
        case BiometricOutcome.cancelled || BiometricOutcome.failed:
          return;
      }
    }
    final result = await settings.setBiometricsEnabled(enabled: on);
    if (context.mounted && result is Failure) _report(context, result, '');
  }

  Future<void> _chooseTimeout(BuildContext context, WidgetRef ref, LockTimeout current) async {
    final l10n = context.l10n;
    final chosen = await showDialog<LockTimeout>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l10n.settingsAutoLock),
        children: [
          for (final option in LockTimeout.values)
            ListTile(
              title: Text(timeoutLabel(l10n, option)),
              trailing: option == current ? const Icon(Icons.check) : null,
              selected: option == current,
              onTap: () => Navigator.of(context).pop(option),
            ),
        ],
      ),
    );
    if (chosen == null || chosen == current || !context.mounted) return;
    final result = await ref.read(lockSettingsControllerProvider.notifier).setTimeout(chosen);
    if (context.mounted && result is Failure) _report(context, result, '');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final settings = ref.watch(lockSettingsControllerProvider).value;
    if (settings == null) return const SizedBox.shrink();
    final biometricsAvailable = ref.watch(biometricsAvailableProvider).value ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: l10n.settingsSecurityLabel),
        AppSwitchTile(
          secondary: const Icon(Icons.lock_outline),
          title: Text(l10n.settingsAppLock),
          subtitle: Text(l10n.settingsAppLockDescription),
          value: settings.pinEnabled,
          onChanged: (on) => _setLock(context, ref, on: on),
        ),
        if (settings.pinEnabled) ...[
          ListTile(
            leading: const Icon(Icons.password),
            title: Text(l10n.settingsChangePin),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _changePin(context),
          ),
          AppSwitchTile(
            secondary: const Icon(Icons.fingerprint),
            title: Text(l10n.settingsBiometrics),
            subtitle: biometricsAvailable ? null : Text(l10n.settingsBiometricsUnavailable),
            value: settings.biometricsEnabled && biometricsAvailable,
            onChanged: biometricsAvailable ? (on) => _setBiometrics(context, ref, on: on) : null,
          ),
          ListTile(
            leading: const Icon(Icons.timer_outlined),
            title: Text(l10n.settingsAutoLock),
            subtitle: Text(timeoutLabel(l10n, settings.timeout)),
            trailing: const Icon(Icons.arrow_drop_down),
            onTap: () => _chooseTimeout(context, ref, settings.timeout),
          ),
        ],
      ],
    );
  }
}
