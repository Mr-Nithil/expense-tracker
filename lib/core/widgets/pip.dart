import 'dart:math' as math;

import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/extensions/reduce_motion.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/core/theme/app_curves.dart';
import 'package:expense_tracker/core/theme/app_durations.dart';
import 'package:flutter/material.dart';

/// Pip's facial expression.
enum PipMood { normal, happy, think, worried }

/// Pip's idle movement.
enum PipIdle { bob, jump, none }

/// Pip, the Sprout mascot (README §Pip geometry): a seedling drawn on a 120×120 grid, scaled to
/// [size]. Decorative unless [semanticsLabel] is given.
///
/// - [mood]: eyes and mouth. [coverEyes]: the hands cover the eyes (380 ms, springy).
/// - [wave]: the right hand waves. [idle]: bob, jump or stand still.
/// - [shakeTrigger]: change it (e.g. increment) to make Pip shake once (500 ms).
///
/// With reduce motion on, Pip doesn't sway, bob, jump, wave or shake, and covers his eyes instantly.
class Pip extends StatefulWidget {
  const Pip({
    super.key,
    this.size = 96,
    this.mood = PipMood.normal,
    this.coverEyes = false,
    this.wave = false,
    this.idle = PipIdle.bob,
    this.shakeTrigger = 0,
    this.semanticsLabel,
  });

  final double size;
  final PipMood mood;
  final bool coverEyes;
  final bool wave;
  final PipIdle idle;
  final int shakeTrigger;
  final String? semanticsLabel;

  static const sway = Duration(milliseconds: 3200);
  static const bob = Duration(milliseconds: 2800);
  static const jump = Duration(milliseconds: 1400);
  static const waveCycle = Duration(milliseconds: 700);
  static const shake = Duration(milliseconds: 500);

  @override
  State<Pip> createState() => _PipState();
}

