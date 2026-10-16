import 'dart:math' as math;

import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/theme/app_sizes.dart';
import 'package:expense_tracker/core/widgets/progress_bar.dart';
import 'package:flutter/material.dart';

/// Circular progress for goals (the round sibling of [ProgressBar]): a `leaf` arc on a `field`
/// ring, one eighth of the diameter thick, with an optional label in the middle. [value] is
/// clamped to `0..1`; screen readers hear it as a percent.
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
    final colors = context.colors;
    final fraction = value.clamp(0.0, 1.0);
    final color = switch (level) {
      ProgressLevel.normal || ProgressLevel.complete => colors.leaf,
      ProgressLevel.warning => colors.accent,
      ProgressLevel.exceeded => context.colorScheme.error,
    };
    final label = child;
    return SizedBox.square(
      dimension: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Semantics(
            label: semanticsLabel,
            value: '${(fraction * 100).round()}',
            child: CustomPaint(
              painter: ProgressRingPainter(fraction: fraction, track: colors.field, arc: color),
            ),
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

/// Paints a [ProgressRing]: the [track] circle and the [arc] for [fraction], from 12 o'clock
/// clockwise, inside the box.
class ProgressRingPainter extends CustomPainter {
  const ProgressRingPainter({required this.fraction, required this.track, required this.arc});

  final double fraction;
  final Color track;
  final Color arc;

  /// Ring thickness for a diameter.
  static double thicknessOf(double diameter) => diameter / 8;

  @override
  void paint(Canvas canvas, Size size) {
    final diameter = size.shortestSide;
    final thickness = thicknessOf(diameter);
    final rect = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: (diameter - thickness) / 2,
    );
    Paint stroke(Color color) => Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness;
    canvas.drawOval(rect, stroke(track));
    if (fraction > 0) {
      canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * fraction, false, stroke(arc));
    }
  }

  @override
  bool shouldRepaint(ProgressRingPainter old) =>
      old.fraction != fraction || old.track != track || old.arc != arc;
}
