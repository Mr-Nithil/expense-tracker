import 'dart:math' as math;

import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/extensions/reduce_motion.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/core/theme/app_curves.dart';
import 'package:expense_tracker/features/goals/domain/entities/goal_stage.dart';
import 'package:flutter/material.dart';

/// A goal drawn as a plant that grows with the savings (README §Core components 8): a seed, a
/// sprout, a seedling, a young plant, then a flower. It sways gently and pops in when it first
/// shows and when it reaches a new [stage]. Still with reduce motion; decorative unless
/// [semanticsLabel] is given.
class GoalPlant extends StatefulWidget {
  const GoalPlant({super.key, required this.stage, this.size = 170, this.semanticsLabel});

  final GoalStage stage;
  final double size;
  final String? semanticsLabel;

  /// One sway (−5° → +6° → −5°).
  static const sway = Duration(seconds: 4);

  /// The pop-in on a new stage.
  static const pop = Duration(milliseconds: 600);

  @override
  State<GoalPlant> createState() => _GoalPlantState();
}

class _GoalPlantState extends State<GoalPlant> with TickerProviderStateMixin {
  late final _sway = AnimationController(vsync: this, duration: GoalPlant.sway);
  late final _pop = AnimationController(vsync: this, duration: GoalPlant.pop);
  var _reduceMotion = false;
  var _shown = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = context.reduceMotion;
    if (_reduceMotion) {
      _sway
        ..stop()
        ..value = 0;
      _pop.value = 1;
    } else {
      if (!_sway.isAnimating) _sway.repeat();
      if (!_shown) _pop.forward(from: 0);
    }
    _shown = true;
  }

  @override
  void didUpdateWidget(GoalPlant old) {
    super.didUpdateWidget(old);
    if (widget.stage != old.stage && !_reduceMotion) _pop.forward(from: 0);
  }

  @override
  void dispose() {
    _sway.dispose();
    _pop.dispose();
    super.dispose();
  }

  /// popIn keyframes: scale 0.5 → 1.08 at 70 % (fading in), then → 1; springy curve.
  static (double, double) _popAt(double t) {
    if (t >= 1) return (1, 1);
    if (t < 0.7) {
      final f = AppCurves.elastic.transform(t / 0.7);
      return (0.5 + 0.58 * f, f.clamp(0.0, 1.0));
    }
    final f = AppCurves.elastic.transform((t - 0.7) / 0.3);
    return (1.08 - 0.08 * f, 1);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final picture = AnimatedBuilder(
      animation: Listenable.merge([_sway, _pop]),
      builder: (context, _) {
        final (scale, opacity) = _popAt(_pop.value);
        final sway = _sway.isAnimating
            ? -5 + 11 * (1 - math.cos(2 * math.pi * _sway.value)) / 2
            : 0.0;
        return Opacity(
          opacity: opacity,
          child: Transform.scale(
            scale: scale,
            child: CustomPaint(
              size: Size.square(widget.size),
              painter: GoalPlantPainter(stage: widget.stage, swayDegrees: sway, colors: colors),
            ),
          ),
        );
      },
    );
    final label = widget.semanticsLabel;
    return label == null
        ? ExcludeSemantics(child: picture)
        : Semantics(label: label, image: true, excludeSemantics: true, child: picture);
  }
}

/// Paints a [GoalPlant] on the design's 120×120 grid (soil, then the plant swayed around its
/// base at (60, 105)). Public for tests.
class GoalPlantPainter extends CustomPainter {
  const GoalPlantPainter({required this.stage, required this.swayDegrees, required this.colors});

  final GoalStage stage;
  final double swayDegrees;
  final AppColors colors;

  static const _grid = 120.0;
  static const _heights = <double>[0, 18, 34, 48, 58];
  static const _leafScales = <double>[0, 0.8, 1.1, 1.3, 1.4];

  /// The stem's height for a stage (0 for the seed).
  static double heightOf(GoalStage stage) => _heights[stage.index];

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..scale(size.width / _grid, size.height / _grid);
    _ellipse(canvas, const Offset(60, 106), 34, 7, 0, colors.leafDeep.withValues(alpha: .25));

    if (stage == GoalStage.seed) {
      _ellipse(canvas, const Offset(60, 101), 8, 5.5, 0, colors.mascotDeep);
      canvas.restore();
      return;
    }

    final height = heightOf(stage);
    final top = 104 - height;
    final sc = _leafScales[stage.index];
    canvas
      ..translate(60, 105)
      ..rotate(swayDegrees * math.pi / 180)
      ..translate(-60, -105)
      ..drawLine(
        const Offset(60, 105),
        Offset(60, top),
        Paint()
          ..color = colors.leafDeep
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round,
      );
    if (stage.index >= GoalStage.youngPlant.index) {
      final y = 104 - height * 0.45;
      _ellipse(canvas, Offset(48, y), 12, 6, 20, colors.leaf);
      _ellipse(canvas, Offset(72, y - 3), 12, 6, -20, colors.leaf);
    }
    _ellipse(canvas, Offset(60 - 10 * sc, top + 3), 10 * sc, 5.5 * sc, 30, colors.leaf);
    _ellipse(canvas, Offset(60 + 11 * sc, top - 1), 11 * sc, 6 * sc, -30, colors.leaf);
    if (stage == GoalStage.bloom) {
      final petal = Paint()..color = colors.accent;
      for (final degrees in [0, 72, 144, 216, 288]) {
        final angle = degrees * math.pi / 180;
        canvas.drawCircle(
          Offset(60 + math.cos(angle) * 7, top - 10 + math.sin(angle) * 7),
          6,
          petal,
        );
      }
      canvas.drawCircle(Offset(60, top - 10), 5, Paint()..color = colors.cheek);
    }
    canvas.restore();
  }

  static void _ellipse(
    Canvas canvas,
    Offset center,
    double rx,
    double ry,
    double degrees,
    Color color,
  ) {
    canvas
      ..save()
      ..translate(center.dx, center.dy)
      ..rotate(degrees * math.pi / 180)
      ..drawOval(
        Rect.fromCenter(center: Offset.zero, width: rx * 2, height: ry * 2),
        Paint()..color = color,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(GoalPlantPainter old) =>
      old.stage != stage || old.swayDegrees != swayDegrees || old.colors != colors;
}
