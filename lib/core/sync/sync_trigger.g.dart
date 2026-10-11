// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_trigger.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(syncTrigger)
final syncTriggerProvider = SyncTriggerProvider._();

final class SyncTriggerProvider extends $FunctionalProvider<SyncTrigger, SyncTrigger, SyncTrigger>
    with $Provider<SyncTrigger> {
  SyncTriggerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncTriggerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncTriggerHash();

  @$internal
  @override
  $ProviderElement<SyncTrigger> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SyncTrigger create(Ref ref) {
    return syncTrigger(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncTrigger value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncTrigger>(value),
    );
  }
}

String _$syncTriggerHash() => r'f7d778bed1c8694b34a00c5bd7afc1177060a4b6';
