// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goals_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Non-deleted goals, oldest first, with what was saved. Re-subscribes for a new user.

@ProviderFor(goals)
final goalsProvider = GoalsProvider._();

/// Non-deleted goals, oldest first, with what was saved. Re-subscribes for a new user.

final class GoalsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<GoalProgress>>,
          List<GoalProgress>,
          Stream<List<GoalProgress>>
        >
    with $FutureModifier<List<GoalProgress>>, $StreamProvider<List<GoalProgress>> {
  /// Non-deleted goals, oldest first, with what was saved. Re-subscribes for a new user.
  GoalsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'goalsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$goalsHash();

  @$internal
  @override
  $StreamProviderElement<List<GoalProgress>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<GoalProgress>> create(Ref ref) {
    return goals(ref);
  }
}

String _$goalsHash() => r'2df5101f15791bd939abeb04ef231ee03f81c0c4';

/// [goalsProvider] at a glance: totals, how many are reached, the closest unfinished goals.

@ProviderFor(goalsSummary)
final goalsSummaryProvider = GoalsSummaryProvider._();

/// [goalsProvider] at a glance: totals, how many are reached, the closest unfinished goals.

final class GoalsSummaryProvider
    extends
        $FunctionalProvider<
          AsyncValue<GoalsSummary>,
          AsyncValue<GoalsSummary>,
          AsyncValue<GoalsSummary>
        >
    with $Provider<AsyncValue<GoalsSummary>> {
  /// [goalsProvider] at a glance: totals, how many are reached, the closest unfinished goals.
  GoalsSummaryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'goalsSummaryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$goalsSummaryHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<GoalsSummary>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<GoalsSummary> create(Ref ref) {
    return goalsSummary(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<GoalsSummary> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<GoalsSummary>>(value),
    );
  }
}

String _$goalsSummaryHash() => r'a5108ca74f30b0ed68a942b1fd04cfedc23f099a';

/// One non-deleted goal with what was saved; `null` when missing or deleted (e.g. on another
/// device). Re-subscribes for a new user.

@ProviderFor(goalById)
final goalByIdProvider = GoalByIdFamily._();

/// One non-deleted goal with what was saved; `null` when missing or deleted (e.g. on another
/// device). Re-subscribes for a new user.

final class GoalByIdProvider
    extends $FunctionalProvider<AsyncValue<GoalProgress?>, GoalProgress?, Stream<GoalProgress?>>
    with $FutureModifier<GoalProgress?>, $StreamProvider<GoalProgress?> {
  /// One non-deleted goal with what was saved; `null` when missing or deleted (e.g. on another
  /// device). Re-subscribes for a new user.
  GoalByIdProvider._({
    required GoalByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'goalByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$goalByIdHash();

  @override
  String toString() {
    return r'goalByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<GoalProgress?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<GoalProgress?> create(Ref ref) {
    final argument = this.argument as String;
    return goalById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GoalByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$goalByIdHash() => r'5691e52aaae54167ea6157cceb2f67bd0a98497d';

/// One non-deleted goal with what was saved; `null` when missing or deleted (e.g. on another
/// device). Re-subscribes for a new user.

final class GoalByIdFamily extends $Family
    with $FunctionalFamilyOverride<Stream<GoalProgress?>, String> {
  GoalByIdFamily._()
    : super(
        retry: null,
        name: r'goalByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One non-deleted goal with what was saved; `null` when missing or deleted (e.g. on another
  /// device). Re-subscribes for a new user.

  GoalByIdProvider call(String id) => GoalByIdProvider._(argument: id, from: this);

  @override
  String toString() => r'goalByIdProvider';
}

/// A goal's non-deleted contributions, newest first. Re-subscribes for a new user.

@ProviderFor(goalContributions)
final goalContributionsProvider = GoalContributionsFamily._();

/// A goal's non-deleted contributions, newest first. Re-subscribes for a new user.

final class GoalContributionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<GoalContribution>>,
          List<GoalContribution>,
          Stream<List<GoalContribution>>
        >
    with $FutureModifier<List<GoalContribution>>, $StreamProvider<List<GoalContribution>> {
  /// A goal's non-deleted contributions, newest first. Re-subscribes for a new user.
  GoalContributionsProvider._({
    required GoalContributionsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'goalContributionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$goalContributionsHash();

  @override
  String toString() {
    return r'goalContributionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<GoalContribution>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<GoalContribution>> create(Ref ref) {
    final argument = this.argument as String;
    return goalContributions(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GoalContributionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$goalContributionsHash() => r'159c08421939679e9120a794c321f91f7b21e309';

/// A goal's non-deleted contributions, newest first. Re-subscribes for a new user.

final class GoalContributionsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<GoalContribution>>, String> {
  GoalContributionsFamily._()
    : super(
        retry: null,
        name: r'goalContributionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// A goal's non-deleted contributions, newest first. Re-subscribes for a new user.

  GoalContributionsProvider call(String goalId) =>
      GoalContributionsProvider._(argument: goalId, from: this);

  @override
  String toString() => r'goalContributionsProvider';
}
