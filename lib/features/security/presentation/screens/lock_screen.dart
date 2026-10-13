import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/l10n/failure_l10n.dart';
import 'package:expense_tracker/core/services/biometric_service.dart';
import 'package:expense_tracker/core/theme/app_sizes.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/widgets/app_button.dart';
import 'package:expense_tracker/features/security/domain/services/pin_rules.dart';
import 'package:expense_tracker/features/security/presentation/providers/app_lock_controller.dart';
import 'package:expense_tracker/features/security/presentation/providers/lock_settings_controller.dart';
import 'package:expense_tracker/features/security/presentation/widgets/pin_entry.dart';
import 'package:expense_tracker/features/security/presentation/widgets/pin_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

/// Asks for the PIN (or fingerprint / face) before the app can be used (M7.3). Shown by
/// `AppLockGate` while the app is locked.
class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  var _pin = '';
  String? _error;
  var _busy = false;

  @override
  void initState() {
    super.initState();
    // Offer biometrics once, right away, when they are on.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final settings = ref.read(lockSettingsControllerProvider).value;
      if (settings?.biometricsEnabled ?? false) _useBiometrics();
    });
  }

  Future<void> _submit(String pin) async {
    if (_busy) return;
    setState(() => _busy = true);
    final result = await ref.read(appLockControllerProvider.notifier).unlockWithPin(pin);
    if (!mounted) return;
    final l10n = context.l10n;
    setState(() {
      _busy = false;
      _pin = '';
      _error = switch (result) {
        Success(value: true) => null,
        Success() => l10n.lockWrongPin,
        Failure(:final failure) => failure.toL10n(context),
      };
    });
    if (_error != null) await HapticFeedback.heavyImpact();
  }

  Future<void> _useBiometrics() async {
    final l10n = context.l10n;
    final outcome = await ref
        .read(appLockControllerProvider.notifier)
        .unlockWithBiometrics(reason: l10n.lockBiometricReason);
    if (!mounted) return;
    final message = switch (outcome) {
      BiometricOutcome.lockedOut => l10n.lockBiometricLockedOut,
      BiometricOutcome.unavailable => l10n.lockBiometricUnavailable,
      _ => null,
    };
    if (message != null) setState(() => _error = message);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final settings = ref.watch(lockSettingsControllerProvider).value;
    // A PIN saved before the 4-digit rule keeps its own length.
    final length = (settings?.pinLength ?? 0) > 0 ? settings!.pinLength : PinRules.length;
    final error = _error;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppSizes.maxMessageWidth),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: AppSizes.iconXl,
                    color: context.colorScheme.primary,
                  ),
                  const Gap(AppSpacing.md),
                  Text(
                    l10n.lockTitle,
                    style: context.text.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const Gap(AppSpacing.sm),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      error ?? '',
                      textAlign: TextAlign.center,
                      style: context.text.bodyMedium?.copyWith(color: context.colorScheme.error),
                    ),
                  ),
                  const Gap(AppSpacing.md),
                  PinEntry(
                    value: _pin,
                    length: length,
                    enabled: !_busy,
                    onChanged: (pin) => setState(() {
                      _pin = pin;
                      _error = null;
                    }),
                    onSubmit: _submit,
                    leading: (settings?.biometricsEnabled ?? false)
                        ? IconButton(
                            onPressed: _busy ? null : _useBiometrics,
                            tooltip: l10n.lockUseBiometrics,
                            icon: const Icon(Icons.fingerprint),
                          )
                        : null,
                  ),
                  const Gap(AppSpacing.md),
                  AppButton.text(
                    label: l10n.lockForgotPin,
                    onPressed: _busy ? null : () => PinSheet.recover(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
