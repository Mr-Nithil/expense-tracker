import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:expense_tracker/core/db/app_database.dart';
import 'package:expense_tracker/core/db/database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

/// A fresh in-memory database, closed automatically at the end of the test.
AppDatabase createTestDatabase() {
  final db = AppDatabase(
    DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true),
  );
  addTearDown(db.close);
  return db;
}

/// A [ProviderContainer] backed by an in-memory database, disposed at the end of the test.
ProviderContainer createTestContainer({AppDatabase? db, List<Override> overrides = const []}) {
  final container = ProviderContainer(
    overrides: [databaseProvider.overrideWithValue(db ?? createTestDatabase()), ...overrides],
  );
  addTearDown(container.dispose);
  return container;
}
