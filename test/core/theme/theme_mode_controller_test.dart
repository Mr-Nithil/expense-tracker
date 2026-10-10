import 'package:expense_tracker/core/db/app_database.dart';
import 'package:expense_tracker/core/theme/theme_mode_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_database.dart';

void main() {
  test('parse falls back to system for missing or unknown values', () {
    expect(ThemeModeController.parse(null), ThemeMode.system);
    expect(ThemeModeController.parse('sepia'), ThemeMode.system);
    expect(ThemeModeController.parse('dark'), ThemeMode.dark);
  });

  test('defaults to system and persists changes to app_settings', () async {
    final AppDatabase db = createTestDatabase();
    final container = createTestContainer(db: db);
    final subscription = container.listen(themeModeControllerProvider, (_, _) {});
    addTearDown(subscription.close);

    expect(await container.read(themeModeControllerProvider.future), ThemeMode.system);

    await container.read(themeModeControllerProvider.notifier).setThemeMode(ThemeMode.dark);
    await pumpEventQueue();

    expect(container.read(themeModeControllerProvider).value, ThemeMode.dark);
    expect(await db.appSettingsDao.getValue(ThemeModeController.settingsKey), 'dark');
  });

  test('reads a previously stored value', () async {
    final db = createTestDatabase();
    await db.appSettingsDao.setValue(ThemeModeController.settingsKey, 'light');
    final container = createTestContainer(db: db);
    // Riverpod 3 pauses providers that are read but not listened to.
    final subscription = container.listen(themeModeControllerProvider, (_, _) {});
    addTearDown(subscription.close);

    expect(await container.read(themeModeControllerProvider.future), ThemeMode.light);
  });
}
