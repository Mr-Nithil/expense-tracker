import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/theme/app_radius.dart';
import 'package:expense_tracker/core/theme/app_sizes.dart';
import 'package:expense_tracker/core/widgets/chunky_pressable.dart';
import 'package:flutter/material.dart';

enum _AppButtonVariant { primary, secondary, text, danger }

/// The app's buttons (Sprout "chunky" style). Pick a variant with a named constructor:
/// primary, secondary (outline), danger, text (link). Chunky variants show their label in capitals.
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
    final colors = context.colors;
    final handler = isLoading ? null : onPressed;
    final enabled = handler != null;
    final leading = isLoading ? const _ButtonSpinner() : (icon == null ? null : Icon(icon));
    final radius = BorderRadius.circular(AppRadius.field);
    final shape = RoundedRectangleBorder(borderRadius: radius);
    final textStyle = context.text.labelLarge;

    // Chunky variants show their label in capitals; screen readers get the normal wording.
    Widget label(bool upper) =>
        upper ? Text(this.label.toUpperCase(), semanticsLabel: this.label) : Text(this.label);

    Widget filled({required Color background, required Color foreground}) {
      final style = FilledButton.styleFrom(
        backgroundColor: background,
        foregroundColor: foreground,
        minimumSize: const Size(AppSizes.minTapTarget, AppSizes.chunkyButtonHeight),
        shape: shape,
        textStyle: textStyle,
        elevation: 0,
      );
      return leading == null
          ? FilledButton(onPressed: handler, style: style, child: label(true))
          : FilledButton.icon(onPressed: handler, style: style, icon: leading, label: label(true));
    }

    final (Widget button, Color? shadow) = switch (_variant) {
      _AppButtonVariant.primary => (
        filled(background: scheme.primary, foreground: scheme.onPrimary),
        colors.primaryDeep,
      ),
      _AppButtonVariant.danger => (
        filled(background: scheme.error, foreground: scheme.onError),
        Color.lerp(scheme.error, scheme.shadow, 0.3),
      ),
      _AppButtonVariant.secondary => () {
        final style = OutlinedButton.styleFrom(
          backgroundColor: scheme.surfaceContainerLowest,
          foregroundColor: scheme.onSurface,
          minimumSize: const Size(AppSizes.minTapTarget, AppSizes.outlineButtonHeight),
          shape: shape,
          side: BorderSide(color: colors.line, width: AppSizes.chunkyBorder),
          textStyle: textStyle,
        );
        final Widget button = leading == null
            ? OutlinedButton(onPressed: handler, style: style, child: label(true))
            : OutlinedButton.icon(
                onPressed: handler,
                style: style,
                icon: leading,
                label: label(true),
              );
        return (button, colors.line);
      }(),
      _AppButtonVariant.text => () {
        final style = TextButton.styleFrom(
          foregroundColor: colors.link,
          minimumSize: const Size(AppSizes.minTapTarget, AppSizes.minTapTarget),
          shape: shape,
          textStyle: textStyle?.copyWith(letterSpacing: 0),
        );
        final Widget button = leading == null
            ? TextButton(onPressed: handler, style: style, child: label(false))
            : TextButton.icon(onPressed: handler, style: style, icon: leading, label: label(false));
        return (button, null);
      }(),
    };

    final sized = isExpanded ? SizedBox(width: double.infinity, child: button) : button;
    if (shadow == null) return sized;
    return ChunkyPressable(shadowColor: shadow, radius: radius, enabled: enabled, child: sized);
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
