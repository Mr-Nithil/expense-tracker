import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:expense_tracker/core/db/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

import 'generated/schema.dart';
import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;
import 'generated/schema_v3.dart' as v3;

/// Verifies every migration against the schema dumps in `drift_schemas/`.
///
/// When bumping `schemaVersion`: run `dart run drift_dev make-migrations`, add the new step to
/// `stepByStep` in `AppDatabase`, and add a data test below for the new version.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  group('every version migrates to every later one', () {
    const versions = GeneratedHelper.versions;
    for (final (i, fromVersion) in versions.indexed) {
      for (final toVersion in versions.skip(i + 1)) {
        test('$fromVersion → $toVersion', () async {
          final schema = await verifier.schemaAt(fromVersion);
          final db = AppDatabase(schema.newConnection());
          await verifier.migrateAndValidate(db, toVersion);
          await db.close();
        });
      }
    }
  });

  test('a fresh database matches the latest schema', () async {
    final connection = await verifier.startAt(GeneratedHelper.versions.last);
    final db = AppDatabase(connection);
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, GeneratedHelper.versions.last);
  });

  test('v1 → v2 keeps existing reminders; day_of_month starts empty', () async {
    final at = DateTime.utc(2026, 10, 1, 8);
    await verifier.testWithDataIntegrity(
      oldVersion: 1,
      newVersion: 2,
      createOld: v1.DatabaseAtV1.new,
      createNew: v2.DatabaseAtV2.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) => batch.insertAll(oldDb.reminders, [
        v1.RemindersData(
          id: 'r1',
          userId: 'u1',
          createdAt: at,
          updatedAt: at,
          syncStatus: 1,
          title: 'Log expenses',
          timeOfDay: '20:30',
          repeatRule: 'weekly',
          weekdays: 0x1F,
          enabled: true,
        ),
      ]),
      validateItems: (newDb) async => expect(await newDb.select(newDb.reminders).get(), [
        v2.RemindersData(
          id: 'r1',
          userId: 'u1',
          createdAt: at,
          updatedAt: at,
          syncStatus: 1,
          title: 'Log expenses',
          timeOfDay: '20:30',
          repeatRule: 'weekly',
          weekdays: 0x1F,
          enabled: true,
        ),
      ]),
    );
  });

  test('v2 → v3 keeps existing rows and marks them as the user\'s', () async {
    final at = DateTime.utc(2026, 10, 1, 8);
    await verifier.testWithDataIntegrity(
      oldVersion: 2,
      newVersion: 3,
      createOld: v2.DatabaseAtV2.new,
      createNew: v3.DatabaseAtV3.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) => batch.insertAll(oldDb.reminders, [
        v2.RemindersData(
          id: 'r1',
          userId: 'u1',
          createdAt: at,
          updatedAt: at,
          syncStatus: 1,
          title: 'Pay rent',
          timeOfDay: '09:00',
          repeatRule: 'monthly',
          dayOfMonth: 31,
          enabled: true,
        ),
      ]),
      validateItems: (newDb) async => expect(await newDb.select(newDb.reminders).get(), [
        v3.RemindersData(
          id: 'r1',
          userId: 'u1',
          createdAt: at,
          updatedAt: at,
          syncStatus: 1,
          createdBy: 'user',
          updatedBy: 'user',
          title: 'Pay rent',
          timeOfDay: '09:00',
          repeatRule: 'monthly',
          dayOfMonth: 31,
          enabled: true,
        ),
      ]),
    );
  });
}
