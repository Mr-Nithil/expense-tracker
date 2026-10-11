import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';

/// One round option in a picker: a 48dp tap target with a ring when [selected], announced to
/// screen readers as a selectable button with [semanticLabel].
class SelectableCircle extends StatelessWidget {
  const SelectableCircle({
    super.key,
    required this.selected,
    required this.semanticLabel,
    required this.onTap,
    required this.child,
  });

  final bool selected;
  final String semanticLabel;
  final VoidCallback? onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: semanticLabel,
      // Excluding the child's semantics also drops the InkWell's tap action, so provide it here.
      onTap: onTap,
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: AppSizes.minTapTarget,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? context.colorScheme.primary : Colors.transparent,
                width: AppSizes.selectionBorder,
              ),
            ),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}
