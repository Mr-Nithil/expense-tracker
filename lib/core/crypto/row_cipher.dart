import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// A row's private fields could not be opened: tampered with, another key, another row, or an
/// unknown format. Never shown to users; sync reports it as a failed run (ARCHITECTURE §13).
class RowCipherException implements Exception {
  const RowCipherException(this.message);

  final String message;

  @override
  String toString() => 'RowCipherException: $message';
}

/// Seals a row's private fields for the cloud and opens them again (M11, ARCHITECTURE §13).
///
/// The fields become one JSON object, encrypted with AES-256-GCM under the user's data key with a
/// random 12-byte nonce: `v1.<nonce>.<ciphertext+tag>` (base64url, no padding). The authenticated
/// data `expense-tracker/v1|<table>|<id>|<user_id>` binds it to its row: copied to another row or
/// user, it fails to open.
class RowCipher {
  /// [key] is the user's 32-byte data key. [nonces] is for tests (fixed nonces).
  RowCipher(List<int> key, {List<int> Function()? nonces})
    : _key = SecretKey(Uint8List.fromList(key)),
      _nonces = nonces ?? _randomNonce {
    if (key.length != keyLength) throw ArgumentError.value(key.length, 'key', 'must be 32 bytes');
  }

  static const keyLength = 32;
  static const version = 'v1';
  static const _nonceLength = 12;
  static const _macLength = 16;
  static final _algorithm = AesGcm.with256bits();
  static final _random = Random.secure();

  final SecretKey _key;
  final List<int> Function() _nonces;

  static List<int> _randomNonce() => [for (var i = 0; i < _nonceLength; i++) _random.nextInt(256)];

  static List<int> _aad(String table, String id, String userId) =>
      utf8.encode('expense-tracker/$version|$table|$id|$userId');

  static String _b64(List<int> bytes) => base64Url.encode(bytes).replaceAll('=', '');

  static List<int> _unb64(String text) => base64Url.decode(base64Url.normalize(text));

  Future<String> seal(
    Map<String, Object?> fields, {
    required String table,
    required String id,
    required String userId,
  }) async {
    final box = await _algorithm.encrypt(
      utf8.encode(jsonEncode(fields)),
      secretKey: _key,
      nonce: _nonces(),
      aad: _aad(table, id, userId),
    );
    return [
      version,
      _b64(box.nonce),
      _b64([...box.cipherText, ...box.mac.bytes]),
    ].join('.');
  }

  /// The fields sealed by [seal] for this row. Throws [RowCipherException] if they can't be
  /// opened.
  Future<Map<String, Object?>> open(
    String envelope, {
    required String table,
    required String id,
    required String userId,
  }) async {
    final parts = envelope.split('.');
    if (parts.length != 3 || parts[0] != version) {
      throw const RowCipherException('unknown envelope format');
    }
    final List<int> nonce;
    final List<int> sealed;
    try {
      nonce = _unb64(parts[1]);
      sealed = _unb64(parts[2]);
    } on FormatException {
      throw const RowCipherException('malformed envelope');
    }
    if (nonce.length != _nonceLength || sealed.length < _macLength) {
      throw const RowCipherException('malformed envelope');
    }
    try {
      final clear = await _algorithm.decrypt(
        SecretBox(
          sealed.sublist(0, sealed.length - _macLength),
          nonce: nonce,
          mac: Mac(sealed.sublist(sealed.length - _macLength)),
        ),
        secretKey: _key,
        aad: _aad(table, id, userId),
      );
      return jsonDecode(utf8.decode(clear)) as Map<String, Object?>;
    } on SecretBoxAuthenticationError {
      throw const RowCipherException('authentication failed');
    } on FormatException {
      throw const RowCipherException('not a JSON object');
    }
  }
}
