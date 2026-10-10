import 'package:drift/drift.dart' show Value;
import 'package:expense_tracker/core/db/app_database.dart';
import 'package:expense_tracker/core/router/onboarding_status.dart';
import 'package:expense_tracker/core/session/session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_database.dart';

void main() {
  const userId = 'u1';
  final now = DateTime.utc(2026, 10, 10);

  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    db = createTestDatabase();
    container = createTestContainer(db: db);
    container.listen(onboardingStatusProvider, (_, _) {});
  });

  Future<OnboardingStatus> status() => container.read(onboardingStatusProvider.future);

  test('unknown without a session', () async {
    expect(await status(), OnboardingStatus.unknown);
  });

  test('required when signed in without a profile or currency', () async {
    container.read(sessionProvider.notifier).set(const SessionUser(userId: userId));
    expect(await status(), OnboardingStatus.required);

    await db.profilesDao.insertProfile(
      ProfilesCompanion.insert(id: userId, userId: userId, createdAt: now, updatedAt: now),
    );
    await pumpEventQueue();
    expect(await status(), OnboardingStatus.required);
  });

  test('complete once the profile has a currency', () async {
    container.read(sessionProvider.notifier).set(const SessionUser(userId: userId));
    await status();

    await db.profilesDao.insertProfile(
      ProfilesCompanion.insert(
        id: userId,
        userId: userId,
        createdAt: now,
        updatedAt: now,
        currencyCode: const Value('LKR'),
      ),
    );
    await pumpEventQueue();

    expect(await status(), OnboardingStatus.complete);
  });
}
