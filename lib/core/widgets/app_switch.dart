import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/extensions/reduce_motion.dart';
import 'package:expense_tracker/core/theme/app_curves.dart';
import 'package:expense_tracker/core/theme/app_durations.dart';
import 'package:expense_tracker/core/theme/app_radius.dart';
import 'package:expense_tracker/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';

/// The Sprout switch: a 52×32 track (`primary` on, `line` off) with a 26 px knob that springs
/// across. Tap area 52×48. A null [onChanged] disables it. Label it with [semanticsLabel], or use
/// [AppSwitchTile].
class AppSwitch extends StatelessWidget {
  const AppSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.semanticsLabel,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;

  /// What the switch turns on or off, for screen readers (not needed inside [AppSwitchTile]).
  final String? semanticsLabel;

  static const _trackWidth = 52.0;
  static const _trackHeight = 32.0;
  static const _knob = 26.0;
  static const _disabledOpacity = 0.5;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final onChanged = this.onChanged;
    final toggle = onChanged == null ? null : () => onChanged(!value);
    final duration = context.reduceMotion ? Duration.zero : AppDurations.pop;

    // One node: label, on/off state and the tap action (the detector adds none of its own).
    return Semantics(
      container: true,
      label: semanticsLabel,
      toggled: value,
      enabled: onChanged != null,
      onTap: toggle,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: toggle,
        child: Opacity(
          opacity: onChanged == null ? _disabledOpacity : 1,
          child: SizedBox(
            width: _trackWidth,
            height: AppSizes.minTapTarget,
            child: Center(
              child: AnimatedContainer(
                duration: duration,
                width: _trackWidth,
                height: _trackHeight,
                padding: const EdgeInsets.all((_trackHeight - _knob) / 2),
                decoration: BoxDecoration(
                  color: value ? scheme.primary : context.colors.line,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: AnimatedAlign(
                  duration: duration,
                  curve: AppCurves.elastic,
                  alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    width: _knob,
                    height: _knob,
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerLowest,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A settings row with an [AppSwitch]: optional leading [secondary], [title], optional
/// [subtitle]. Tapping anywhere on the row toggles it; read out as one toggle.
class AppSwitchTile extends StatelessWidget {
  const AppSwitchTile({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.secondary,
  });

  final Widget title;
  final Widget? subtitle;
  final Widget? secondary;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final onChanged = this.onChanged;
    return MergeSemantics(
      child: ListTile(
        leading: secondary,
        title: title,
        subtitle: subtitle,
        enabled: onChanged != null,
        onTap: onChanged == null ? null : () => onChanged(!value),
        trailing: AppSwitch(value: value, onChanged: onChanged),
      ),
    );
  }
}
