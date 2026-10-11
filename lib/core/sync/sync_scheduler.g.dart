// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_scheduler.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Automatic sync while signed in (ARCHITECTURE §7): once when the session starts (app start
/// with a restored session, or a sign-in), and again on app resume and when the connection comes
/// back. Stops, and drops a pending debounced run, when the user is no longer signed in.
///
/// Must be kept alive by the app (see `App`). Writes trigger sync themselves (repositories).

@ProviderFor(syncScheduler)
final syncSchedulerProvider = SyncSchedulerProvider._();

/// Automatic sync while signed in (ARCHITECTURE §7): once when the session starts (app start
/// with a restored session, or a sign-in), and again on app resume and when the connection comes
/// back. Stops, and drops a pending debounced run, when the user is no longer signed in.
///
/// Must be kept alive by the app (see `App`). Writes trigger sync themselves (repositories).

final class SyncSchedulerProvider extends $FunctionalProvider<void, void, void>
    with $Provider<void> {
  /// Automatic sync while signed in (ARCHITECTURE §7): once when the session starts (app start
  /// with a restored session, or a sign-in), and again on app resume and when the connection comes
  /// back. Stops, and drops a pending debounced run, when the user is no longer signed in.
  ///
  /// Must be kept alive by the app (see `App`). Writes trigger sync themselves (repositories).
  SyncSchedulerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncSchedulerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncSchedulerHash();

  @$internal
  @override
  $ProviderElement<void> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  void create(Ref ref) {
    return syncScheduler(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$syncSchedulerHash() => r'8dfabb9e8eefad055263ec22cfe2f68645ff422e';
