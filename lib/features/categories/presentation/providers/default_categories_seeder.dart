import 'dart:ui';

import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/l10n/generated/app_localizations.dart';
import 'package:expense_tracker/core/l10n/l10n_lookup.dart';
import 'package:expense_tracker/core/l10n/locale_controller.dart';
import 'package:expense_tracker/features/categories/data/category_repository_provider.dart';
import 'package:expense_tracker/features/categories/domain/category_repository.dart';
import 'package:expense_tracker/features/categories/domain/services/default_categories.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'default_categories_seeder.g.dart';

/// Seeds the default categories with names in the app's language. The categories feature's
/// entry point for onboarding (ARCHITECTURE §3, cross-feature UI).
class DefaultCategoriesSeeder {
  DefaultCategoriesSeeder({required this.repository, required this.l10n});

  final CategoryRepository repository;
  final AppLocalizations l10n;

  /// Safe to call repeatedly; returns how many categories were added.
  Future<Result<int>> seed() => repository.seedDefaults([
    for (final spec in DefaultCategories.all)
      DefaultCategorySeed(spec: spec, name: nameOf(l10n, spec.key)),
  ]);

  /// The localized name of a default category. Throws for a key without a name (caught by tests).
  static String nameOf(AppLocalizations l10n, String key) => switch (key) {
    'food' => l10n.categoryDefaultFood,
    'transport' => l10n.categoryDefaultTransport,
    'bills' => l10n.categoryDefaultBills,
    'shopping' => l10n.categoryDefaultShopping,
    'health' => l10n.categoryDefaultHealth,
    'entertainment' => l10n.categoryDefaultEntertainment,
    'education' => l10n.categoryDefaultEducation,
    'other' => l10n.categoryDefaultOther,
    'salary' => l10n.categoryDefaultSalary,
    'freelance' => l10n.categoryDefaultFreelance,
    'gifts' => l10n.categoryDefaultGifts,
    'investments' => l10n.categoryDefaultInvestments,
    'other_income' => l10n.categoryDefaultOtherIncome,
    _ => throw ArgumentError.value(key, 'key', 'Default category without a name'),
  };
}

@Riverpod(keepAlive: true)
DefaultCategoriesSeeder defaultCategoriesSeeder(Ref ref) => DefaultCategoriesSeeder(
  repository: ref.watch(categoryRepositoryProvider),
  l10n: appLocalizationsFor(
    ref.watch(localeControllerProvider).value,
    device: PlatformDispatcher.instance.locale,
  ),
);
