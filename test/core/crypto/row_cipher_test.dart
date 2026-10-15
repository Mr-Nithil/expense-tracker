import 'package:expense_tracker/core/crypto/row_cipher.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final key = List<int>.generate(32, (i) => i);
  final otherKey = List<int>.generate(32, (i) => 255 - i);
  const fields = {'amount_minor': 1250, 'note': 'Lunch ☕ කෑම'};

  Future<String> seal(RowCipher cipher, {String table = 'transactions', String id = 't1'}) =>
      cipher.seal(fields, table: table, id: id, userId: 'u1');

  Future<Map<String, Object?>> open(
    RowCipher cipher,
    String envelope, {
    String table = 'transactions',
    String id = 't1',
    String userId = 'u1',
  }) => cipher.open(envelope, table: table, id: id, userId: userId);

  final fails = throwsA(isA<RowCipherException>());

  test('round trip, including null, unicode and large numbers', () async {
    final cipher = RowCipher(key);
    const values = {'amount_minor': 9007199254740991, 'note': null, 'name': 'සිංහල 🎉'};

    final envelope = await cipher.seal(values, table: 'transactions', id: 't1', userId: 'u1');

    expect(await open(cipher, envelope), values);
    expect(envelope, startsWith('v1.'));
    expect(envelope, isNot(contains('සිංහල')));
  });

  test('matches AES-256-GCM from OpenSSL (Python cryptography) byte for byte', () async {
    final cipher = RowCipher(key, nonces: () => List<int>.generate(12, (i) => 100 + i));

    expect(
      await seal(cipher),
      'v1.ZGVmZ2hpamtsbW5v.Mzm_CxacOOphDzaGtRdIx3PwMzqnTp0d07SOctnv0Cb3gWAi1Ie75EtpmIhsonx3OSYVkaovl_FL0rAF_fsfRBNu',
    );
    expect(
      await open(
        RowCipher(key),
        'v1.ZGVmZ2hpamtsbW5v.Mzm_CxacOOphDzaGtRdIx3PwMzqnTp0d07SOctnv0Cb3gWAi1Ie75EtpmIhsonx3OSYVkaovl_FL0rAF_fsfRBNu',
      ),
      fields,
    );
  });

  test('every seal uses a fresh nonce', () async {
    final cipher = RowCipher(key);
    expect(await seal(cipher), isNot(await seal(cipher)));
  });

  test('another key cannot open it', () async {
    final envelope = await seal(RowCipher(key));
    await expectLater(open(RowCipher(otherKey), envelope), fails);
  });

  test('it only opens for its own table, row and user', () async {
    final cipher = RowCipher(key);
    final envelope = await seal(cipher);

    await expectLater(open(cipher, envelope, id: 't2'), fails);
    await expectLater(open(cipher, envelope, table: 'goal_contributions'), fails);
    await expectLater(open(cipher, envelope, userId: 'u2'), fails);
  });

  test('any change to the ciphertext is detected', () async {
    final cipher = RowCipher(key);
    final envelope = await seal(cipher);
    final parts = envelope.split('.');
    final body = parts[2];
    final flipped = (body[5] == 'A' ? 'B' : 'A');
    final tampered = [parts[0], parts[1], body.replaceRange(5, 6, flipped)].join('.');

    await expectLater(open(cipher, tampered), fails);
  });

  test('unknown or malformed envelopes are rejected', () async {
    final cipher = RowCipher(key);
    for (final envelope in ['', 'v1', 'v2.a.b', 'v1.%%%.b', 'v1.AAAA.BBBB', 'plain text']) {
      await expectLater(open(cipher, envelope), fails, reason: envelope);
    }
  });

  test('the key must be 32 bytes', () {
    expect(() => RowCipher(List.filled(16, 0)), throwsArgumentError);
  });
}
