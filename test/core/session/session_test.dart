import 'package:expense_tracker/core/session/session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
    addTearDown(container.dispose);
  });

  Session session() => container.read(sessionProvider.notifier);

  test('starts signed out and requireUserId throws', () {
    expect(container.read(sessionProvider), isNull);
    expect(session().requireUserId, throwsStateError);
  });

  test('requireUserId returns the set user', () {
    session().set(const SessionUser(userId: 'u1', displayName: 'Me'));
    expect(session().requireUserId(), 'u1');

    session().set(null);
    expect(session().requireUserId, throwsStateError);
  });

  test('SessionUser equality covers id and display name', () {
    const a = SessionUser(userId: 'u1', displayName: 'A');
    expect(a, const SessionUser(userId: 'u1', displayName: 'A'));
    expect(a.hashCode, const SessionUser(userId: 'u1', displayName: 'A').hashCode);
    expect(a, isNot(const SessionUser(userId: 'u2', displayName: 'A')));
    expect(a, isNot(const SessionUser(userId: 'u1', displayName: 'B')));
  });
}
