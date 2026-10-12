import 'dart:async';

import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/l10n/generated/app_localizations_en.dart';
import 'package:expense_tracker/features/categories/presentation/providers/default_categories_seeder.dart';
import 'package:expense_tracker/features/profile/data/profile_repository_provider.dart';
import 'package:expense_tracker/features/profile/domain/entities/profile.dart';
import 'package:expense_tracker/features/profile/domain/profile_repository.dart';
import 'package:expense_tracker/features/profile/presentation/screens/onboarding_screen.dart';
import 'package:expense_tracker/features/profile/presentation/widgets/currency_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/accessibility.dart';
import '../../../../helpers/pump_app.dart';

class _MockProfileRepository extends Mock implements ProfileRepository {}

class _MockSeeder extends Mock implements DefaultCategoriesSeeder {}

void main() {
  final l10n = AppLocalizationsEn();

  late _MockProfileRepository repository;
  late _MockSeeder seeder;

  setUp(() {
    repository = _MockProfileRepository();
    seeder = _MockSeeder();
    when(() => seeder.seed()).thenAnswer((_) async => const Result.success(13));
  });

  Future<void> pumpOnboarding(
    WidgetTester tester, {
    Locale deviceLocale = const Locale('de', 'DE'),
    Brightness brightness = Brightness.light,
  }) async {
    tester.platformDispatcher.localeTestValue = deviceLocale;
    addTearDown(tester.platformDispatcher.clearLocaleTestValue);
    await tester.pumpApp(
      const OnboardingScreen(),
      brightness: brightness,
      overrides: [
        profileRepositoryProvider.overrideWithValue(repository),
        defaultCategoriesSeederProvider.overrideWithValue(seeder),
      ],
    );
  }

  CurrencyTile tile(WidgetTester tester, String code) => tester.widget(
    find.ancestor(of: find.text(code), matching: find.byType(CurrencyTile)),
  );
  Finder continueButton() => find.widgetWithText(FilledButton, l10n.onboardingContinue);

  testWidgetsBothThemes('renders the currency list', (tester, brightness) async {
    await pumpOnboarding(tester, brightness: brightness);

    expect(find.text(l10n.onboardingSubtitle), findsOneWidget);
    expect(find.byType(CurrencyTile), findsWidgets);
    expect(continueButton(), findsOneWidget);
  });

  testWidgets('pre-selects and lists first the device currency', (tester) async {
    await pumpOnboarding(tester);

    final first = tester.widget<CurrencyTile>(find.byType(CurrencyTile).first);
    expect(first.currencyCode, 'EUR');
    expect(first.selected, isTrue);
    expect(first.suggested, isTrue);
  });

  testWidgets('saves the tapped currency', (tester) async {
    when(() => repository.setCurrency(any())).thenAnswer(
      (_) async => const Result.success(Profile(id: 'u1', currencyCode: 'AED')),
    );
    await pumpOnboarding(tester);

    await tester.tap(find.text('AED'));
    await tester.pump();
    expect(tile(tester, 'AED').selected, isTrue);
    expect(tile(tester, 'EUR').selected, isFalse);

    await tester.tap(continueButton());
    await tester.pump();

    verify(() => repository.setCurrency('AED')).called(1);
  });

  testWidgets('shows the loading state while saving', (tester) async {
    final completer = Completer<Result<Profile>>();
    when(() => repository.setCurrency(any())).thenAnswer((_) => completer.future);
    await pumpOnboarding(tester);

    await tester.tap(continueButton());
    await tester.pump();

    expect(
      find.descendant(of: continueButton(), matching: find.byType(CircularProgressIndicator)),
      findsOneWidget,
    );
    completer.complete(const Result.success(Profile(id: 'u1', currencyCode: 'EUR')));
    await tester.pumpAndSettle();
  });

  testWidgets('a failure shows a snackbar', (tester) async {
    when(
      () => repository.setCurrency(any()),
    ).thenAnswer((_) async => const Result.failure(StorageFailure('disk full')));
    await pumpOnboarding(tester);

    await tester.tap(continueButton());
    await tester.pumpAndSettle();

    expect(find.text(l10n.errorStorage), findsOneWidget);
  });

  group('accessibility (M9.5)', () {
    testWidgetsBothThemes('meets the guidelines', (tester, brightness) async {
      await pumpOnboarding(tester, brightness: brightness);
      await tester.pumpAndSettle();
      await expectAccessible(tester);
    });

    testWidgets('large text (2x) fits', (tester) async {
      useTextScale(tester, 2);
      await pumpOnboarding(tester);
      await tester.pumpAndSettle();
      await scrollThrough(tester);
    });
  });
}
