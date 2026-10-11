import 'package:expense_tracker/core/session/session.dart';
import 'package:expense_tracker/core/utils/currencies.dart';
import 'package:expense_tracker/features/profile/data/profile_repository_provider.dart';
import 'package:expense_tracker/features/profile/domain/entities/profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show ProviderListenableSelect;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_providers.g.dart';

/// The signed-in user's profile. Re-subscribes when the user changes.
@riverpod
Stream<Profile?> profile(Ref ref) {
  ref.watch(sessionProvider.select((user) => user?.userId));
  return ref.watch(profileRepositoryProvider).watchProfile();
}

/// The user's one currency (ISO 4217). Always set behind the onboarding gate; the fallback is
/// only a safety net. A future, so forms wait for the real currency before formatting amounts.
@riverpod
Future<String> currencyCode(Ref ref) async =>
    (await ref.watch(profileProvider.future))?.currencyCode ?? Currencies.fallback;
