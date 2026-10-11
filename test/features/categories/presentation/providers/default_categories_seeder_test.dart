import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/l10n/generated/app_localizations_en.dart';
import 'package:expense_tracker/features/categories/domain/category_repository.dart';
import 'package:expense_tracker/features/categories/domain/services/default_categories.dart';
import 'package:expense_tracker/features/categories/presentation/providers/default_categories_seeder.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockCategoryRepository extends Mock implements CategoryRepository {}

void main() {
  final l10n = AppLocalizationsEn();

  test('every default category has a localized name', () {
    for (final spec in DefaultCategories.all) {
      expect(DefaultCategoriesSeeder.nameOf(l10n, spec.key), isNotEmpty, reason: spec.key);
    }
    expect(() => DefaultCategoriesSeeder.nameOf(l10n, 'unknown'), throwsArgumentError);
  });

  test('seeds all defaults with their names', () async {
    final repository = _MockCategoryRepository();
    when(() => repository.seedDefaults(any())).thenAnswer((_) async => const Result.success(13));

    final result = await DefaultCategoriesSeeder(repository: repository, l10n: l10n).seed();

    expect(result.valueOrNull, 13);
    final seeds =
        verify(() => repository.seedDefaults(captureAny())).captured.single
            as List<DefaultCategorySeed>;
    expect(seeds.map((s) => s.spec.key), DefaultCategories.all.map((s) => s.key));
    expect(seeds.first.name, l10n.categoryDefaultFood);
  });
}
