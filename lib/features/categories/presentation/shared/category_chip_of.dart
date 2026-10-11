import 'package:expense_tracker/core/widgets/category_chip.dart';
import 'package:expense_tracker/features/categories/domain/entities/category.dart';
// Not the whole library: foundation also exports an annotation named `Category`.
import 'package:flutter/foundation.dart' show VoidCallback;

/// The core [CategoryChip] for [category]: archived categories are marked, and `null` (not on
/// this device) shows as unknown. Use this instead of mapping a `Category` by hand.
CategoryChip categoryChipOf(Category? category, {bool selected = false, VoidCallback? onTap}) =>
    category == null
    ? CategoryChip.unknown(selected: selected, onTap: onTap)
    : CategoryChip(
        label: category.name,
        iconKey: category.icon,
        color: category.color,
        isArchived: category.isArchived,
        selected: selected,
        onTap: onTap,
      );