class _PipState extends State<Pip> with TickerProviderStateMixin {
  late final _sway = AnimationController(vsync: this, duration: Pip.sway);
  late final _idle = AnimationController(vsync: this);
  late final _wave = AnimationController(vsync: this, duration: Pip.waveCycle);
  late final _cover = AnimationController(vsync: this, duration: AppDurations.eyeCover);
  late final _coverCurve = CurvedAnimation(
    parent: _cover,
    curve: AppCurves.elastic,
    reverseCurve: AppCurves.elastic.flipped,
  );
  late final _shake = AnimationController(vsync: this, duration: Pip.shake);
  var _reduceMotion = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = context.reduceMotion;
    _sync(initial: true);
  }

  @override
  void didUpdateWidget(Pip old) {
    super.didUpdateWidget(old);
    _sync();
    if (widget.shakeTrigger != old.shakeTrigger && !_reduceMotion) _shake.forward(from: 0);
  }

  /// Starts or stops the loops to match the widget and the motion setting.
  void _sync({bool initial = false}) {
    void loop(AnimationController controller, bool on) {
      if (on && !_reduceMotion) {
        if (!controller.isAnimating) controller.repeat();
      } else {
        controller
          ..stop()
          ..value = 0;
      }
    }

    _idle.duration = widget.idle == PipIdle.jump ? Pip.jump : Pip.bob;
    loop(_sway, true);
    loop(_idle, widget.idle != PipIdle.none);
    loop(_wave, widget.wave);
    final target = widget.coverEyes ? 1.0 : 0.0;
    if (_reduceMotion || initial) {
      _cover.value = target;
    } else if (_cover.value != target) {
      widget.coverEyes ? _cover.forward() : _cover.reverse();
    }
  }

  @override
  void dispose() {
    _coverCurve.dispose();
    for (final controller in [_sway, _idle, _wave, _cover, _shake]) {
      controller.dispose();
    }
    super.dispose();
  }

  /// 0 → 1 → 0 over one loop, eased (the CSS "ease-in-out" keyframes 0 %, 50 %, 100 %).
  static double _pingPong(double t) => (1 - math.cos(2 * math.pi * t)) / 2;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final picture = AnimatedBuilder(
      animation: Listenable.merge([_sway, _idle, _wave, _coverCurve, _shake]),
      builder: (context, _) {
        final idle = _idle.value;
        var dy = 0.0;
        var scaleX = 1.0;
        var scaleY = 1.0;
        switch (widget.idle) {
          case PipIdle.bob when _idle.isAnimating:
            dy = -6 * _pingPong(idle);
          case PipIdle.jump when _idle.isAnimating:
            (dy, scaleX, scaleY) = _jumpAt(idle);
          default:
            break;
        }
        final dx = _shake.isAnimating ? _shakeAt(_shake.value) : 0.0;

        return Transform.translate(
          offset: Offset(dx, dy),
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.diagonal3Values(scaleX, scaleY, 1),
            child: CustomPaint(
              size: Size.square(widget.size),
              painter: PipPainter(
                mood: widget.mood,
                swayDegrees: _sway.isAnimating ? -5 + 11 * _pingPong(_sway.value) : 0,
                cover: _coverCurve.value,
                waveDegrees: widget.wave
                    ? (_wave.isAnimating ? -25 + 45 * _pingPong(_wave.value) : -25)
                    : null,
                colors: colors,
              ),
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

  /// The jump keyframes: 0 % rest, 30 % up 18 px and stretched, 55 % landed and squashed,
  /// 70 % rest.
  static (double, double, double) _jumpAt(double t) {
    double lerp(double a, double b, double f) => a + (b - a) * Curves.easeInOut.transform(f);
    if (t < 0.3) {
      final f = t / 0.3;
      return (lerp(0, -18, f), lerp(1, 0.96, f), lerp(1, 1.04, f));
    }
    if (t < 0.55) {
      final f = (t - 0.3) / 0.25;
      return (lerp(-18, 0, f), lerp(0.96, 1.07, f), lerp(1.04, 0.93, f));
    }
    if (t < 0.7) {
      final f = (t - 0.55) / 0.15;
      return (0, lerp(1.07, 1, f), lerp(0.93, 1, f));
    }
    return (0, 1, 1);
  }

  /// The shake keyframes: x −9, +8, −5, +4, 0 at 20 % steps.
  static double _shakeAt(double t) {
    const stops = [0.0, -9.0, 8.0, -5.0, 4.0, 0.0];
    final scaled = t * (stops.length - 1);
    final i = scaled.floor().clamp(0, stops.length - 2);
    return stops[i] + (stops[i + 1] - stops[i]) * (scaled - i);
  }
}

/// Paints Pip on the README's 120×120 grid. Public for tests.
class PipPainter extends CustomPainter {
  const PipPainter({
    required this.mood,
    required this.swayDegrees,
    required this.cover,
    required this.waveDegrees,
    required this.colors,
  });

  final PipMood mood;

  /// Leaves' rotation around (60, 36).
  final double swayDegrees;

  /// 0 = hands down, 1 = covering the eyes (may overshoot with the springy curve).
  final double cover;

  /// The waving right hand's rotation, or null when not waving.
  final double? waveDegrees;
  final AppColors colors;

  static const grid = 120.0;
  static double _rad(double degrees) => degrees * math.pi / 180;

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..scale(size.width / grid);
    final ink = colors.pipInk;

    // Ground shadow.
    _oval(canvas, const Offset(60, 115), 28, 4, ink.withValues(alpha: 0.12));

    // Leaves (sway around the top of the head).
    canvas
      ..save()
      ..translate(60, 36)
      ..rotate(_rad(swayDegrees))
      ..translate(-60, -36);
    canvas.drawLine(const Offset(60, 37), const Offset(60, 21), _stroke(colors.leafDeep, 4));
    _oval(canvas, const Offset(50, 19), 11, 6, colors.leaf, degrees: 30);
    _oval(canvas, const Offset(71, 14), 13, 7, colors.leaf, degrees: -30);
    canvas.restore();

    // Body, belly, cheeks.
    _oval(canvas, const Offset(60, 72), 42, 40, colors.mascot);
    _oval(canvas, const Offset(60, 87), 25, 17, colors.pipShine.withValues(alpha: 0.25));
    final cheek = colors.cheek.withValues(alpha: 0.85);
    _oval(canvas, const Offset(33, 79), 6.5, 3.8, cheek);
    _oval(canvas, const Offset(87, 79), 6.5, 3.8, cheek);

    _face(canvas, ink);

    // Hands: left always; right waves or mirrors the left.
    final hand = colors.mascotDeep;
    _oval(canvas, Offset(20 + 25 * cover, 88 - 22 * cover), 11, 8.5, hand);
    final wave = waveDegrees;
    if (wave == null) {
      _oval(canvas, Offset(100 - 25 * cover, 88 - 22 * cover), 11, 8.5, hand);
    } else {
      // Lifted (+2, −32) and swung around the hand's bottom-left corner (89, 96.5).
      canvas
        ..save()
        ..translate(89 + 2, 96.5 - 32)
        ..rotate(_rad(wave))
        ..translate(-89, -96.5);
      _oval(canvas, const Offset(100, 88), 11, 8.5, hand);
      canvas.restore();
    }
    canvas.restore();
  }

  void _face(Canvas canvas, Color ink) {
    final fill = Paint()..color = ink;
    final shine = Paint()..color = colors.pipShine;
    void eye(double x, double y, double r, double hx, double hy, double hr) {
      canvas
        ..drawCircle(Offset(x, y), r, fill)
        ..drawCircle(Offset(hx, hy), hr, shine);
    }

    Path curve(double x0, double y0, double cx, double cy, double x1, double y1) => Path()
      ..moveTo(x0, y0)
      ..quadraticBezierTo(cx, cy, x1, y1);

    switch (mood) {
      case PipMood.happy:
        canvas
          ..drawPath(curve(38, 68, 45, 59, 52, 68), _stroke(ink, 4))
          ..drawPath(curve(68, 68, 75, 59, 82, 68), _stroke(ink, 4));
        final mouth = curve(49, 79, 60, 95, 71, 79)..close();
        canvas
          ..drawPath(mouth, fill)
          ..drawPath(mouth, _stroke(ink, 3));
      case PipMood.worried:
        eye(45, 68, 6, 46.8, 66, 2);
        eye(75, 68, 6, 76.8, 66, 2);
        canvas
          ..drawLine(const Offset(37, 60), const Offset(50, 55), _stroke(ink, 3.5))
          ..drawLine(const Offset(83, 60), const Offset(70, 55), _stroke(ink, 3.5))
          ..drawPath(curve(52, 87, 60, 80, 68, 87), _stroke(ink, 3.5));
      case PipMood.think:
        eye(48, 62, 6.5, 49.6, 59.4, 2.2);
        eye(78, 62, 6.5, 79.6, 59.4, 2.2);
        canvas.drawPath(curve(55, 83, 61, 80, 67, 84), _stroke(ink, 3.5));
      case PipMood.normal:
        eye(45, 66, 6.5, 47.2, 63.6, 2.3);
        eye(75, 66, 6.5, 77.2, 63.6, 2.3);
        canvas.drawPath(curve(52, 80, 60, 88, 68, 80), _stroke(ink, 3.5));
    }
  }

  static Paint _stroke(Color color, double width) => Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  static void _oval(
    Canvas canvas,
    Offset center,
    double rx,
    double ry,
    Color color, {
    double degrees = 0,
  }) {
    canvas
      ..save()
      ..translate(center.dx, center.dy)
      ..rotate(_rad(degrees))
      ..drawOval(
        Rect.fromCenter(center: Offset.zero, width: rx * 2, height: ry * 2),
        Paint()..color = color,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(PipPainter old) =>
      old.mood != mood ||
      old.swayDegrees != swayDegrees ||
      old.cover != cover ||
      old.waveDegrees != waveDegrees ||
      old.colors != colors;
}
