import 'dart:math' as math;

import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/extensions/reduce_motion.dart';
import 'package:expense_tracker/core/theme/app_curves.dart';
import 'package:expense_tracker/core/theme/app_durations.dart';
import 'package:expense_tracker/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';

/// How a [ProgressBar] is colored.
enum ProgressLevel {
  /// On track: primary color.
  normal,

  /// Close to the limit (≥ 80 %): accent color.
  warning,

  /// At or over the limit: danger color; the sprout tip droops.
  exceeded,

  /// A target reached (e.g. a savings goal): leaf color.
  complete,
}

/// The Sprout progress bar for budgets and goals (README §Core components 4): a rounded `field`
/// track, a fill that springs to its new width (500 ms) and a small sprout on the fill's end.
/// [value] is clamped to `0..1`; screen readers hear it as a percent.
///
/// The sprout is painted 12 px above the bar without taking space, like the design.
class ProgressBar extends StatelessWidget {
  const ProgressBar({
    super.key,
    required this.value,
    this.level = ProgressLevel.normal,
    this.semanticsLabel,
    this.height = AppSizes.progressBarHeight,
  });

  final double value;
  final ProgressLevel level;

  /// What the bar measures, e.g. the budget's name.
  final String? semanticsLabel;

  /// Thickness; the fill is never shorter than this.
  final double height;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final colors = context.colors;
    final fraction = value.clamp(0.0, 1.0);
    final exceeded = level == ProgressLevel.exceeded;
    final fill = switch (level) {
      ProgressLevel.normal => scheme.primary,
      ProgressLevel.warning => colors.accent,
      ProgressLevel.exceeded => scheme.error,
      ProgressLevel.complete => colors.leaf,
    };

    return Semantics(
      label: semanticsLabel,
      value: '${(fraction * 100).round()}',
      child: ExcludeSemantics(
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: TweenAnimationBuilder<double>(
            // Springs from the old width to a new one; no animation on first build.
            tween: Tween(begin: fraction, end: fraction),
            duration: context.reduceMotion ? Duration.zero : AppDurations.barGrow,
            curve: AppCurves.elastic,
            builder: (context, shown, _) => CustomPaint(
              painter: ProgressBarPainter(
                fraction: shown,
                track: colors.field,
                fill: fill,
                stem: colors.leafDeep,
                leaves: exceeded ? scheme.error : colors.leaf,
                droop: exceeded,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Paints a [ProgressBar]: track, fill ([fraction] of the width, at least the bar's height, at
/// most the width) and the sprout tip at the fill's end.
class ProgressBarPainter extends CustomPainter {
  const ProgressBarPainter({
    required this.fraction,
    required this.track,
    required this.fill,
    required this.stem,
    required this.leaves,
    required this.droop,
  });

  final double fraction;
  final Color track;
  final Color fill;
  final Color stem;
  final Color leaves;

  /// Over the limit: the leaves hang down (±50°) instead of reaching up (∓20°).
  final bool droop;

  /// The fill's width on a bar of [size].
  static double fillWidth(Size size, double fraction) =>
      (size.width * fraction).clamp(math.min(size.height, size.width), size.width);

  @override
  void paint(Canvas canvas, Size size) {
    final radius = Radius.circular(size.height / 2);
    canvas.drawRRect(RRect.fromRectAndRadius(Offset.zero & size, radius), Paint()..color = track);
    final width = fillWidth(size, fraction);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, width, size.height), radius),
      Paint()..color = fill,
    );
    _tip(canvas, Offset(width + 4 - 16, -12));
  }

  /// The 16×13 sprout (design CSS: stem 2.5×9 at (7, 4); leaves 8×5 at (0, 1) and 9×5 at (8, 0)).
  void _tip(Canvas canvas, Offset origin) {
    canvas
      ..save()
      ..translate(origin.dx, origin.dy)
      ..drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(7, 4, 2.5, 9), const Radius.circular(2)),
        Paint()..color = stem,
      );
    final paint = Paint()..color = leaves;
    // Left leaf: rounded top-right and bottom-left, turning around its bottom-right corner.
    _leaf(
      canvas,
      const Rect.fromLTWH(0, 1, 8, 5),
      pivot: const Offset(8, 6),
      degrees: droop ? 50 : -20,
      leftLeaning: true,
      paint: paint,
    );
    // Right leaf: rounded top-left and bottom-right, turning around its bottom-left corner.
    _leaf(
      canvas,
      const Rect.fromLTWH(8, 0, 9, 5),
      pivot: const Offset(8, 5),
      degrees: droop ? -50 : 20,
      leftLeaning: false,
      paint: paint,
    );
    canvas.restore();
  }

  static void _leaf(
    Canvas canvas,
    Rect rect, {
    required Offset pivot,
    required double degrees,
    required bool leftLeaning,
    required Paint paint,
  }) {
    final round = Radius.elliptical(rect.width, rect.height);
    final shape = leftLeaning
        ? RRect.fromRectAndCorners(rect, topRight: round, bottomLeft: round)
        : RRect.fromRectAndCorners(rect, topLeft: round, bottomRight: round);
    canvas
      ..save()
      ..translate(pivot.dx, pivot.dy)
      ..rotate(degrees * math.pi / 180)
      ..translate(-pivot.dx, -pivot.dy)
      ..drawRRect(shape, paint)
      ..restore();
  }

  @override
  bool shouldRepaint(ProgressBarPainter old) =>
      old.fraction != fraction ||
      old.track != track ||
      old.fill != fill ||
      old.stem != stem ||
      old.leaves != leaves ||
      old.droop != droop;
}
