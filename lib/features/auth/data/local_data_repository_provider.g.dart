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

String _$localDataRepositoryHash() => r'86d1a165d6cc79e7f44c6d295ce5f349786f4f21';
