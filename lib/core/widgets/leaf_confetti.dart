import 'dart:math' as math;

import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/extensions/reduce_motion.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Celebration confetti (README §Core components 10): 18 small leaves falling and turning over
/// the whole area, staggered, looping while shown. Put it in a `Stack` over the content; it
/// ignores touches and screen readers. Nothing is drawn with reduce motion.
class LeafConfetti extends StatefulWidget {
  const LeafConfetti({super.key});

  @override
  State<LeafConfetti> createState() => _LeafConfettiState();
}

class _LeafConfettiState extends State<LeafConfetti> with SingleTickerProviderStateMixin {
  late final Ticker _ticker = createTicker((elapsed) => _elapsed.value = elapsed);
  final _elapsed = ValueNotifier(Duration.zero);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (context.reduceMotion) {
      if (_ticker.isActive) _ticker.stop();
    } else if (!_ticker.isActive) {
      _ticker.start();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _elapsed.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (context.reduceMotion) return const SizedBox.expand();
    final colors = context.colors;
    return IgnorePointer(
      child: ExcludeSemantics(
        child: ClipRect(
          child: CustomPaint(
            size: Size.infinite,
            painter: LeafConfettiPainter(
              elapsed: _elapsed,
              palette: [colors.leaf, colors.mascot, colors.accent, context.colorScheme.primary],
            ),
          ),
        ),
      ),
    );
  }
}

/// Where one confetti leaf is: [x] as a share of the width, [y] in px, [degrees], [opacity].
typedef ConfettiLeaf = ({double x, double y, double degrees, double opacity});

/// Paints [LeafConfetti] at the time in [elapsed]. Public for tests.
class LeafConfettiPainter extends CustomPainter {
  LeafConfettiPainter({required this.elapsed, required this.palette}) : super(repaint: elapsed);

  final ValueListenable<Duration> elapsed;

  /// Leaf colors, used in turn.
  final List<Color> palette;

  static const count = 18;
  static const leafSize = Size(12, 7);

  /// Leaves start just above the top. They fall through the painter's height (the design's
  /// 780 px is a phone screen).
  static const _start = -30.0;

  /// Leaf [i] at [elapsed], falling to [fall] px; null while it waits for its first start.
  static ConfettiLeaf? leafAt(int i, Duration elapsed, double fall) {
    final delay = (i % 7) * 0.3;
    final duration = 2.6 + (i % 5) * 0.45;
    final local = elapsed.inMicroseconds / Duration.microsecondsPerSecond - delay;
    if (local < 0) return null;
    final t = (local % duration) / duration;
    final eased = Curves.easeIn.transform(t);
    final opacity = t < 0.1
        ? Curves.easeIn.transform(t / 0.1)
        : 1 - 0.1 * Curves.easeIn.transform((t - 0.1) / 0.9);
    return (
      x: ((i * 53 + 7) % 100) / 100,
      y: _start + (fall - _start) * eased,
      degrees: 620 * eased,
      opacity: opacity,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final now = elapsed.value;
    final round = Radius.elliptical(leafSize.width, leafSize.height);
    final shape = RRect.fromRectAndCorners(
      Offset.zero & leafSize,
      topRight: round,
      bottomLeft: round,
    );
    for (var i = 0; i < count; i++) {
      final leaf = leafAt(i, now, size.height);
      if (leaf == null) continue;
      canvas
        ..save()
        ..translate(leaf.x * size.width + leafSize.width / 2, leaf.y + leafSize.height / 2)
        ..rotate(leaf.degrees * math.pi / 180)
        ..translate(-leafSize.width / 2, -leafSize.height / 2)
        ..drawRRect(
          shape,
          Paint()..color = palette[i % palette.length].withValues(alpha: leaf.opacity),
        )
        ..restore();
    }
  }

  @override
  bool shouldRepaint(LeafConfettiPainter old) => old.palette != palette;
}
