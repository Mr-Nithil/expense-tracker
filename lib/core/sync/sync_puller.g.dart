// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_puller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(syncPuller)
final syncPullerProvider = SyncPullerProvider._();

final class SyncPullerProvider extends $FunctionalProvider<SyncPuller, SyncPuller, SyncPuller>
    with $Provider<SyncPuller> {
  SyncPullerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncPullerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncPullerHash();

  @$internal
  @override
  $ProviderElement<SyncPuller> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SyncPuller create(Ref ref) {
    return syncPuller(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncPuller value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncPuller>(value),
    );
  }
}

String _$syncPullerHash() => r'770bffc1eb1f35ce6323721672a828bef8832e2f';
