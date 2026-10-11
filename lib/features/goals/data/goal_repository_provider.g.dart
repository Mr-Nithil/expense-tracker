// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal_repository_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The goal repository, exposed as its interface.

@ProviderFor(goalRepository)
final goalRepositoryProvider = GoalRepositoryProvider._();

/// The goal repository, exposed as its interface.

final class GoalRepositoryProvider
    extends $FunctionalProvider<GoalRepository, GoalRepository, GoalRepository>
    with $Provider<GoalRepository> {
  /// The goal repository, exposed as its interface.
  GoalRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'goalRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$goalRepositoryHash();

  @$internal
  @override
  $ProviderElement<GoalRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoalRepository create(Ref ref) {
    return goalRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoalRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoalRepository>(value),
    );
  }
}

String _$goalRepositoryHash() => r'a821bc8554037b719f0ab0ae2f470b5e3a7b8b65';
