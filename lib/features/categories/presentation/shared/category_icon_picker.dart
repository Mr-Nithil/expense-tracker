import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/widgets/category_icon.dart';
import 'package:expense_tracker/core/widgets/category_tile.dart';
import 'package:flutter/material.dart';

/// Grid of every known category icon as Sprout [CategoryTile]s. [color] is the category's color,
/// shown by the form's preview, not by the tiles.
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
      spacing: AppSpacing.s10,
      runSpacing: AppSpacing.s6,
      children: [
        for (final (index, key) in keys.indexed)
          CategoryTile(
            icon: CategoryIcon.iconFor(key),
            selected: key == selected,
            semanticLabel: context.l10n.categoryFormIconOption(index + 1, keys.length),
            onTap: onChanged == null ? null : () => onChanged!(key),
          ),
      ],
    );
  }
}
