import 'package:expense_tracker/core/extensions/reduce_motion.dart';
import 'package:expense_tracker/core/theme/app_durations.dart';
import 'package:expense_tracker/core/theme/app_sizes.dart';
import 'package:flutter/widgets.dart';

/// The Sprout "chunky 3D" look: a solid bottom shadow (no blur) under [child], which sinks into it
/// while pressed. Wrap buttons, cards and other tappable surfaces with it.
///
/// It only watches the pointer and never handles the tap: [child] keeps its own tap handling,
/// semantics and focus. The shadow occupies [depth] below the child, so the layout doesn't jump.
class ChunkyPressable extends StatefulWidget {
  const ChunkyPressable({
    super.key,
    required this.child,
    required this.shadowColor,
    required this.radius,
    this.depth = AppSizes.chunkyDepth,
    this.enabled = true,
  });

  final Widget child;
  final Color shadowColor;
  final BorderRadius radius;
  final double depth;

  /// Disabled: flat (no shadow) and doesn't move.
  final bool enabled;

  @override
  State<ChunkyPressable> createState() => _ChunkyPressableState();
}

class _ChunkyPressableState extends State<ChunkyPressable> {
  var _pressed = false;

  void _set(bool pressed) {
    if (_pressed != pressed && mounted) setState(() => _pressed = pressed);
  }

  @override
  Widget build(BuildContext context) {
    final down = widget.enabled && _pressed;
    final lifted = widget.enabled && !_pressed;
    return Listener(
      onPointerDown: widget.enabled ? (_) => _set(true) : null,
      onPointerUp: (_) => _set(false),
      onPointerCancel: (_) => _set(false),
      child: Padding(
        padding: EdgeInsets.only(bottom: widget.depth),
        child: AnimatedContainer(
          duration: context.reduceMotion ? Duration.zero : AppDurations.press,
          transform: Matrix4.translationValues(0, down ? widget.depth : 0, 0),
          decoration: BoxDecoration(
            borderRadius: widget.radius,
            boxShadow: [
              if (lifted) BoxShadow(color: widget.shadowColor, offset: Offset(0, widget.depth)),
            ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
