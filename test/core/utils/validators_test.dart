import 'package:expense_tracker/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('required', () {
    test('rejects null, empty and whitespace', () {
      for (final value in [null, '', '   ']) {
        expect(Validators.required(value), ValidationError.required, reason: '$value');
      }
    });

    test('accepts text', () => expect(Validators.required('a'), isNull));
  });

  group('email', () {
    test('accepts normal addresses, ignoring surrounding spaces', () {
      for (final value in ['a@b.co', 'first.last+tag@mail.example.com', ' me@x.io ']) {
        expect(Validators.email(value), isNull, reason: value);
      }
    });

    test('rejects malformed addresses', () {
      for (final value in ['plain', 'a@b', '@b.co', 'a@.', 'a b@c.co', 'a@b c.co']) {
        expect(Validators.email(value), ValidationError.invalidEmail, reason: value);
      }
    });

    test('reports empty as required', () {
      expect(Validators.email(''), ValidationError.required);
    });
  });

  group('password', () {
    test('requires the minimum length', () {
      expect(
        Validators.password('a' * (Validators.minPasswordLength - 1)),
        ValidationError.passwordTooShort,
      );
      expect(Validators.password('a' * Validators.minPasswordLength), isNull);
    });

    test('reports empty as required', () {
      expect(Validators.password(''), ValidationError.required);
    });
  });

  group('passwordConfirmation', () {
    test('accepts an exact repeat', () {
      expect(Validators.passwordConfirmation('secret-123', 'secret-123'), isNull);
    });

    test('rejects a different value, including whitespace differences', () {
      for (final value in ['secret-124', 'secret-123 ', 'SECRET-123']) {
        expect(
          Validators.passwordConfirmation('secret-123', value),
          ValidationError.passwordMismatch,
          reason: value,
        );
      }
    });

    test('reports empty as required', () {
      expect(Validators.passwordConfirmation('secret-123', ''), ValidationError.required);
    });
  });
}
