import 'package:drift_dev/api/migrations_native.dart';
import 'package:expense_tracker/core/db/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

import 'generated/schema.dart';

/// Verifies the live schema matches the dumped schema files in `drift_schemas/`.
///
/// When bumping `schemaVersion`: run `dart run drift_dev make-migrations`, then add a test here
/// migrating from every older version to the new one.
void main() {
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  test('fresh database matches schema v1', () async {
    final connection = await verifier.startAt(1);
    final db = AppDatabase(connection);
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, 1);
  });
}
