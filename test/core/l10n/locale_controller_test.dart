import 'package:drift/drift.dart' show Value;
import 'package:expense_tracker/core/db/app_database.dart';
import 'package:expense_tracker/core/l10n/locale_controller.dart';
import 'package:expense_tracker/core/session/session.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_database.dart';

void main() {
  final now = DateTime.utc(2026, 10, 12);

  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    db = createTestDatabase();
    container = createTestContainer(db: db);
    container.listen(localeControllerProvider, (_, _) {});
  });

  Future<Locale?> locale() async {
    await pumpEventQueue();
    return container.read(localeControllerProvider.future);
  }

  Future<void> profile(String userId, String? locale) => db.profilesDao.insertProfile(
    ProfilesCompanion.insert(
      id: userId,
      userId: userId,
      createdAt: now,
      updatedAt: now,
      locale: Value(locale),
    ),
  );

  void signIn(String userId) =>
      container.read(sessionProvider.notifier).set(SessionUser(userId: userId));

  test('parse keeps only supported languages', () {
    expect(LocaleController.parse('si'), const Locale('si'));
    expect(LocaleController.parse('en'), const Locale('en'));
    expect(LocaleController.parse('fr'), isNull);
    expect(LocaleController.parse(null), isNull);
  });

  test('signed out, the app follows the device', () async {
    expect(await locale(), isNull);
  });

  test('signed in without a profile or a choice, the app follows the device', () async {
    signIn('u1');
    expect(await locale(), isNull);

    await profile('u1', null);
    expect(await locale(), isNull);
  });

  test('follows the profile, including a value pulled from another device', () async {
    await profile('u1', 'si');
    signIn('u1');
    expect(await locale(), const Locale('si'));

    // A pull (or a local change) updates the row.
    await db.profilesDao.updateProfile('u1', const ProfilesCompanion(locale: Value('en')));
    expect(await locale(), const Locale('en'));
  });

  test('a language this app version does not support follows the device', () async {
    await profile('u1', 'fr');
    signIn('u1');

    expect(await locale(), isNull);
  });

  test('uses only the signed-in user’s profile', () async {
    await profile('u2', 'si');
    signIn('u1');

    expect(await locale(), isNull);
  });
}
