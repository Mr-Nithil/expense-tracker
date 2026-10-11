// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supabase_sync_gateway.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(syncGateway)
final syncGatewayProvider = SyncGatewayProvider._();

final class SyncGatewayProvider extends $FunctionalProvider<SyncGateway, SyncGateway, SyncGateway>
    with $Provider<SyncGateway> {
  SyncGatewayProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncGatewayProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncGatewayHash();

  @$internal
  @override
  $ProviderElement<SyncGateway> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SyncGateway create(Ref ref) {
    return syncGateway(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncGateway value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncGateway>(value),
    );
  }
}

String _$syncGatewayHash() => r'9cc8f2f656b263901890b8db6bf4f1a5c246c599';
