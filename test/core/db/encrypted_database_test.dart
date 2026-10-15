import 'dart:io';

import 'package:expense_tracker/core/db/encrypted_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

import '../../helpers/fake_secure_storage.dart';

void main() {
  late Directory dir;
  late FakeSecureStorage storage;
  late List<(String, String)> conversions;
  late EncryptedDatabase opener;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('enc_db_test');
    addTearDown(() => dir.deleteSync(recursive: true));
    storage = FakeSecureStorage();
    conversions = [];
    opener = EncryptedDatabase(
      storage: storage,
      directory: () async => dir,
      convert: (file, key) => conversions.add((file.path, key)),
    );
  });

  File file() => File('${dir.path}/app.sqlite');

  /// A real plain SQLite file (header "SQLite format 3").
  void writePlain() {
    final db = sqlite3.open(file().path)..execute('CREATE TABLE t (x)');
    db.dispose();
  }

  void writeEncrypted() => file().writeAsBytesSync(List.generate(4096, (i) => (i * 31 + 7) & 0xFF));

  String? key() => storage.values[EncryptedDatabase.keyName];

  test('first start: a new 32-byte key, nothing to convert', () async {
    await opener.prepare('app');

    expect(key(), matches(RegExp(r'^[0-9a-f]{64}$')));
    expect(conversions, isEmpty);
  });

  test('an existing plain database (before M11.8) gets a key and is converted', () async {
    writePlain();
    expect(EncryptedDatabase.stateOf(file()), DatabaseFileState.plain);

    await opener.prepare('app');

    expect(conversions, [(file().path, key()!)]);
  });

  test(
    'a plain file with a key already stored (interrupted conversion) is converted with it',
    () async {
      writePlain();
      storage.values[EncryptedDatabase.keyName] = 'ab' * 32;

      await opener.prepare('app');

      expect(conversions, [(file().path, 'ab' * 32)]);
    },
  );

  test('an encrypted file with its key is just opened', () async {
    writeEncrypted();
    storage.values[EncryptedDatabase.keyName] = 'cd' * 32;

    await opener.prepare('app');

    expect(EncryptedDatabase.stateOf(file()), DatabaseFileState.encrypted);
    expect(file().existsSync(), isTrue);
    expect(key(), 'cd' * 32);
    expect(conversions, isEmpty);
  });

  test('an encrypted file whose key was lost is replaced by a new database', () async {
    writeEncrypted();
    File('${file().path}-wal').writeAsStringSync('x');

    await opener.prepare('app');

    expect(file().existsSync(), isFalse);
    expect(File('${file().path}-wal').existsSync(), isFalse);
    expect(key(), isNotNull);
  });

  test('logout keeps the database key (the file stays and must still open)', () async {
    await opener.prepare('app');
    final before = key();
    storage.values['data_key'] = 'user secret';

    await storage.deleteAll();

    expect(key(), before);
    expect(storage.values.containsKey('data_key'), isFalse);
  });

  test('refuses to unlock a SQLite that is not SQLCipher (no silent plain-text database)', () {
    final db = sqlite3.openInMemory();
    addTearDown(db.dispose);

    expect(() => EncryptedDatabase.unlock(db, 'ab' * 32), throwsStateError);
  });
}
