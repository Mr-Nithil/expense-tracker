import 'package:expense_tracker/features/security/data/pin_hasher.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const hasher = PinHasher(iterations: 1000);

  test('a hash verifies its own PIN only', () async {
    final stored = await hasher.hash('1234');

    expect(await hasher.verify('1234', stored), isTrue);
    expect(await hasher.verify('1235', stored), isFalse);
    expect(await hasher.verify('12345', stored), isFalse);
  });

  test('never stores the PIN and salts every hash', () async {
    final a = await hasher.hash('1234');
    final b = await hasher.hash('1234');

    expect(a, isNot(contains('1234')));
    expect(a, isNot(b));
    expect(a, startsWith(r'pbkdf2-sha256$1000$'));
  });

  test('verifies with the iteration count stored in the hash', () async {
    final stored = await hasher.hash('987654');

    expect(await const PinHasher(iterations: 5).verify('987654', stored), isTrue);
  });

  test('matches the RFC 7914 PBKDF2-HMAC-SHA256 test vector', () async {
    // P = "passwd", S = "salt", c = 1, first 32 bytes.
    expect(
      await hasher.verify(
        'passwd',
        r'pbkdf2-sha256$1$c2FsdA==$VawEblbjCJ/sFpHCJUS2BflBhSFt3gRl5oudV8INrLw=',
      ),
      isTrue,
    );
    // P = "Password", S = "NaCl", c = 80000: exercises the iteration loop.
    expect(
      await hasher.verify(
        'Password',
        r'pbkdf2-sha256$80000$TmFDbA==$TdzY9guYviGDDO5e8icB+WQaRBjQTAQUrv8Ih2s0q1Y=',
      ),
      isTrue,
    );
  });

  test('hashing inline (tests) gives the same results', () async {
    const inline = PinHasher(iterations: 1000, inBackground: false);
    expect(await inline.verify('1234', await hasher.hash('1234')), isTrue);
    expect(await hasher.verify('1234', await inline.hash('1234')), isTrue);
  });

  test('a malformed stored value never verifies', () async {
    for (final stored in [
      '',
      'plain',
      r'md5$1$a$b',
      r'pbkdf2-sha256$x$a$b',
      r'pbkdf2-sha256$1$%$b',
    ]) {
      expect(await hasher.verify('1234', stored), isFalse, reason: stored);
    }
  });
}
