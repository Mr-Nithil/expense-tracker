// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_status.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The sync state for the UI, from the sync runs, the pending-row count and connectivity.

@ProviderFor(syncStatus)
final syncStatusProvider = SyncStatusProvider._();

/// The sync state for the UI, from the sync runs, the pending-row count and connectivity.

final class SyncStatusProvider
    extends $FunctionalProvider<AsyncValue<SyncStatusInfo>, SyncStatusInfo, Stream<SyncStatusInfo>>
    with $FutureModifier<SyncStatusInfo>, $StreamProvider<SyncStatusInfo> {
  /// The sync state for the UI, from the sync runs, the pending-row count and connectivity.
  SyncStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncStatusProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncStatusHash();

  @$internal
  @override
  $StreamProviderElement<SyncStatusInfo> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<SyncStatusInfo> create(Ref ref) {
    return syncStatus(ref);
  }
}

String _$syncStatusHash() => r'e00d3ccffea97469c6d93344d4b3e431bd8594aa';
