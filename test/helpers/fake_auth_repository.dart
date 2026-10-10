import 'dart:async';

import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/features/auth/data/auth_repository_provider.dart';
import 'package:expense_tracker/features/auth/domain/auth_repository.dart';
import 'package:expense_tracker/features/auth/domain/entities/auth_snapshot.dart';
import 'package:expense_tracker/features/auth/domain/entities/auth_user.dart';
import 'package:expense_tracker/features/auth/domain/entities/sign_up_outcome.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

const testUser = AuthUser(id: 'user-1', email: 'me@example.com', displayName: 'Test User');

/// In-memory [AuthRepository]. Drive session changes with [emit] / [emitError].
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.currentUser = testUser}) {
    addTearDown(_changes.close);
    addTearDown(_linkErrors.close);
  }

  final _changes = StreamController<AuthSnapshot>.broadcast();
  final _linkErrors = StreamController<AuthFailure>.broadcast();

  /// Emails passed to [resendConfirmation], in order.
  final resentTo = <String>[];

  @override
  AuthUser? currentUser;

  /// Simulates a sign-in (`user`) or sign-out (`null`) event from the auth backend.
  void emit(AuthUser? user) {
    currentUser = user;
    _changes.add(AuthSnapshot(user: user));
  }

  /// Simulates opening a password-reset link (signed in, recovery pending).
  void emitRecovery(AuthUser user) {
    currentUser = user;
    _changes.add(AuthSnapshot(user: user, isPasswordRecovery: true));
  }

  void emitError(Object error) => _changes.addError(error);

  /// Simulates opening an email link that fails (expired, used, other device).
  void emitLinkError(AuthFailure failure) => _linkErrors.add(failure);

  @override
  Stream<AuthFailure> authLinkErrors() => _linkErrors.stream;

  @override
  Future<Result<void>> resendConfirmation({required String email}) async {
    resentTo.add(email);
    return Result.ok;
  }

  /// How many times [authStateChanges] was subscribed to.
  int subscriptionCount = 0;

  @override
  Stream<AuthSnapshot> authStateChanges() {
    subscriptionCount++;
    return _changes.stream;
  }

  @override
  Future<Result<AuthUser>> signIn({required String email, required String password}) async {
    emit(testUser);
    return const Result.success(testUser);
  }

  @override
  Future<Result<SignUpOutcome>> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    emit(testUser);
    return const Result.success(SignUpOutcome.signedIn);
  }

  @override
  Future<Result<void>> signOut() async {
    emit(null);
    return Result.ok;
  }

  @override
  Future<Result<void>> sendPasswordReset({required String email}) async => Result.ok;

  /// Like Supabase's `userUpdated`: the user stays signed in and recovery ends.
  @override
  Future<Result<void>> updatePassword({required String newPassword}) async {
    emit(currentUser);
    return Result.ok;
  }

  Override get providerOverride => authRepositoryProvider.overrideWithValue(this);
}
