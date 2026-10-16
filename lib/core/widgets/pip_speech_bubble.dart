import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/extensions/reduce_motion.dart';
import 'package:expense_tracker/core/theme/app_curves.dart';
import 'package:expense_tracker/core/theme/app_durations.dart';
import 'package:expense_tracker/core/theme/app_radius.dart';
import 'package:expense_tracker/core/theme/app_sizes.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// What Pip says, next to him (README §Core components 7): surface, 2 px `line` border, radius 18
/// and a tail on the left pointing at Pip. Pops in when [text] changes (instant with reduce
/// motion); screen readers hear the new text.
class PipSpeechBubble extends StatelessWidget {
  const PipSpeechBubble({super.key, required this.text});

  final String text;

  static const tailSize = 10.0;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final line = context.colors.line;
    final bubble = CustomPaint(
      painter: _BubblePainter(fill: scheme.surfaceContainerLowest, border: line),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          tailSize + AppSpacing.s14,
          AppSpacing.s10,
          AppSpacing.s14,
          AppSpacing.s10,
        ),
        child: Text(text, style: context.text.titleSmall?.copyWith(color: scheme.onSurface)),
      ),
    );

    return Semantics(
      liveRegion: true,
      child: TweenAnimationBuilder<double>(
        key: ValueKey(text),
        tween: Tween(begin: context.reduceMotion ? 1 : 0.6, end: 1),
        duration: context.reduceMotion ? Duration.zero : AppDurations.pop,
        curve: AppCurves.elastic,
        builder: (context, scale, child) =>
            Transform.scale(scale: scale, alignment: Alignment.centerLeft, child: child),
        child: bubble,
      ),
    );
  }
}

/// A rounded rectangle with a small tail on the left edge, filled and outlined.
class _BubblePainter extends CustomPainter {
  const _BubblePainter({required this.fill, required this.border});

  final Color fill;
  final Color border;

  @override
  void paint(Canvas canvas, Size size) {
    const tail = PipSpeechBubble.tailSize;
    const inset = AppSizes.chunkyBorder / 2;
    final body = RRect.fromLTRBR(
      tail + inset,
      inset,
      size.width - inset,
      size.height - inset,
      const Radius.circular(AppRadius.field),
    );
    final midY = size.height / 2;
    final path = Path()
      ..addRRect(body)
      ..moveTo(tail + inset + 1, midY - tail * 0.8)
      ..lineTo(inset, midY)
      ..lineTo(tail + inset + 1, midY + tail * 0.8)
      ..close();
    final outline = Path.combine(
      PathOperation.union,
      Path()..addRRect(body),
      Path()
        ..moveTo(tail + inset + 1, midY - tail * 0.8)
        ..lineTo(inset, midY)
        ..lineTo(tail + inset + 1, midY + tail * 0.8)
        ..close(),
    );
    canvas
      ..drawPath(path, Paint()..color = fill)
      ..drawPath(
        outline,
        Paint()
          ..color = border
          ..style = PaintingStyle.stroke
          ..strokeWidth = AppSizes.chunkyBorder,
      );
  }

  @override
  bool shouldRepaint(_BubblePainter old) => old.fill != fill || old.border != border;
}
