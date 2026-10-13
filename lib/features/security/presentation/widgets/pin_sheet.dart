import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/l10n/failure_l10n.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/widgets/app_bottom_sheet.dart';
import 'package:expense_tracker/core/widgets/app_button.dart';
import 'package:expense_tracker/core/widgets/app_text_field.dart';
import 'package:expense_tracker/features/auth/presentation/providers/confirm_password_controller.dart';
import 'package:expense_tracker/features/security/domain/services/pin_rules.dart';
import 'package:expense_tracker/features/security/presentation/providers/lock_settings_controller.dart';
import 'package:expense_tracker/features/security/presentation/widgets/pin_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

enum _Mode { setUp, change, verify, recover }

enum _Step { password, current, choose, confirm }

/// Every PIN flow in one sheet (M7.6, M7.7). Each `show` completes with `true` when the flow
/// finished (PIN saved, or the current PIN confirmed) and `false` when closed early.
///
/// - [setUp]: choose → confirm → turn the lock on.
/// - [change]: current PIN → choose → confirm.
/// - [verify]: current PIN only (before turning the lock off).
/// - [recover] ("Forgot PIN?"): account password → choose (or skip) → confirm. Saves at the end
///   (old PIN removed, new one set); removing the PIN is what unlocks the app.
class PinSheet extends ConsumerStatefulWidget {
  const PinSheet._(this._mode);

  final _Mode _mode;

  static Future<bool> setUp(BuildContext context) => _show(context, _Mode.setUp);

  static Future<bool> change(BuildContext context) => _show(context, _Mode.change);

  static Future<bool> verify(BuildContext context) => _show(context, _Mode.verify);

  static Future<bool> recover(BuildContext context) => _show(context, _Mode.recover);

  static Future<bool> _show(BuildContext context, _Mode mode) async =>
      await AppBottomSheet.show<bool>(context, child: PinSheet._(mode)) ?? false;

  @override
  ConsumerState<PinSheet> createState() => _PinSheetState();
}

class _PinSheetState extends ConsumerState<PinSheet> {
  late var _step = switch (widget._mode) {
    _Mode.setUp => _Step.choose,
    _Mode.recover => _Step.password,
    _Mode.change || _Mode.verify => _Step.current,
  };
  final _password = TextEditingController();
  var _pin = '';
  var _first = '';
  String? _error;
  var _busy = false;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  LockSettingsController get _settings => ref.read(lockSettingsControllerProvider.notifier);

  void _fail(String message, {_Step? step}) {
    setState(() {
      _busy = false;
      _pin = '';
      _error = message;
      if (step != null) _step = step;
    });
    HapticFeedback.heavyImpact();
  }

  void _next(_Step step) => setState(() {
    _busy = false;
    _pin = '';
    _error = null;
    _step = step;
  });

  Future<void> _checkPassword() async {
    setState(() => _busy = true);
    final result = await ref
        .read(confirmPasswordControllerProvider.notifier)
        .confirm(_password.text);
    if (!mounted) return;
    switch (result) {
      case Success():
        _next(_Step.choose);
      case Failure(:final failure):
        setState(() {
          _busy = false;
          _error = failure.toL10n(context);
        });
    }
  }

  Future<void> _checkCurrent(String pin) async {
    setState(() => _busy = true);
    final result = await _settings.verifyPin(pin);
    if (!mounted) return;
    switch (result) {
      case Success(value: true) when widget._mode == _Mode.verify:
        Navigator.of(context).pop(true);
      case Success(value: true):
        _next(_Step.choose);
      case Success():
        _fail(context.l10n.lockWrongPin);
      case Failure(:final failure):
        _fail(failure.toL10n(context));
    }
  }

  void _chosen(String pin) {
    _first = pin;
    _next(_Step.confirm);
  }

  Future<void> _confirm(String pin) async {
    if (pin != _first) return _fail(context.l10n.pinMismatch, step: _Step.choose);
    setState(() => _busy = true);
    // Captured first: in recovery, removing the PIN unlocks the app and closes this sheet.
    final settings = _settings;
    final navigator = Navigator.of(context);
    final errorOf = context.l10n;
    if (widget._mode == _Mode.recover) {
      if (await settings.removePin() case Failure(:final failure)) {
        if (mounted) _fail(failure.localize(errorOf));
        return;
      }
    }
    final result = await settings.setPin(pin);
    if (!mounted) return;
    switch (result) {
      case Success():
        navigator.pop(true);
      case Failure(:final failure):
        _fail(failure.toL10n(context));
    }
  }

  /// Recovery without a new PIN: the lock is simply turned off.
  Future<void> _skip() async {
    setState(() => _busy = true);
    final navigator = Navigator.of(context);
    final result = await _settings.removePin();
    if (!mounted) return;
    switch (result) {
      case Success():
        navigator.pop(true);
      case Failure(:final failure):
        _fail(failure.toL10n(context));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final recovering = widget._mode == _Mode.recover;
    final pinLength = ref.watch(lockSettingsControllerProvider).value?.pinLength ?? 0;
    final error = _error;

    final (title, hint) = switch (_step) {
      _Step.password => (l10n.lockRecoveryTitle, null),
      _Step.current => (l10n.pinCurrentTitle, null),
      _Step.choose => (
        l10n.pinSetTitle,
        [
          if (recovering) l10n.lockRecoveryDone,
          l10n.pinSetHint(PinRules.length),
        ].join('\n'),
      ),
      _Step.confirm => (l10n.pinConfirmTitle, null),
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: context.text.titleLarge),
        if (hint != null) ...[
          const Gap(AppSpacing.sm),
          Text(hint, style: context.text.bodyMedium),
        ],
        const Gap(AppSpacing.sm),
        Semantics(
          liveRegion: true,
          child: Text(
            error ?? '',
            style: context.text.bodyMedium?.copyWith(color: context.colorScheme.error),
          ),
        ),
        const Gap(AppSpacing.sm),
        if (_step == _Step.password) ...[
          Text(
            l10n.lockRecoveryMessage(
              ref.read(confirmPasswordControllerProvider.notifier).email ?? '',
            ),
          ),
          const Gap(AppSpacing.md),
          AppTextField(
            label: l10n.authPasswordLabel,
            controller: _password,
            obscureText: true,
            autofocus: true,
            enabled: !_busy,
            autofillHints: const [AutofillHints.password],
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _checkPassword(),
          ),
          const Gap(AppSpacing.md),
          AppButton.primary(
            label: l10n.lockRecoverySubmit,
            isLoading: _busy,
            onPressed: _checkPassword,
          ),
        ] else
          PinEntry(
            key: ValueKey(_step),
            value: _pin,
            enabled: !_busy,
            length: switch (_step) {
              // A PIN saved before the 4-digit rule keeps its own length.
              _Step.current => pinLength > 0 ? pinLength : PinRules.length,
              _ => PinRules.length,
            },
            onChanged: (pin) => setState(() {
              _pin = pin;
              _error = null;
            }),
            onSubmit: switch (_step) {
              _Step.current => _checkCurrent,
              _Step.confirm => _confirm,
              _ => _chosen,
            },
          ),
        if (recovering && _step == _Step.choose) ...[
          const Gap(AppSpacing.sm),
          AppButton.text(label: l10n.lockRecoverySkip, onPressed: _busy ? null : _skip),
        ],
      ],
    );
  }
}
