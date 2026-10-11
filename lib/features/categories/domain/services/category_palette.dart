import 'package:expense_tracker/features/categories/domain/services/default_categories.dart';

/// Colors offered by the category color picker (M2.4). ARGB values stored on the row, so data
/// rather than theme tokens. Contains every default category's color, so editing a default shows
/// its color as selected.
abstract final class CategoryPalette {
  static final colors = <int>[
    for (final spec in DefaultCategories.all) spec.color,
    0xFFFDD835, // yellow
    0xFF00ACC1, // cyan
    0xFF7CB342, // light green
  ];
}
