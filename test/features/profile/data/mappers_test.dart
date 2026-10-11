import 'package:expense_tracker/features/profile/data/mappers.dart';
import 'package:expense_tracker/features/profile/domain/entities/profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every theme mode round-trips through its DB value', () {
    for (final mode in AppThemeMode.values) {
      expect(AppThemeModeDb.fromDb(mode.dbValue), mode);
    }
  });

  test('unknown or missing values fall back to system', () {
    expect(AppThemeModeDb.fromDb('sepia'), AppThemeMode.system);
    expect(AppThemeModeDb.fromDb(null), AppThemeMode.system);
  });
}
