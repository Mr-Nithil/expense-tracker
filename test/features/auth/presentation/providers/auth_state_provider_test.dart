import 'dart:async';

import 'package:expense_tracker/core/router/auth_status.dart';
import 'package:expense_tracker/core/session/session.dart';
import 'package:expense_tracker/features/auth/domain/entities/auth_snapshot.dart';
import 'package:expense_tracker/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fake_auth_repository.dart';
import '../../../../helpers/fake_local_data_repository.dart';

void main() {
  late FakeAuthRepository repository;
  late FakeLocalDataRepository localData;

  ProviderContainer createContainer() {
    final container = ProviderContainer(
      overrides: [repository.providerOverride, localData.providerOverride],
    );
    addTearDown(container.dispose);
    // The app keeps the binding alive the same way (App.build).
    container.listen(authStatusBindingProvider, (_, _) {});
    return container;
  }

  AuthStatus statusOf(ProviderContainer container) => container.read(authStatusControllerProvider);

  Future<void> flush() => Future<void>.delayed(Duration.zero);

  setUp(() {
    repository = FakeAuthRepository();
    localData = FakeLocalDataRepository();
  });

  test('authState starts with the restored user, then follows changes', () async {
    final container = createContainer();
    final values = <AuthSnapshot>[];
    container.listen(authStateProvider, (_, next) {
      if (next.hasValue) values.add(next.requireValue);
    });

    await flush();
    repository.emit(null);
    await flush();

    expect(values, [const AuthSnapshot(user: testUser), const AuthSnapshot()]);
  });

  test('status is unknown until the session is read', () {
    final container = createContainer();
    expect(statusOf(container), AuthStatus.unknown);
  });

  test('a restored session means signedIn (no network needed)', () async {
    final container = createContainer();
    await flush();
    expect(statusOf(container), AuthStatus.signedIn);
  });

  test('no stored session means signedOut', () async {
    repository = FakeAuthRepository(currentUser: null);
    final container = createContainer();
    await flush();
    expect(statusOf(container), AuthStatus.signedOut);
  });

  test('follows sign-out and sign-in events', () async {
    final container = createContainer();
    await flush();

    repository.emit(null);
    await flush();
    expect(statusOf(container), AuthStatus.signedOut);

    repository.emit(testUser);
    await flush();
    expect(statusOf(container), AuthStatus.signedIn);
  });

  test('a stream error keeps the current status', () async {
    final container = createContainer();
    await flush();

    repository.emitError(Exception('refresh failed offline'));
    await flush();

    expect(statusOf(container), AuthStatus.signedIn);
  });

  test('the session follows the signed-in user', () async {
    final container = createContainer();
    await flush();
    expect(
      container.read(sessionProvider),
      SessionUser(userId: testUser.id, displayName: testUser.displayName),
    );

    repository.emit(null);
    await flush();
    expect(container.read(sessionProvider), isNull);
  });

  test('a stream error keeps the session', () async {
    final container = createContainer();
    await flush();

    repository.emitError(Exception('refresh failed offline'));
    await flush();

    expect(container.read(sessionProvider)?.userId, testUser.id);
  });

  test('a stream error does not rebuild the provider, later events still arrive', () async {
    final container = createContainer();
    await flush();

    repository.emitError(Exception('refresh failed offline'));
    await Future<void>.delayed(const Duration(seconds: 1));
    expect(repository.subscriptionCount, 1);

    repository.emit(null);
    await flush();
    expect(statusOf(container), AuthStatus.signedOut);
  });

  test('a recovery link means passwordRecovery, with the session set', () async {
    final container = createContainer();
    await flush();

    repository.emitRecovery(testUser);
    await flush();
    expect(statusOf(container), AuthStatus.passwordRecovery);
    expect(container.read(sessionProvider)?.userId, testUser.id);

    await repository.updatePassword(newPassword: 'new-password');
    await flush();
    expect(statusOf(container), AuthStatus.signedIn);
  });

  group('local data ownership', () {
    test('stays on unknown (splash) until the local data is claimed', () async {
      localData.pending = Completer<void>();
      final container = createContainer();
      await flush();

      expect(localData.claims, [testUser.id]);
      expect(statusOf(container), AuthStatus.unknown);
      expect(container.read(sessionProvider)?.userId, testUser.id);

      localData.pending!.complete();
      await flush();
      expect(statusOf(container), AuthStatus.signedIn);
    });

    test('a token refresh for the same user does not claim again', () async {
      createContainer();
      await flush();

      repository.emit(testUser);
      await flush();

      expect(localData.claims, [testUser.id]);
    });

    test('every new sign-in is checked, even by the same user', () async {
      createContainer();
      await flush();

      repository.emit(null);
      await flush();
      repository.emit(testUser);
      await flush();

      expect(localData.claims, [testUser.id, testUser.id]);
    });

    test('signing out while the claim runs ends signed out', () async {
      localData.pending = Completer<void>();
      final container = createContainer();
      await flush();

      repository.emit(null);
      await flush();
      localData.pending!.complete();
      await flush();

      expect(statusOf(container), AuthStatus.signedOut);
      expect(container.read(sessionProvider), isNull);
    });
  });
}
