import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const failure = ValidationFailure('amount must be > 0', field: 'amount');

  group('Result', () {
    test('success exposes its value', () {
      const result = Result<int>.success(42);
      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.valueOrNull, 42);
      expect(result.failureOrNull, isNull);
    });

    test('failure exposes its failure', () {
      const result = Result<int>.failure(failure);
      expect(result.isFailure, isTrue);
      expect(result.valueOrNull, isNull);
      expect(result.failureOrNull, same(failure));
    });

    test('when picks the matching branch', () {
      String describe(Result<int> r) => r.when(success: (v) => 'ok $v', failure: (f) => f.message);
      expect(describe(const Result.success(1)), 'ok 1');
      expect(describe(const Result.failure(failure)), 'amount must be > 0');
    });

    test('map transforms success and keeps failure', () {
      expect(const Result<int>.success(2).map((v) => v * 10), const Result<int>.success(20));
      final mapped = const Result<int>.failure(failure).map((v) => v * 10);
      expect(mapped.failureOrNull, same(failure));
    });

    test('ok is a successful void result', () {
      expect(Result.ok.isSuccess, isTrue);
    });

    test('pattern matching is exhaustive over Success and Failure', () {
      const Result<String> result = Success('x');
      final text = switch (result) {
        Success(:final value) => value,
        Failure(:final failure) => failure.message,
      };
      expect(text, 'x');
    });
  });

  group('AppFailure', () {
    test('ValidationFailure keeps the field', () {
      expect(failure.field, 'amount');
      expect(failure.toString(), contains('ValidationFailure'));
    });

    test('UnexpectedFailure keeps the cause', () {
      final cause = StateError('boom');
      expect(UnexpectedFailure('x', cause: cause).cause, same(cause));
    });
  });
}
