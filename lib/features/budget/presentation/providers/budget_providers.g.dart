// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The month the budget tab shows, as its first day. Starts at the current month and resets when
/// the signed-in user changes.

@ProviderFor(BudgetMonthController)
final budgetMonthControllerProvider = BudgetMonthControllerProvider._();

/// The month the budget tab shows, as its first day. Starts at the current month and resets when
/// the signed-in user changes.
final class BudgetMonthControllerProvider
    extends $NotifierProvider<BudgetMonthController, DateTime> {
  /// The month the budget tab shows, as its first day. Starts at the current month and resets when
  /// the signed-in user changes.
  BudgetMonthControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'budgetMonthControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$budgetMonthControllerHash();

  @$internal
  @override
  BudgetMonthController create() => BudgetMonthController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime>(value),
    );
  }
}

String _$budgetMonthControllerHash() => r'ee2841eac5878fff7af1de9f295f91940086d58f';

/// The month the budget tab shows, as its first day. Starts at the current month and resets when
/// the signed-in user changes.

abstract class _$BudgetMonthController extends $Notifier<DateTime> {
  DateTime build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<DateTime, DateTime>;
    final element =
        ref.element
            as $ClassProviderElement<AnyNotifier<DateTime, DateTime>, DateTime, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}

/// The budgets of the month containing [month] with their spending. Updates when budgets or
/// transactions change; re-subscribes for a new user.

@ProviderFor(budgetOverview)
final budgetOverviewProvider = BudgetOverviewFamily._();

/// The budgets of the month containing [month] with their spending. Updates when budgets or
/// transactions change; re-subscribes for a new user.

final class BudgetOverviewProvider
    extends $FunctionalProvider<AsyncValue<BudgetOverview>, BudgetOverview, Stream<BudgetOverview>>
    with $FutureModifier<BudgetOverview>, $StreamProvider<BudgetOverview> {
  /// The budgets of the month containing [month] with their spending. Updates when budgets or
  /// transactions change; re-subscribes for a new user.
  BudgetOverviewProvider._({
    required BudgetOverviewFamily super.from,
    required DateTime super.argument,
  }) : super(
         retry: null,
         name: r'budgetOverviewProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$budgetOverviewHash();

  @override
  String toString() {
    return r'budgetOverviewProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<BudgetOverview> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<BudgetOverview> create(Ref ref) {
    final argument = this.argument as DateTime;
    return budgetOverview(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BudgetOverviewProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$budgetOverviewHash() => r'340fbe63bd565b126b0d815e55d57f016a37fb27';

/// The budgets of the month containing [month] with their spending. Updates when budgets or
/// transactions change; re-subscribes for a new user.

final class BudgetOverviewFamily extends $Family
    with $FunctionalFamilyOverride<Stream<BudgetOverview>, DateTime> {
  BudgetOverviewFamily._()
    : super(
        retry: null,
        name: r'budgetOverviewProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The budgets of the month containing [month] with their spending. Updates when budgets or
  /// transactions change; re-subscribes for a new user.

  BudgetOverviewProvider call(DateTime month) =>
      BudgetOverviewProvider._(argument: month, from: this);

  @override
  String toString() => r'budgetOverviewProvider';
}
