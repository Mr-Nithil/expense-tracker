import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/theme/app_radius.dart';
import 'package:expense_tracker/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';

/// How a [ProgressBar] is colored.
enum ProgressLevel {
  /// On track: primary color.
  normal,

  /// Close to the limit: warning color.
  warning,

  /// At or over the limit: expense color.
  exceeded,

  /// A target reached (e.g. a savings goal): success color.
  complete,
}

/// A rounded horizontal bar for budget and goal progress. Use instead of a raw
/// `LinearProgressIndicator`. [value] is clamped to `0..1`; screen readers hear it as a percent.
class ProgressBar extends StatelessWidget {
  const ProgressBar({
    super.key,
    required this.value,
    this.level = ProgressLevel.normal,
    this.semanticsLabel,
  });

  final double value;
  final ProgressLevel level;

  /// What the bar measures, e.g. the budget's name.
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final color = switch (level) {
      ProgressLevel.normal => context.colorScheme.primary,
      ProgressLevel.warning => context.colors.warning,
      ProgressLevel.exceeded => context.colors.expense,
      ProgressLevel.complete => context.colors.success,
    };
    return LinearProgressIndicator(
      value: value.clamp(0.0, 1.0),
      minHeight: AppSizes.progressBarHeight,
      color: color,
      backgroundColor: context.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      semanticsLabel: semanticsLabel,
    );
  }
}
