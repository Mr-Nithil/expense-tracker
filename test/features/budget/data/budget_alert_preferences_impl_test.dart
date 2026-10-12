import 'package:expense_tracker/core/db/app_database.dart';
import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/features/budget/data/budget_alert_preferences_impl.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_database.dart';

void main() {
  late AppDatabase db;
  late BudgetAlertPreferencesImpl preferences;

  setUp(() {
    db = createTestDatabase();
    preferences = BudgetAlertPreferencesImpl(db.appSettingsDao);
  });

  test('off until enabled, and follows changes', () async {
    expect(await preferences.watchEnabled().first, isFalse);

    expect(await preferences.setEnabled(enabled: true), Result.ok);
    expect(await preferences.watchEnabled().first, isTrue);

    await preferences.setEnabled(enabled: false);
    expect(await preferences.watchEnabled().first, isFalse);
  });

  test('a storage error becomes a StorageFailure', () async {
    await db.customStatement('DROP TABLE app_settings');

    expect(
      (await preferences.setEnabled(enabled: true)).failureOrNull,
      isA<StorageFailure>(),
    );
  });
}
