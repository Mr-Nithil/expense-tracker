import 'package:expense_tracker/core/utils/id.dart';
import 'package:expense_tracker/features/categories/domain/entities/category.dart';

/// A built-in category. [key] is stable: it derives the row id and doubles as the icon key.
class DefaultCategorySpec {
  const DefaultCategorySpec(this.key, this.type, this.color);

  final String key;
  final CategoryType type;

  /// ARGB. Stored as data on the row (users can recolor), so not a theme token.
  final int color;

  String get icon => key;
}

/// A [DefaultCategorySpec] with its localized name, ready to store.
class DefaultCategorySeed {
  const DefaultCategorySeed({required this.spec, required this.name});

  final DefaultCategorySpec spec;
  final String name;
}

/// The categories every user starts with (seeded at onboarding, M2.2).
abstract final class DefaultCategories {
  /// Both timestamps of seeded rows. Deliberately old, so with last-write-wins sync any real edit
  /// (e.g. a rename on another device) beats a later seed of the same row.
  static final seedTimestamp = DateTime.utc(2000);

  static const all = [
    DefaultCategorySpec('food', CategoryType.expense, 0xFFEF6C00),
    DefaultCategorySpec('transport', CategoryType.expense, 0xFF1E88E5),
    DefaultCategorySpec('bills', CategoryType.expense, 0xFF8E24AA),
    DefaultCategorySpec('shopping', CategoryType.expense, 0xFFD81B60),
    DefaultCategorySpec('health', CategoryType.expense, 0xFF43A047),
    DefaultCategorySpec('entertainment', CategoryType.expense, 0xFFF4511E),
    DefaultCategorySpec('education', CategoryType.expense, 0xFF3949AB),
    DefaultCategorySpec('other', CategoryType.expense, 0xFF757575),
    DefaultCategorySpec('salary', CategoryType.income, 0xFF2E7D32),
    DefaultCategorySpec('freelance', CategoryType.income, 0xFF00897B),
    DefaultCategorySpec('gifts', CategoryType.income, 0xFFC2185B),
    DefaultCategorySpec('investments', CategoryType.income, 0xFF6D4C41),
    DefaultCategorySpec('other_income', CategoryType.income, 0xFF546E7A),
  ];

  /// The same on every device, so two devices seeding offline converge on one row per default.
  static String idFor(String userId, String key) =>
      IdGenerator.deterministic(['category', userId, key]);
}
