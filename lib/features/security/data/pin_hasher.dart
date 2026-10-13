import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

/// Salted, slow PIN hashing: PBKDF2-HMAC-SHA256 with a random 16-byte salt. The stored form is
/// `pbkdf2-sha256$<iterations>$<salt>$<hash>` (base64), so the cost can be raised later without
/// breaking stored PINs. Runs off the UI isolate.
class PinHasher {
  const PinHasher({this.iterations = defaultIterations, this.inBackground = true});

  static const defaultIterations = 100000;
  static const _scheme = 'pbkdf2-sha256';
  static const _saltLength = 16;

  final int iterations;

  /// Hash on a background isolate (the app). Off only for fake-time widget tests, where an
  /// isolate's result never arrives.
  final bool inBackground;

  Future<T> _run<T>(T Function() work) => inBackground ? Isolate.run(work) : Future.sync(work);

  Future<String> hash(String pin) {
    final random = Random.secure();
    final salt = Uint8List.fromList([for (var i = 0; i < _saltLength; i++) random.nextInt(256)]);
    final rounds = iterations;
    return _run(
      () => [
        _scheme,
        '$rounds',
        base64.encode(salt),
        base64.encode(_pbkdf2(pin, salt, rounds)),
      ].join(r'$'),
    );
  }

  /// Whether [pin] matches [stored]. `false` for a malformed [stored] value.
  Future<bool> verify(String pin, String stored) async {
    final parts = stored.split(r'$');
    if (parts.length != 4 || parts[0] != _scheme) return false;
    final rounds = int.tryParse(parts[1]);
    if (rounds == null || rounds < 1) return false;
    final Uint8List salt;
    final Uint8List expected;
    try {
      salt = base64.decode(parts[2]);
      expected = base64.decode(parts[3]);
    } on FormatException {
      return false;
    }
    final actual = await _run(() => _pbkdf2(pin, salt, rounds));
    return _constantTimeEquals(actual, expected);
  }

  /// One 32-byte PBKDF2 block (RFC 8018) with HMAC-SHA256.
  static Uint8List _pbkdf2(String pin, List<int> salt, int rounds) {
    final hmac = Hmac(sha256, utf8.encode(pin));
    var block = hmac.convert([...salt, 0, 0, 0, 1]).bytes;
    final result = Uint8List.fromList(block);
    for (var i = 1; i < rounds; i++) {
      block = hmac.convert(block).bytes;
      for (var j = 0; j < result.length; j++) {
        result[j] ^= block[j];
      }
    }
    return result;
  }

  static bool _constantTimeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }
}
