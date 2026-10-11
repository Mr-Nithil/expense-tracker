// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal_detail_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Goal detail actions: delete the goal, remove a contribution and undo that. Returns the
/// [Result] so the page can close, offer Undo or show the error. Kept alive because it is only
/// used from callbacks.

@ProviderFor(GoalDetailController)
final goalDetailControllerProvider = GoalDetailControllerProvider._();

/// Goal detail actions: delete the goal, remove a contribution and undo that. Returns the
/// [Result] so the page can close, offer Undo or show the error. Kept alive because it is only
/// used from callbacks.
final class GoalDetailControllerProvider extends $NotifierProvider<GoalDetailController, void> {
  /// Goal detail actions: delete the goal, remove a contribution and undo that. Returns the
  /// [Result] so the page can close, offer Undo or show the error. Kept alive because it is only
  /// used from callbacks.
  GoalDetailControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'goalDetailControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$goalDetailControllerHash();

  @$internal
  @override
  GoalDetailController create() => GoalDetailController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$goalDetailControllerHash() => r'646df8a3db85527bb0e374ec8d86eb6626d6ccb7';

/// Goal detail actions: delete the goal, remove a contribution and undo that. Returns the
/// [Result] so the page can close, offer Undo or show the error. Kept alive because it is only
/// used from callbacks.

abstract class _$GoalDetailController extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element as $ClassProviderElement<AnyNotifier<void, void>, void, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
