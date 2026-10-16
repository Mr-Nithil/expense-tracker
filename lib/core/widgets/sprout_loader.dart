import 'dart:math' as math;

import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/extensions/reduce_motion.dart';
import 'package:expense_tracker/core/theme/app_durations.dart';
import 'package:expense_tracker/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';

/// The app's loading indicator (README §Core components 3): a sprout grows from the soil, its
/// two leaves pop out, then it fades and grows again (1.8 s loop). Use instead of a raw
/// `CircularProgressIndicator`.
///
/// Sizes: [AppSizes.loaderPage], [AppSizes.loaderSplash], [AppSizes.loaderButton] (pass
/// `onPrimary` as [color]), [AppSizes.loaderTyping]. With reduce motion on it stands still, fully
/// grown. Decorative unless [semanticsLabel] is given.
class SproutLoader extends StatefulWidget {
  const SproutLoader({
    super.key,
    this.size = AppSizes.loaderPage,
    this.color,
    this.semanticsLabel,
  });

  final double size;

  /// Defaults to the primary color.
  final Color? color;

  /// E.g. "Loading". Without it, screen readers skip the loader.
  final String? semanticsLabel;

  @override
  State<SproutLoader> createState() => _SproutLoaderState();
}

class _SproutLoaderState extends State<SproutLoader> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(vsync: this, duration: AppDurations.loaderLoop);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (context.reduceMotion) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? context.colorScheme.primary;
    final still = context.reduceMotion;
    final loader = SizedBox.square(
      dimension: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          painter: SproutLoaderPainter(color: color, t: still ? null : _controller.value),
        ),
      ),
    );
    final label = widget.semanticsLabel;
    if (label == null) return ExcludeSemantics(child: loader);
    return Semantics(
      label: label,
      image: true,
      child: ExcludeSemantics(child: loader),
    );
  }
}

/// Paints the loader at loop time [t] (0..1), in the design's 48×48 box scaled to the canvas.
/// A null [t] paints the still, fully grown sprout (reduce motion).
class SproutLoaderPainter extends CustomPainter {
  const SproutLoaderPainter({required this.color, required this.t});

  final Color color;
  final double? t;

  static const _box = 48.0;
  static const _stemLength = 18.0;
  static const _leafOrigin = Offset(24, 25);

  /// The stem's drawn length (CSS: dash 20, offset 20 → 0 over 0–32 %, ease-out).
  static double stemLength(double? t) {
    if (t == null) return _stemLength;
    final offset = 20 * (1 - Curves.easeOut.transform((t / 0.32).clamp(0.0, 1.0)));
    return (20 - offset).clamp(0.0, _stemLength);
  }

  /// A leaf's scale: 0 until [start], up to 1.2 at [start] + 18 %, settles to 1 at + 28 %.
  static double leafScale(double? t, double start) {
    if (t == null) return 1;
    final peak = start + 0.18;
    final settle = start + 0.28;
    if (t <= start) return 0;
    if (t <= peak) return 1.2 * Curves.easeInOut.transform((t - start) / (peak - start));
    if (t <= settle) return 1.2 - 0.2 * Curves.easeInOut.transform((t - peak) / (settle - peak));
    return 1;
  }

  /// The whole sprout's opacity: 1 until 80 %, 0 from 95 %.
  static double opacity(double? t) {
    if (t == null || t <= 0.8) return 1;
    if (t >= 0.95) return 0;
    return 1 - Curves.easeInOut.transform((t - 0.8) / 0.15);
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..scale(size.width / _box, size.height / _box);
    final fill = Paint()..color = color;

    _ellipse(
      canvas,
      const Offset(24, 43),
      11,
      2.6,
      0,
      Paint()..color = color.withValues(alpha: .3),
    );

    final alpha = opacity(t);
    if (alpha > 0) {
      canvas.saveLayer(
        const Rect.fromLTWH(0, 0, _box, _box),
        Paint()..color = Color.fromRGBO(0, 0, 0, alpha),
      );
      final length = stemLength(t);
      if (length > 0) {
        canvas.drawLine(
          const Offset(24, 43),
          Offset(24, 43 - length),
          Paint()
            ..color = color
            ..strokeWidth = 3.5
            ..strokeCap = StrokeCap.round,
        );
      }
      _leaf(canvas, leafScale(t, 0.28), const Offset(17, 22.5), 7.5, 4.2, 30, fill);
      _leaf(canvas, leafScale(t, 0.40), const Offset(31.5, 19.5), 8.5, 4.8, -30, fill);
      canvas.restore();
    }
    canvas.restore();
  }

  static void _leaf(
    Canvas canvas,
    double scale,
    Offset center,
    double rx,
    double ry,
    double degrees,
    Paint paint,
  ) {
    if (scale <= 0) return;
    canvas
      ..save()
      ..translate(_leafOrigin.dx, _leafOrigin.dy)
      ..scale(scale)
      ..translate(-_leafOrigin.dx, -_leafOrigin.dy);
    _ellipse(canvas, center, rx, ry, degrees, paint);
    canvas.restore();
  }

  static void _ellipse(
    Canvas canvas,
    Offset center,
    double rx,
    double ry,
    double degrees,
    Paint paint,
  ) {
    canvas
      ..save()
      ..translate(center.dx, center.dy)
      ..rotate(degrees * math.pi / 180)
      ..drawOval(Rect.fromCenter(center: Offset.zero, width: rx * 2, height: ry * 2), paint)
      ..restore();
  }

  @override
  bool shouldRepaint(SproutLoaderPainter old) => old.color != color || old.t != t;
}
