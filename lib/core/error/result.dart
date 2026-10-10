import 'package:expense_tracker/core/error/app_failure.dart';

/// The outcome of a repository write: either a [Success] value or a [Failure].
///
/// Repositories return `Future<Result<T>>` and never throw (CONVENTIONS §8).
sealed class Result<T> {
  const Result();

  const factory Result.success(T value) = Success<T>;
  const factory Result.failure(AppFailure failure) = Failure<T>;

  /// A successful `Result<void>`.
  static const Result<void> ok = Success<void>(null);

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get valueOrNull => switch (this) {
    Success<T>(:final value) => value,
    Failure<T>() => null,
  };

  AppFailure? get failureOrNull => switch (this) {
    Success<T>() => null,
    Failure<T>(:final failure) => failure,
  };

  R when<R>({
    required R Function(T value) success,
    required R Function(AppFailure failure) failure,
  }) => switch (this) {
    Success<T>(:final value) => success(value),
    Failure<T>(failure: final f) => failure(f),
  };

  /// Transforms the success value, keeping a failure as is.
  Result<R> map<R>(R Function(T value) transform) => switch (this) {
    Success<T>(:final value) => Result<R>.success(transform(value)),
    Failure<T>(:final failure) => Result<R>.failure(failure),
  };
}

final class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;

  @override
  bool operator ==(Object other) => other is Success<T> && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Success($value)';
}

final class Failure<T> extends Result<T> {
  const Failure(this.failure);

  final AppFailure failure;

  @override
  bool operator ==(Object other) => other is Failure<T> && other.failure == failure;

  @override
  int get hashCode => failure.hashCode;

  @override
  String toString() => 'Failure($failure)';
}
