// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'categories_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Active categories of [type] in display order. Re-subscribes when the signed-in user changes.

@ProviderFor(categories)
final categoriesProvider = CategoriesFamily._();

/// Active categories of [type] in display order. Re-subscribes when the signed-in user changes.

final class CategoriesProvider
    extends $FunctionalProvider<AsyncValue<List<Category>>, List<Category>, Stream<List<Category>>>
    with $FutureModifier<List<Category>>, $StreamProvider<List<Category>> {
  /// Active categories of [type] in display order. Re-subscribes when the signed-in user changes.
  CategoriesProvider._({
    required CategoriesFamily super.from,
    required CategoryType super.argument,
  }) : super(
         retry: null,
         name: r'categoriesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$categoriesHash();

  @override
  String toString() {
    return r'categoriesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Category>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Category>> create(Ref ref) {
    final argument = this.argument as CategoryType;
    return categories(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CategoriesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$categoriesHash() => r'8bbabc3ac4f24d1fe91df9ac9c8b0dafaf616b32';

/// Active categories of [type] in display order. Re-subscribes when the signed-in user changes.

final class CategoriesFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Category>>, CategoryType> {
  CategoriesFamily._()
    : super(
        retry: null,
        name: r'categoriesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Active categories of [type] in display order. Re-subscribes when the signed-in user changes.

  CategoriesProvider call(CategoryType type) => CategoriesProvider._(argument: type, from: this);

  @override
  String toString() => r'categoriesProvider';
}

/// One category, **including** archived ones, so transactions can still show theirs. `null` when
/// it isn't on this device (e.g. not synced yet).

@ProviderFor(categoryById)
final categoryByIdProvider = CategoryByIdFamily._();

/// One category, **including** archived ones, so transactions can still show theirs. `null` when
/// it isn't on this device (e.g. not synced yet).

final class CategoryByIdProvider
    extends $FunctionalProvider<AsyncValue<Category?>, Category?, Stream<Category?>>
    with $FutureModifier<Category?>, $StreamProvider<Category?> {
  /// One category, **including** archived ones, so transactions can still show theirs. `null` when
  /// it isn't on this device (e.g. not synced yet).
  CategoryByIdProvider._({
    required CategoryByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'categoryByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$categoryByIdHash();

  @override
  String toString() {
    return r'categoryByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Category?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Category?> create(Ref ref) {
    final argument = this.argument as String;
    return categoryById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CategoryByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$categoryByIdHash() => r'f97c341ead2d3674d3c1b45d4eadc229fedf35e1';

/// One category, **including** archived ones, so transactions can still show theirs. `null` when
/// it isn't on this device (e.g. not synced yet).

final class CategoryByIdFamily extends $Family
    with $FunctionalFamilyOverride<Stream<Category?>, String> {
  CategoryByIdFamily._()
    : super(
        retry: null,
        name: r'categoryByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One category, **including** archived ones, so transactions can still show theirs. `null` when
  /// it isn't on this device (e.g. not synced yet).

  CategoryByIdProvider call(String id) => CategoryByIdProvider._(argument: id, from: this);

  @override
  String toString() => r'categoryByIdProvider';
}
