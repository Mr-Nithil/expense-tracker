import 'package:expense_tracker/core/db/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_database.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = createTestDatabase());

  test('get returns null for a missing key', () async {
    expect(await db.appSettingsDao.getValue('missing'), isNull);
  });

  test('set inserts then overwrites', () async {
    await db.appSettingsDao.setValue('theme_mode', 'dark');
    await db.appSettingsDao.setValue('theme_mode', 'light');
    expect(await db.appSettingsDao.getValue('theme_mode'), 'light');
  });

  test('remove deletes the key', () async {
    await db.appSettingsDao.setValue('k', 'v');
    await db.appSettingsDao.removeValue('k');
    expect(await db.appSettingsDao.getValue('k'), isNull);
  });

  test('watch emits changes', () async {
    final values = db.appSettingsDao.watchValue('k');
    final expectation = expectLater(values, emitsInOrder([null, 'a', 'b']));
    await pumpEventQueue();
    await db.appSettingsDao.setValue('k', 'a');
    await pumpEventQueue();
    await db.appSettingsDao.setValue('k', 'b');
    await expectation;
  });
}
