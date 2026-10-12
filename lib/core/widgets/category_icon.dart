import 'package:expense_tracker/core/theme/app_sizes.dart';
import 'package:expense_tracker/core/theme/contrast.dart';
import 'package:flutter/material.dart';

/// A category's icon in a circle tinted with its color (the glyph is adjusted for contrast). Use wherever a category is shown
/// (lists, pickers, transactions). Decorative: the surrounding row provides the label.
///
/// Takes plain values (icon key + ARGB color) because core never imports features.
class CategoryIcon extends StatelessWidget {
  const CategoryIcon({
    super.key,
    required this.iconKey,
    required this.color,
    this.size = AppSizes.avatarMd,
  });

  /// Stored key, e.g. `food`. Unknown keys show [fallback].
  final String iconKey;

  /// ARGB value from the category row.
  final int color;

  /// Diameter of the circle.
  final double size;

  /// Background tint strength. The icon itself uses the full color.
  static const _tintAlpha = 0.16;

  /// Icon size relative to the circle.
  static const _iconScale = 0.55;

  static const fallback = Icons.category_outlined;

  static const _icons = <String, IconData>{
    // Default categories (M2.2).
    'food': Icons.restaurant_outlined,
    'transport': Icons.directions_bus_outlined,
    'bills': Icons.receipt_long_outlined,
    'shopping': Icons.shopping_bag_outlined,
    'health': Icons.favorite_outline,
    'entertainment': Icons.movie_outlined,
    'education': Icons.school_outlined,
    'other': Icons.more_horiz,
    'salary': Icons.work_outline,
    'freelance': Icons.laptop_mac_outlined,
    'gifts': Icons.card_giftcard_outlined,
    'investments': Icons.trending_up,
    'other_income': Icons.add_card_outlined,
    // Extra choices for custom categories (picker, M2.4).
    'home': Icons.home_outlined,
    'groceries': Icons.local_grocery_store_outlined,
    'coffee': Icons.local_cafe_outlined,
    'fuel': Icons.local_gas_station_outlined,
    'travel': Icons.flight_outlined,
    'pets': Icons.pets_outlined,
    'kids': Icons.child_care_outlined,
    'sports': Icons.fitness_center_outlined,
    'phone': Icons.smartphone_outlined,
    'subscriptions': Icons.subscriptions_outlined,
    'savings': Icons.savings_outlined,
  };

  /// Every known key, in picker order.
  static Iterable<String> get keys => _icons.keys;

  static IconData iconFor(String key) => _icons[key] ?? fallback;

  @override
  Widget build(BuildContext context) {
    final tint = Color(color);
    final background = tint.withValues(alpha: _tintAlpha);
    // The stored color is shared by both themes: draw the glyph at 3:1 at least against its
    // circle on the darkest light / lightest dark surface, so it stays visible in both.
    final glyph = Contrast.ensure(
      tint,
      on: Color.alphaBlend(background, Theme.of(context).colorScheme.surfaceContainerHighest),
    );
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: background,
        ),
        child: Icon(iconFor(iconKey), color: glyph, size: size * _iconScale),
      ),
    );
  }
}
