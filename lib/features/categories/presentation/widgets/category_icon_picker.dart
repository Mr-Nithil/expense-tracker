import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/widgets/category_icon.dart';
import 'package:expense_tracker/features/categories/presentation/widgets/selectable_circle.dart';
import 'package:flutter/material.dart';

/// Grid of every known category icon, drawn in the current [color].
class CategoryIconPicker extends StatelessWidget {
  const CategoryIconPicker({
    super.key,
    required this.selected,
    required this.color,
    required this.onChanged,
  });

  final String selected;
  final int color;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final keys = CategoryIcon.keys.toList();
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        for (final (index, key) in keys.indexed)
          SelectableCircle(
            selected: key == selected,
            semanticLabel: context.l10n.categoryFormIconOption(index + 1, keys.length),
            onTap: onChanged == null ? null : () => onChanged!(key),
            child: CategoryIcon(iconKey: key, color: color),
          ),
      ],
    );
  }
}
