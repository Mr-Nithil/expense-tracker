// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_repository_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The category repository, exposed as its interface.

@ProviderFor(categoryRepository)
final categoryRepositoryProvider = CategoryRepositoryProvider._();

/// The category repository, exposed as its interface.

final class CategoryRepositoryProvider
    extends $FunctionalProvider<CategoryRepository, CategoryRepository, CategoryRepository>
    with $Provider<CategoryRepository> {
  /// The category repository, exposed as its interface.
  CategoryRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoryRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoryRepositoryHash();

  @$internal
  @override
  $ProviderElement<CategoryRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CategoryRepository create(Ref ref) {
    return categoryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CategoryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CategoryRepository>(value),
    );
  }
}

String _$categoryRepositoryHash() => r'd6a6bd86259c08ed90db5207f84060f12eda7035';
