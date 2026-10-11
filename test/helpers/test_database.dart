import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:expense_tracker/core/db/app_database.dart';
import 'package:expense_tracker/core/db/database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'fake_sync_trigger.dart';

/// A fresh in-memory database, closed automatically at the end of the test.
AppDatabase createTestDatabase() {
  final db = AppDatabase(
    DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true),
  );
  addTearDown(db.close);
  return db;
}

/// A [ProviderContainer] backed by an in-memory database, disposed at the end of the test.
///
/// Sync is never triggered for real: repositories get a [FakeSyncTrigger] ([syncTrigger] lets a
/// test pass its own to inspect it), so no test reaches Supabase.
ProviderContainer createTestContainer({
  AppDatabase? db,
  FakeSyncTrigger? syncTrigger,
  List<Override> overrides = const [],
}) {
  final container = ProviderContainer(
    retry: noAutoRetry,
    overrides: [
      databaseProvider.overrideWithValue(db ?? createTestDatabase()),
      (syncTrigger ?? FakeSyncTrigger()).providerOverride,
      ...overrides,
    ],
  );
  addTearDown(container.dispose);
  return container;
}

/// Turns off Riverpod's automatic retry of failed providers in tests, so an error stays until
/// something (e.g. a Retry button) explicitly retries. Otherwise retry tests could pass by
/// themselves.
Duration? noAutoRetry(int retryCount, Object error) => null;
