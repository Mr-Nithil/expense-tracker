import 'package:expense_tracker/core/db/app_database.dart';
import 'package:expense_tracker/core/db/encrypted_database.dart';
import 'package:expense_tracker/core/services/secure_storage_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'database_provider.g.dart';

/// The app database, encrypted on disk with SQLCipher (M11.8). Override with an in-memory database
/// in tests.
@Riverpod(keepAlive: true)
AppDatabase database(Ref ref) {
  final db = AppDatabase(
    EncryptedDatabase(
      storage: ref.watch(secureStorageServiceProvider),
    ).executor(AppDatabase.databaseName),
  );
  ref.onDispose(db.close);
  return db;
}
