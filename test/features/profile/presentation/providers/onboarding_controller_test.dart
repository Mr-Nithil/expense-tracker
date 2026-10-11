import 'dart:async';

import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/features/categories/presentation/providers/default_categories_seeder.dart';
import 'package:expense_tracker/features/profile/data/profile_repository_provider.dart';
import 'package:expense_tracker/features/profile/domain/entities/profile.dart';
import 'package:expense_tracker/features/profile/domain/profile_repository.dart';
import 'package:expense_tracker/features/profile/presentation/providers/onboarding_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockProfileRepository extends Mock implements ProfileRepository {}

class _MockSeeder extends Mock implements DefaultCategoriesSeeder {}

void main() {
  const profile = Profile(id: 'u1', currencyCode: 'LKR');

  late _MockProfileRepository repository;
  late _MockSeeder seeder;
  late ProviderContainer container;

  setUp(() {
    repository = _MockProfileRepository();
    seeder = _MockSeeder();
    when(() => seeder.seed()).thenAnswer((_) async => const Result.success(13));
    container = ProviderContainer(
      overrides: [
        profileRepositoryProvider.overrideWithValue(repository),
        defaultCategoriesSeederProvider.overrideWithValue(seeder),
      ],
    );
    addTearDown(container.dispose);
    container.listen(onboardingControllerProvider, (_, _) {});
  });

  OnboardingController controller() => container.read(onboardingControllerProvider.notifier);
  AsyncValue<void> state() => container.read(onboardingControllerProvider);

  test('is loading while saving, then succeeds', () async {
    final completer = Completer<Result<Profile>>();
    when(() => repository.setCurrency(any())).thenAnswer((_) => completer.future);

    final pending = controller().confirm('LKR');
    expect(state().isLoading, isTrue);

    completer.complete(const Result.success(profile));
    await pending;

    expect(state(), isA<AsyncData<void>>());
    verify(() => repository.setCurrency('LKR')).called(1);
  });

  test('exposes the failure as an error', () async {
    const failure = StorageFailure('disk full');
    when(
      () => repository.setCurrency(any()),
    ).thenAnswer((_) async => const Result.failure(failure));

    await controller().confirm('LKR');

    expect(state().error, failure);
  });

  test('ignores a second confirm while one is in flight', () async {
    final completer = Completer<Result<Profile>>();
    when(() => repository.setCurrency(any())).thenAnswer((_) => completer.future);

    final first = controller().confirm('LKR');
    await controller().confirm('USD');
    completer.complete(const Result.success(profile));
    await first;

    verify(() => repository.setCurrency(any())).called(1);
  });

  test('seeds the default categories before saving the currency', () async {
    when(
      () => repository.setCurrency(any()),
    ).thenAnswer((_) async => const Result.success(profile));

    await controller().confirm('LKR');

    verifyInOrder([() => seeder.seed(), () => repository.setCurrency('LKR')]);
  });

  test('a failed seed keeps the user on onboarding without saving the currency', () async {
    const failure = StorageFailure('disk full');
    when(() => seeder.seed()).thenAnswer((_) async => const Result.failure(failure));

    await controller().confirm('LKR');

    expect(state().error, failure);
    verifyNever(() => repository.setCurrency(any()));
  });
}
