// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transactions_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// What the transactions tab shows: one month, optionally narrowed by type and category.
/// Starts at the current month, unfiltered, and resets when the signed-in user changes.

@ProviderFor(TransactionFilterController)
final transactionFilterControllerProvider = TransactionFilterControllerProvider._();

/// What the transactions tab shows: one month, optionally narrowed by type and category.
/// Starts at the current month, unfiltered, and resets when the signed-in user changes.
final class TransactionFilterControllerProvider
    extends $NotifierProvider<TransactionFilterController, TransactionFilter> {
  /// What the transactions tab shows: one month, optionally narrowed by type and category.
  /// Starts at the current month, unfiltered, and resets when the signed-in user changes.
  TransactionFilterControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transactionFilterControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transactionFilterControllerHash();

  @$internal
  @override
  TransactionFilterController create() => TransactionFilterController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TransactionFilter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TransactionFilter>(value),
    );
  }
}

String _$transactionFilterControllerHash() => r'b551fe712ae5d9834a283b2e63469afd413b1941';

/// What the transactions tab shows: one month, optionally narrowed by type and category.
/// Starts at the current month, unfiltered, and resets when the signed-in user changes.

abstract class _$TransactionFilterController extends $Notifier<TransactionFilter> {
  TransactionFilter build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<TransactionFilter, TransactionFilter>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TransactionFilter, TransactionFilter>,
              TransactionFilter,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Non-deleted transactions matching [filter], newest first. Re-subscribes for a new user.

@ProviderFor(transactions)
final transactionsProvider = TransactionsFamily._();

/// Non-deleted transactions matching [filter], newest first. Re-subscribes for a new user.

final class TransactionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Transaction>>,
          List<Transaction>,
          Stream<List<Transaction>>
        >
    with $FutureModifier<List<Transaction>>, $StreamProvider<List<Transaction>> {
  /// Non-deleted transactions matching [filter], newest first. Re-subscribes for a new user.
  TransactionsProvider._({
    required TransactionsFamily super.from,
    required TransactionFilter super.argument,
  }) : super(
         retry: null,
         name: r'transactionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$transactionsHash();

  @override
  String toString() {
    return r'transactionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Transaction>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Transaction>> create(Ref ref) {
    final argument = this.argument as TransactionFilter;
    return transactions(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TransactionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$transactionsHash() => r'b67b01c639f77b52f395713bd4c467c1add731dc';

/// Non-deleted transactions matching [filter], newest first. Re-subscribes for a new user.

final class TransactionsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Transaction>>, TransactionFilter> {
  TransactionsFamily._()
    : super(
        retry: null,
        name: r'transactionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Non-deleted transactions matching [filter], newest first. Re-subscribes for a new user.

  TransactionsProvider call(TransactionFilter filter) =>
      TransactionsProvider._(argument: filter, from: this);

  @override
  String toString() => r'transactionsProvider';
}

/// [transactionsProvider] grouped into newest-first days with subtotals.

@ProviderFor(transactionDays)
final transactionDaysProvider = TransactionDaysFamily._();

/// [transactionsProvider] grouped into newest-first days with subtotals.

final class TransactionDaysProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TransactionDay>>,
          AsyncValue<List<TransactionDay>>,
          AsyncValue<List<TransactionDay>>
        >
    with $Provider<AsyncValue<List<TransactionDay>>> {
  /// [transactionsProvider] grouped into newest-first days with subtotals.
  TransactionDaysProvider._({
    required TransactionDaysFamily super.from,
    required TransactionFilter super.argument,
  }) : super(
         retry: null,
         name: r'transactionDaysProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$transactionDaysHash();

  @override
  String toString() {
    return r'transactionDaysProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<AsyncValue<List<TransactionDay>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<List<TransactionDay>> create(Ref ref) {
    final argument = this.argument as TransactionFilter;
    return transactionDays(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<TransactionDay>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<TransactionDay>>>(
        value,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TransactionDaysProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$transactionDaysHash() => r'd51343c68479fc21e1fb09995c7238adf31e81e9';

/// [transactionsProvider] grouped into newest-first days with subtotals.

final class TransactionDaysFamily extends $Family
    with $FunctionalFamilyOverride<AsyncValue<List<TransactionDay>>, TransactionFilter> {
  TransactionDaysFamily._()
    : super(
        retry: null,
        name: r'transactionDaysProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// [transactionsProvider] grouped into newest-first days with subtotals.

  TransactionDaysProvider call(TransactionFilter filter) =>
      TransactionDaysProvider._(argument: filter, from: this);

  @override
  String toString() => r'transactionDaysProvider';
}

/// Income and expense totals of the month containing [month]. Re-subscribes for a new user.

@ProviderFor(monthTotals)
final monthTotalsProvider = MonthTotalsFamily._();

/// Income and expense totals of the month containing [month]. Re-subscribes for a new user.

final class MonthTotalsProvider
    extends $FunctionalProvider<AsyncValue<MonthTotals>, MonthTotals, Stream<MonthTotals>>
    with $FutureModifier<MonthTotals>, $StreamProvider<MonthTotals> {
  /// Income and expense totals of the month containing [month]. Re-subscribes for a new user.
  MonthTotalsProvider._({
    required MonthTotalsFamily super.from,
    required DateTime super.argument,
  }) : super(
         retry: null,
         name: r'monthTotalsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$monthTotalsHash();

  @override
  String toString() {
    return r'monthTotalsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<MonthTotals> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<MonthTotals> create(Ref ref) {
    final argument = this.argument as DateTime;
    return monthTotals(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MonthTotalsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$monthTotalsHash() => r'07bcfca1d92902f547f80502b5019f6fbad86135';

/// Income and expense totals of the month containing [month]. Re-subscribes for a new user.

final class MonthTotalsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<MonthTotals>, DateTime> {
  MonthTotalsFamily._()
    : super(
        retry: null,
        name: r'monthTotalsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Income and expense totals of the month containing [month]. Re-subscribes for a new user.

  MonthTotalsProvider call(DateTime month) => MonthTotalsProvider._(argument: month, from: this);

  @override
  String toString() => r'monthTotalsProvider';
}

/// Expenses of the month containing [month] by category, largest first, the tail folded into
/// "Other". Re-subscribes for a new user.

@ProviderFor(spendingBreakdown)
final spendingBreakdownProvider = SpendingBreakdownFamily._();

/// Expenses of the month containing [month] by category, largest first, the tail folded into
/// "Other". Re-subscribes for a new user.

final class SpendingBreakdownProvider
    extends
        $FunctionalProvider<
          AsyncValue<SpendingBreakdown>,
          SpendingBreakdown,
          Stream<SpendingBreakdown>
        >
    with $FutureModifier<SpendingBreakdown>, $StreamProvider<SpendingBreakdown> {
  /// Expenses of the month containing [month] by category, largest first, the tail folded into
  /// "Other". Re-subscribes for a new user.
  SpendingBreakdownProvider._({
    required SpendingBreakdownFamily super.from,
    required DateTime super.argument,
  }) : super(
         retry: null,
         name: r'spendingBreakdownProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$spendingBreakdownHash();

  @override
  String toString() {
    return r'spendingBreakdownProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<SpendingBreakdown> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<SpendingBreakdown> create(Ref ref) {
    final argument = this.argument as DateTime;
    return spendingBreakdown(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SpendingBreakdownProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$spendingBreakdownHash() => r'2c9df257d2f643aa2ebb4281d13431ddcd999b30';

/// Expenses of the month containing [month] by category, largest first, the tail folded into
/// "Other". Re-subscribes for a new user.

final class SpendingBreakdownFamily extends $Family
    with $FunctionalFamilyOverride<Stream<SpendingBreakdown>, DateTime> {
  SpendingBreakdownFamily._()
    : super(
        retry: null,
        name: r'spendingBreakdownProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Expenses of the month containing [month] by category, largest first, the tail folded into
  /// "Other". Re-subscribes for a new user.

  SpendingBreakdownProvider call(DateTime month) =>
      SpendingBreakdownProvider._(argument: month, from: this);

  @override
  String toString() => r'spendingBreakdownProvider';
}

/// One transaction, including a soft-deleted one (`isDeleted`). Re-subscribes for a new user.

@ProviderFor(transactionById)
final transactionByIdProvider = TransactionByIdFamily._();

/// One transaction, including a soft-deleted one (`isDeleted`). Re-subscribes for a new user.

final class TransactionByIdProvider
    extends $FunctionalProvider<AsyncValue<Transaction?>, Transaction?, Stream<Transaction?>>
    with $FutureModifier<Transaction?>, $StreamProvider<Transaction?> {
  /// One transaction, including a soft-deleted one (`isDeleted`). Re-subscribes for a new user.
  TransactionByIdProvider._({
    required TransactionByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'transactionByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$transactionByIdHash();

  @override
  String toString() {
    return r'transactionByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Transaction?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Transaction?> create(Ref ref) {
    final argument = this.argument as String;
    return transactionById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TransactionByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$transactionByIdHash() => r'bf5aa3e88092257cc1ec81fb91402812a1fa53a7';

/// One transaction, including a soft-deleted one (`isDeleted`). Re-subscribes for a new user.

final class TransactionByIdFamily extends $Family
    with $FunctionalFamilyOverride<Stream<Transaction?>, String> {
  TransactionByIdFamily._()
    : super(
        retry: null,
        name: r'transactionByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One transaction, including a soft-deleted one (`isDeleted`). Re-subscribes for a new user.

  TransactionByIdProvider call(String id) => TransactionByIdProvider._(argument: id, from: this);

  @override
  String toString() => r'transactionByIdProvider';
}
