import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';

enum _AppButtonVariant { primary, secondary, text, danger }

/// The app's buttons. Pick a variant with a named constructor.
///
/// While [isLoading] is true the button shows a spinner and ignores taps. A null [onPressed]
/// disables it.
class AppButton extends StatelessWidget {
  const AppButton.primary({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isExpanded = false,
  }) : _variant = _AppButtonVariant.primary;

  const AppButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isExpanded = false,
  }) : _variant = _AppButtonVariant.secondary;

  const AppButton.text({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isExpanded = false,
  }) : _variant = _AppButtonVariant.text;

  /// For destructive actions (delete, log out).
  const AppButton.danger({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isExpanded = false,
  }) : _variant = _AppButtonVariant.danger;

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;

  /// Stretch to the full available width.
  final bool isExpanded;

  final _AppButtonVariant _variant;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final handler = isLoading ? null : onPressed;
    final leading = isLoading ? const _ButtonSpinner() : (icon == null ? null : Icon(icon));
    final child = Text(label);

    final button = switch (_variant) {
      _AppButtonVariant.primary =>
        leading == null
            ? FilledButton(onPressed: handler, child: child)
            : FilledButton.icon(onPressed: handler, icon: leading, label: child),
      _AppButtonVariant.secondary =>
        leading == null
            ? OutlinedButton(onPressed: handler, child: child)
            : OutlinedButton.icon(onPressed: handler, icon: leading, label: child),
      _AppButtonVariant.text =>
        leading == null
            ? TextButton(onPressed: handler, child: child)
            : TextButton.icon(onPressed: handler, icon: leading, label: child),
      _AppButtonVariant.danger => () {
        final style = FilledButton.styleFrom(
          backgroundColor: scheme.error,
          foregroundColor: scheme.onError,
        );
        return leading == null
            ? FilledButton(onPressed: handler, style: style, child: child)
            : FilledButton.icon(onPressed: handler, style: style, icon: leading, label: child);
      }(),
    };

    return isExpanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}

class _ButtonSpinner extends StatelessWidget {
  const _ButtonSpinner();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.square(
      dimension: AppSizes.iconSm,
      child: CircularProgressIndicator(strokeWidth: AppSizes.progressStroke),
    );
  }
}
