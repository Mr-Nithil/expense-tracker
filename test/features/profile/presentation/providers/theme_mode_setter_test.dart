import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/features/profile/data/profile_repository_provider.dart';
import 'package:expense_tracker/features/profile/domain/entities/profile.dart';
import 'package:expense_tracker/features/profile/domain/profile_repository.dart';
import 'package:expense_tracker/features/profile/presentation/providers/theme_mode_setter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  late _MockProfileRepository repository;
  late ThemeModeSetter setter;

  setUpAll(() => registerFallbackValue(AppThemeMode.system));

  setUp(() {
    repository = _MockProfileRepository();
    when(
      () => repository.setThemeMode(any()),
    ).thenAnswer((_) async => const Result.success(Profile(id: 'u1')));
    final container = ProviderContainer(
      overrides: [profileRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    setter = container.read(themeModeSetterProvider.notifier);
  });

  test('maps each Flutter theme mode to the profile value', () async {
    for (final (mode, expected) in [
      (ThemeMode.system, AppThemeMode.system),
      (ThemeMode.light, AppThemeMode.light),
      (ThemeMode.dark, AppThemeMode.dark),
    ]) {
      await setter.setThemeMode(mode);
      verify(() => repository.setThemeMode(expected)).called(1);
    }
  });

  test('passes a failure through', () async {
    when(
      () => repository.setThemeMode(any()),
    ).thenAnswer((_) async => const Result.failure(StorageFailure('db')));

    expect((await setter.setThemeMode(ThemeMode.dark)).failureOrNull, isA<StorageFailure>());
  });
}
