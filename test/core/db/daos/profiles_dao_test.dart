import 'package:drift/drift.dart' show Value;
import 'package:expense_tracker/core/db/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_database.dart';

void main() {
  late AppDatabase db;
  final now = DateTime.utc(2026, 10, 10);

  setUp(() => db = createTestDatabase());

  ProfilesCompanion row(String userId, {String? currency, DateTime? deletedAt}) =>
      ProfilesCompanion.insert(
        id: userId,
        userId: userId,
        createdAt: now,
        updatedAt: now,
        currencyCode: Value(currency),
        deletedAt: Value(deletedAt),
      );

  test('get returns null when there is no profile', () async {
    expect(await db.profilesDao.getProfile('u1'), isNull);
  });

  test('insert then get returns the row for that user only', () async {
    await db.profilesDao.insertProfile(row('u1', currency: 'USD'));
    await db.profilesDao.insertProfile(row('u2', currency: 'EUR'));

    expect((await db.profilesDao.getProfile('u1'))?.currencyCode, 'USD');
  });

  test('soft-deleted profiles are hidden', () async {
    await db.profilesDao.insertProfile(row('u1', deletedAt: now));
    expect(await db.profilesDao.getProfile('u1'), isNull);
  });

  test('update changes the row and reports how many rows changed', () async {
    expect(
      await db.profilesDao.updateProfile('u1', const ProfilesCompanion(currencyCode: Value('EUR'))),
      0,
    );

    await db.profilesDao.insertProfile(row('u1'));
    final changed = await db.profilesDao.updateProfile(
      'u1',
      const ProfilesCompanion(currencyCode: Value('LKR')),
    );

    expect(changed, 1);
    expect((await db.profilesDao.getProfile('u1'))?.currencyCode, 'LKR');
  });

  test('watch emits on insert and update', () async {
    final currencies = db.profilesDao.watchProfile('u1').map((p) => p?.currencyCode);
    final expectation = expectLater(currencies, emitsInOrder([null, null, 'USD']));
    await pumpEventQueue();

    await db.profilesDao.insertProfile(row('u1'));
    await pumpEventQueue();
    await db.profilesDao.updateProfile('u1', const ProfilesCompanion(currencyCode: Value('USD')));

    await expectation;
  });
}
