import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/extensions/reduce_motion.dart';
import 'package:expense_tracker/core/theme/app_durations.dart';
import 'package:expense_tracker/core/theme/app_radius.dart';
import 'package:expense_tracker/core/theme/app_sizes.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// One choice of a [SegmentedPill].
class SegmentedPillOption<T> {
  const SegmentedPillOption({required this.value, required this.label, this.icon});

  final T value;
  final String label;
  final IconData? icon;
}

/// The Sprout segmented control: a `field` track; the selected segment is `surface` with a 2 px
/// `line` bottom shadow. Use for 2–4 mutually exclusive choices (type, theme, repeat, Plan tabs).
/// A null [onChanged] disables it. At least 48 px tall (tap targets), growing with the text.
class SegmentedPill<T> extends StatelessWidget {
  const SegmentedPill({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final List<SegmentedPillOption<T>> options;
  final T selected;
  final ValueChanged<T>? onChanged;

  static const _trackPadding = AppSpacing.xs;
  static const _selectedShadow = 2.0;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final colors = context.colors;
    final duration = context.reduceMotion ? Duration.zero : AppDurations.short;
    final onChanged = this.onChanged;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.field,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final option in options)
              Expanded(
                child: () {
                  final isSelected = option.value == selected;
                  final foreground = isSelected ? scheme.onSurface : scheme.onSurfaceVariant;
                  // The whole 48 px cell is the tap target; the visible pill is inset in it.
                  return Semantics(
                    button: true,
                    selected: isSelected,
                    inMutuallyExclusiveGroup: true,
                    enabled: onChanged != null,
                    child: Material(
                      type: MaterialType.transparency,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        onTap: onChanged == null || isSelected
                            ? null
                            : () => onChanged(option.value),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: AppSizes.minTapTarget),
                          child: Padding(
                            padding: const EdgeInsets.all(_trackPadding),
                            child: AnimatedContainer(
                              duration: duration,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isSelected ? scheme.surfaceContainerLowest : null,
                                borderRadius: BorderRadius.circular(AppRadius.pill),
                                boxShadow: [
                                  if (isSelected)
                                    BoxShadow(
                                      color: colors.line,
                                      offset: const Offset(0, _selectedShadow),
                                    ),
                                ],
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.s10,
                                vertical: AppSpacing.xs,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (option.icon case final icon?) ...[
                                    Icon(icon, size: AppSizes.iconSm, color: foreground),
                                    const Gap(AppSpacing.s6),
                                  ],
                                  Flexible(
                                    child: Text(
                                      option.label,
                                      textAlign: TextAlign.center,
                                      style: context.text.titleSmall?.copyWith(color: foreground),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }(),
              ),
          ],
        ),
      ),
    );
  }
}
