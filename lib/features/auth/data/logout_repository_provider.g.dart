// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'logout_repository_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The logout repository, exposed as its interface. Other features use it through
/// `LogoutController` (ARCHITECTURE §3, cross-feature UI).

@ProviderFor(logoutRepository)
final logoutRepositoryProvider = LogoutRepositoryProvider._();

/// The logout repository, exposed as its interface. Other features use it through
/// `LogoutController` (ARCHITECTURE §3, cross-feature UI).

final class LogoutRepositoryProvider
    extends $FunctionalProvider<LogoutRepository, LogoutRepository, LogoutRepository>
    with $Provider<LogoutRepository> {
  /// The logout repository, exposed as its interface. Other features use it through
  /// `LogoutController` (ARCHITECTURE §3, cross-feature UI).
  LogoutRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'logoutRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$logoutRepositoryHash();

  @$internal
  @override
  $ProviderElement<LogoutRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LogoutRepository create(Ref ref) {
    return logoutRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LogoutRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LogoutRepository>(value),
    );
  }
}

String _$logoutRepositoryHash() => r'1e6acbf1e69af095e833750b822054343cce35b7';
