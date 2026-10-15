// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supabase_data_key_gateway.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(dataKeyGateway)
final dataKeyGatewayProvider = DataKeyGatewayProvider._();

final class DataKeyGatewayProvider
    extends $FunctionalProvider<DataKeyGateway, DataKeyGateway, DataKeyGateway>
    with $Provider<DataKeyGateway> {
  DataKeyGatewayProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dataKeyGatewayProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dataKeyGatewayHash();

  @$internal
  @override
  $ProviderElement<DataKeyGateway> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DataKeyGateway create(Ref ref) {
    return dataKeyGateway(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DataKeyGateway value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DataKeyGateway>(value),
    );
  }
}

String _$dataKeyGatewayHash() => r'658b8e586698d0af21dd0e3238591eae19f7669e';

@ProviderFor(dataKeyService)
final dataKeyServiceProvider = DataKeyServiceProvider._();

final class DataKeyServiceProvider
    extends $FunctionalProvider<DataKeyService, DataKeyService, DataKeyService>
    with $Provider<DataKeyService> {
  DataKeyServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dataKeyServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dataKeyServiceHash();

  @$internal
  @override
  $ProviderElement<DataKeyService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DataKeyService create(Ref ref) {
    return dataKeyService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DataKeyService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DataKeyService>(value),
    );
  }
}

String _$dataKeyServiceHash() => r'ea2a4f0e5a788eff60031fb06662674b605105ff';
