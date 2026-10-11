import 'package:drift/drift.dart' show Value;
import 'package:expense_tracker/core/db/app_database.dart';
import 'package:expense_tracker/core/session/session.dart';
import 'package:expense_tracker/core/theme/theme_mode_controller.dart';
import 'package:flutter/material.dart';
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
    container.listen(themeModeControllerProvider, (_, _) {});
  });

  Future<ThemeMode> theme() async {
    await pumpEventQueue();
    return container.read(themeModeControllerProvider.future);
  }

  Future<void> profile(String userId, String themeMode) => db.profilesDao.insertProfile(
    ProfilesCompanion.insert(
      id: userId,
      userId: userId,
      createdAt: now,
      updatedAt: now,
      themeMode: Value(themeMode),
    ),
  );

  void signIn(String userId) =>
      container.read(sessionProvider.notifier).set(SessionUser(userId: userId));

  test('parse falls back to system for unknown or missing values', () {
    expect(ThemeModeController.parse(null), ThemeMode.system);
    expect(ThemeModeController.parse('sepia'), ThemeMode.system);
    expect(ThemeModeController.parse('dark'), ThemeMode.dark);
  });

  test('signed out, the app follows the system', () async {
    expect(await theme(), ThemeMode.system);
  });

  test('signed in without a profile yet, the app follows the system', () async {
    signIn('u1');
    expect(await theme(), ThemeMode.system);
  });

  test('follows the profile, including a value pulled from another device', () async {
    await profile('u1', 'dark');
    signIn('u1');
    expect(await theme(), ThemeMode.dark);

    // A pull (or a local change) updates the row.
    await db.profilesDao.updateProfile('u1', const ProfilesCompanion(themeMode: Value('light')));
    expect(await theme(), ThemeMode.light);
  });

  test('uses only the signed-in user’s profile', () async {
    await profile('u2', 'dark');
    signIn('u1');

    expect(await theme(), ThemeMode.system);
  });
}
