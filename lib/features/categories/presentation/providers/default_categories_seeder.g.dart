// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'default_categories_seeder.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(defaultCategoriesSeeder)
final defaultCategoriesSeederProvider = DefaultCategoriesSeederProvider._();

final class DefaultCategoriesSeederProvider
    extends
        $FunctionalProvider<
          DefaultCategoriesSeeder,
          DefaultCategoriesSeeder,
          DefaultCategoriesSeeder
        >
    with $Provider<DefaultCategoriesSeeder> {
  DefaultCategoriesSeederProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'defaultCategoriesSeederProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$defaultCategoriesSeederHash();

  @$internal
  @override
  $ProviderElement<DefaultCategoriesSeeder> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DefaultCategoriesSeeder create(Ref ref) {
    return defaultCategoriesSeeder(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DefaultCategoriesSeeder value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DefaultCategoriesSeeder>(value),
    );
  }
}

String _$defaultCategoriesSeederHash() => r'dbb6703a167a5dd79b081a8ca214b2a8cbe16df7';
