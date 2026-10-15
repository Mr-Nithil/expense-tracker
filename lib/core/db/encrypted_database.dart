import 'dart:io';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:expense_tracker/core/logging/app_logger.dart';
import 'package:expense_tracker/core/services/secure_storage_service.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';
import 'package:sqlite3/open.dart';
import 'package:sqlite3/sqlite3.dart';

/// What is on disk where the database lives.
enum DatabaseFileState { missing, plain, encrypted }

/// The app database file, encrypted with SQLCipher (M11.8, ARCHITECTURE §13). The key is 32
/// random bytes in secure storage.
///
/// | key \ file | missing | plain (before M11.8) | encrypted |
/// |---|---|---|---|
/// | stored | create | convert | open |
/// | none | new key, create | new key, convert | key lost (e.g. secure storage reset by the OS): delete the file, new key, create — its data is in the cloud |
///
/// Refuses to open when SQLCipher isn't really loaded (no silent plain-text database).
class EncryptedDatabase {
  EncryptedDatabase({
    required this.storage,
    Future<Directory> Function()? directory,
    void Function(File plain, String keyHex)? convert,
  }) : _directory = directory ?? getApplicationDocumentsDirectory,
       _convert = convert ?? convertToEncrypted;

  static const keyName = SecureStorageService.databaseKeyName;
  static const _plainHeader = 'SQLite format 3\u0000';

  final SecureStorageService storage;
  final Future<Directory> Function() _directory;
  final void Function(File plain, String keyHex) _convert;

  /// The executor for [AppDatabase]; opens lazily on first use.
  QueryExecutor executor(String name) => LazyDatabase(() async {
    final file = await prepare(name);
    final keyHex = (await storage.read(keyName))!;
    return NativeDatabase.createInBackground(
      file,
      isolateSetup: useSqlCipher,
      setup: (db) => unlock(db, keyHex),
    );
  });

  /// Makes sure [name]'s file and key are ready (the table above) and returns the file.
  Future<File> prepare(String name) async {
    final file = File(p.join((await _directory()).path, '$name.sqlite'));
    final state = stateOf(file);
    var keyHex = await storage.read(keyName);

    if (keyHex == null) {
      if (state == DatabaseFileState.encrypted) {
        AppLogger.warning('database key missing: starting a new local database');
        await deleteFiles(file);
      }
      keyHex = _newKeyHex();
      await storage.write(keyName, keyHex);
    }
    if (state == DatabaseFileState.plain) {
      AppLogger.info('encrypting the local database');
      _convert(file, keyHex);
    }
    return file;
  }

  static DatabaseFileState stateOf(File file) {
    if (!file.existsSync() || file.lengthSync() == 0) return DatabaseFileState.missing;
    final handle = file.openSync();
    try {
      final header = String.fromCharCodes(handle.readSync(_plainHeader.length));
      return header == _plainHeader ? DatabaseFileState.plain : DatabaseFileState.encrypted;
    } finally {
      handle.closeSync();
    }
  }

  static Future<void> deleteFiles(File file) async {
    for (final path in [
      file.path,
      '${file.path}-wal',
      '${file.path}-shm',
      '${file.path}-journal',
    ]) {
      final part = File(path);
      if (part.existsSync()) await part.delete();
    }
  }

  static String _newKeyHex() {
    final random = Random.secure();
    return [
      for (var i = 0; i < 32; i++) random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ].join();
  }

  /// Loads SQLCipher instead of the system SQLite (in every isolate that opens the database).
  static void useSqlCipher() => open.overrideFor(OperatingSystem.android, openCipherOnAndroid);

  /// Unlocks a connection, and fails if SQLCipher isn't the library actually in use.
  static void unlock(Database db, String keyHex) {
    final rows = db.select('PRAGMA cipher_version;');
    if (rows.isEmpty) throw StateError('SQLCipher is not available: refusing to open');
    db.execute("PRAGMA key = \"x'$keyHex'\";");
    // Fails here (not later, mid-query) when the key doesn't match the file.
    db.select('SELECT count(*) FROM sqlite_master;');
  }

  /// Converts a plain database file to an encrypted one in place, keeping drift's schema version.
  static void convertToEncrypted(File plain, String keyHex) {
    useSqlCipher();
    final target = File('${plain.path}.encrypting');
    if (target.existsSync()) target.deleteSync();
    final db = sqlite3.open(plain.path);
    try {
      if (db.select('PRAGMA cipher_version;').isEmpty) {
        throw StateError('SQLCipher is not available: refusing to convert');
      }
      final version = db.select('PRAGMA user_version;').first.columnAt(0) as int;
      final escaped = target.path.replaceAll("'", "''");
      db
        ..execute("ATTACH DATABASE '$escaped' AS encrypted KEY \"x'$keyHex'\";")
        ..execute("SELECT sqlcipher_export('encrypted');")
        ..execute('PRAGMA encrypted.user_version = $version;')
        ..execute('DETACH DATABASE encrypted;');
    } finally {
      db.dispose();
    }
    for (final suffix in ['-wal', '-shm', '-journal']) {
      final part = File('${plain.path}$suffix');
      if (part.existsSync()) part.deleteSync();
    }
    target.renameSync(plain.path);
  }
}
