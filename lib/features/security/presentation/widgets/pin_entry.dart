import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/theme/app_sizes.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// PIN dots and keypad. The parent owns [value] (so it can clear it after a wrong PIN).
/// [onSubmit] runs as soon as [length] digits are entered.
class PinEntry extends StatelessWidget {
  const PinEntry({
    super.key,
    required this.value,
    required this.onChanged,
    required this.onSubmit,
    required this.length,
    this.leading,
    this.enabled = true,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmit;
  final int length;

  /// The bottom-left key, e.g. the biometric button.
  final Widget? leading;
  final bool enabled;

  void _add(int digit) {
    if (value.length >= length) return;
    final next = '$value$digit';
    onChanged(next);
    if (next.length == length) onSubmit(next);
  }

  void _delete() {
    if (value.isNotEmpty) onChanged(value.substring(0, value.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    Widget digit(int d) => _Key(
      onPressed: enabled ? () => _add(d) : null,
      child: Text(context.formatNumber(d), style: context.text.headlineSmall),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          liveRegion: true,
          label: l10n.pinProgress(value.length, length),
          child: ExcludeSemantics(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < length; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                    child: _Dot(filled: i < value.length),
                  ),
              ],
            ),
          ),
        ),
        const Gap(AppSpacing.lg),
        for (final row in const [
          [1, 2, 3],
          [4, 5, 6],
          [7, 8, 9],
        ])
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [for (final d in row) digit(d)],
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox.square(
              dimension: AppSizes.pinKey,
              child: Center(child: leading),
            ),
            digit(0),
            _Key(
              onPressed: enabled && value.isNotEmpty ? _delete : null,
              tooltip: l10n.pinDeleteDigit,
              child: const Icon(Icons.backspace_outlined),
            ),
          ],
        ),
      ],
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({required this.onPressed, required this.child, this.tooltip});

  final VoidCallback? onPressed;
  final Widget child;
  final String? tooltip;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: AppSizes.pinKey,
    child: IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      iconSize: AppSizes.iconMd,
      icon: child,
    ),
  );
}

class _Dot extends StatelessWidget {
  const _Dot({required this.filled});

  final bool filled;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme.primary;
    return Container(
      width: AppSizes.pinDot,
      height: AppSizes.pinDot,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? color : null,
        border: Border.all(color: filled ? color : context.colorScheme.outline),
      ),
    );
  }
}
