// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'initial_sync.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The first full pull for the signed-in user on this device (M3.8): the onboarding gate waits
/// for it, so a second device downloads the profile (with its currency) instead of asking again.
///
/// Starts when the user becomes signed in, i.e. after the local-data claim (M1.15), so it never
/// reads a previous user's cursors.

@ProviderFor(InitialSync)
final initialSyncProvider = InitialSyncProvider._();

/// The first full pull for the signed-in user on this device (M3.8): the onboarding gate waits
/// for it, so a second device downloads the profile (with its currency) instead of asking again.
///
/// Starts when the user becomes signed in, i.e. after the local-data claim (M1.15), so it never
/// reads a previous user's cursors.
final class InitialSyncProvider extends $NotifierProvider<InitialSync, InitialSyncStatus> {
  /// The first full pull for the signed-in user on this device (M3.8): the onboarding gate waits
  /// for it, so a second device downloads the profile (with its currency) instead of asking again.
  ///
  /// Starts when the user becomes signed in, i.e. after the local-data claim (M1.15), so it never
  /// reads a previous user's cursors.
  InitialSyncProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'initialSyncProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$initialSyncHash();

  @$internal
  @override
  InitialSync create() => InitialSync();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InitialSyncStatus value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InitialSyncStatus>(value),
    );
  }
}

String _$initialSyncHash() => r'0e09e2eb0e235fe66dba4eaefbd4d0934b9b5292';

/// The first full pull for the signed-in user on this device (M3.8): the onboarding gate waits
/// for it, so a second device downloads the profile (with its currency) instead of asking again.
///
/// Starts when the user becomes signed in, i.e. after the local-data claim (M1.15), so it never
/// reads a previous user's cursors.

abstract class _$InitialSync extends $Notifier<InitialSyncStatus> {
  InitialSyncStatus build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<InitialSyncStatus, InitialSyncStatus>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<InitialSyncStatus, InitialSyncStatus>,
              InitialSyncStatus,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// How long sign-in waits for the initial pull before moving on (the run itself continues in the
/// background). A provider so tests can shorten it.

@ProviderFor(initialSyncTimeout)
final initialSyncTimeoutProvider = InitialSyncTimeoutProvider._();

/// How long sign-in waits for the initial pull before moving on (the run itself continues in the
/// background). A provider so tests can shorten it.

final class InitialSyncTimeoutProvider extends $FunctionalProvider<Duration, Duration, Duration>
    with $Provider<Duration> {
  /// How long sign-in waits for the initial pull before moving on (the run itself continues in the
  /// background). A provider so tests can shorten it.
  InitialSyncTimeoutProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'initialSyncTimeoutProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$initialSyncTimeoutHash();

  @$internal
  @override
  $ProviderElement<Duration> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  Duration create(Ref ref) {
    return initialSyncTimeout(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Duration value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Duration>(value),
    );
  }
}

String _$initialSyncTimeoutHash() => r'98aa751168bb74be354bd6954007f5ff150c0b99';
