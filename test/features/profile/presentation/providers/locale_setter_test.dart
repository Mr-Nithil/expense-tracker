import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/features/profile/data/profile_repository_provider.dart';
import 'package:expense_tracker/features/profile/domain/entities/profile.dart';
import 'package:expense_tracker/features/profile/domain/profile_repository.dart';
import 'package:expense_tracker/features/profile/presentation/providers/locale_setter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  late _MockProfileRepository repository;
  late LocaleSetter setter;

  setUp(() {
    repository = _MockProfileRepository();
    when(
      () => repository.setLocale(any()),
    ).thenAnswer((_) async => const Result.success(Profile(id: 'u1')));
    final container = ProviderContainer(
      overrides: [profileRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    setter = container.read(localeSetterProvider.notifier);
  });

  test('saves the language code, or null for the device language', () async {
    await setter.setLocale(const Locale('si', 'LK'));
    verify(() => repository.setLocale('si')).called(1);

    await setter.setLocale(null);
    verify(() => repository.setLocale(null)).called(1);
  });

  test('passes a failure through', () async {
    when(
      () => repository.setLocale(any()),
    ).thenAnswer((_) async => const Result.failure(StorageFailure('db')));

    expect((await setter.setLocale(const Locale('si'))).failureOrNull, isA<StorageFailure>());
  });
}
