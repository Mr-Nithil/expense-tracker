import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/theme/app_sizes.dart';
import 'package:expense_tracker/core/widgets/progress_bar.dart';
import 'package:flutter/material.dart';

/// Circular progress for goals (the round sibling of [ProgressBar]), with an optional label in
/// the middle. Use instead of a raw `CircularProgressIndicator`. [value] is clamped to `0..1`.
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.value,
    this.level = ProgressLevel.normal,
    this.size = AppSizes.progressRing,
    this.child,
    this.semanticsLabel,
  });

  final double value;
  final ProgressLevel level;

  /// Diameter.
  final double size;

  /// Shown in the middle, e.g. the percent.
  final Widget? child;

  /// What the ring measures, e.g. the goal's name.
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final color = switch (level) {
      ProgressLevel.normal => context.colorScheme.primary,
      ProgressLevel.warning => context.colors.warning,
      ProgressLevel.exceeded => context.colors.expense,
      ProgressLevel.complete => context.colors.success,
    };
    final label = child;
    return SizedBox.square(
      dimension: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: value.clamp(0.0, 1.0),
            strokeWidth: AppSizes.progressRingStroke,
            color: color,
            backgroundColor: context.colorScheme.surfaceContainerHighest,
            semanticsLabel: semanticsLabel,
          ),
          if (label != null)
            Center(
              child: FittedBox(fit: BoxFit.scaleDown, child: label),
            ),
        ],
      ),
    );
  }
}
