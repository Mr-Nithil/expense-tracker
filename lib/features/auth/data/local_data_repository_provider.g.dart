// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_data_repository_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The local data repository, exposed as its interface.

@ProviderFor(localDataRepository)
final localDataRepositoryProvider = LocalDataRepositoryProvider._();

/// The local data repository, exposed as its interface.

final class LocalDataRepositoryProvider
    extends $FunctionalProvider<LocalDataRepository, LocalDataRepository, LocalDataRepository>
    with $Provider<LocalDataRepository> {
  /// The local data repository, exposed as its interface.
  LocalDataRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localDataRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localDataRepositoryHash();

  @$internal
  @override
  $ProviderElement<LocalDataRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LocalDataRepository create(Ref ref) {
    return localDataRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocalDataRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocalDataRepository>(value),
    );
  }
}

String _$localDataRepositoryHash() => r'15c5adc5d417eaf0ce60efa7a083d0a909a3db1b';
