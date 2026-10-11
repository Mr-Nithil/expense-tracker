// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_pusher.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(syncPusher)
final syncPusherProvider = SyncPusherProvider._();

final class SyncPusherProvider extends $FunctionalProvider<SyncPusher, SyncPusher, SyncPusher>
    with $Provider<SyncPusher> {
  SyncPusherProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncPusherProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncPusherHash();

  @$internal
  @override
  $ProviderElement<SyncPusher> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SyncPusher create(Ref ref) {
    return syncPusher(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncPusher value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncPusher>(value),
    );
  }
}

String _$syncPusherHash() => r'12736876b5e2167ebb358b7f3ef3e8370a31c6ee';
