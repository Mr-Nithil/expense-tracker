// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_repository_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The budget repository, exposed as its interface.

@ProviderFor(budgetRepository)
final budgetRepositoryProvider = BudgetRepositoryProvider._();

/// The budget repository, exposed as its interface.

final class BudgetRepositoryProvider
    extends $FunctionalProvider<BudgetRepository, BudgetRepository, BudgetRepository>
    with $Provider<BudgetRepository> {
  /// The budget repository, exposed as its interface.
  BudgetRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'budgetRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$budgetRepositoryHash();

  @$internal
  @override
  $ProviderElement<BudgetRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BudgetRepository create(Ref ref) {
    return budgetRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BudgetRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BudgetRepository>(value),
    );
  }
}

String _$budgetRepositoryHash() => r'eab6b346a0b53f7f9b83e3652bcc1758ca18c842';

/// Whether this device shows budget alerts (device-only setting).

@ProviderFor(budgetAlertPreferences)
final budgetAlertPreferencesProvider = BudgetAlertPreferencesProvider._();

/// Whether this device shows budget alerts (device-only setting).

final class BudgetAlertPreferencesProvider
    extends
        $FunctionalProvider<BudgetAlertPreferences, BudgetAlertPreferences, BudgetAlertPreferences>
    with $Provider<BudgetAlertPreferences> {
  /// Whether this device shows budget alerts (device-only setting).
  BudgetAlertPreferencesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'budgetAlertPreferencesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$budgetAlertPreferencesHash();

  @$internal
  @override
  $ProviderElement<BudgetAlertPreferences> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BudgetAlertPreferences create(Ref ref) {
    return budgetAlertPreferences(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BudgetAlertPreferences value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BudgetAlertPreferences>(value),
    );
  }
}

String _$budgetAlertPreferencesHash() => r'470fdfc4cb1a3188af86174fa3146c4d125010fb';
