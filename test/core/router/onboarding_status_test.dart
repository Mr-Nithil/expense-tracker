import 'package:drift/drift.dart' show Value;
import 'package:expense_tracker/core/db/app_database.dart';
import 'package:expense_tracker/core/router/onboarding_status.dart';
import 'package:expense_tracker/core/session/session.dart';
import 'package:expense_tracker/core/sync/initial_sync.dart';
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

  group('waits for the initial pull', () {
    late _ControlledInitialSync initial;

    ProviderContainer containerWith(InitialSyncStatus start) {
      final c = createTestContainer(
        db: db,
        overrides: [
          initialSyncProvider.overrideWith(() => initial = _ControlledInitialSync(start)),
        ],
      );
      c.read(sessionProvider.notifier).set(const SessionUser(userId: userId));
      c.listen(onboardingStatusProvider, (_, _) {});
      return c;
    }

    Future<OnboardingStatus> statusOf(ProviderContainer c) async {
      await pumpEventQueue();
      return c.read(onboardingStatusProvider.future);
    }

    Future<void> pulledProfile({String? currency}) => db.profilesDao.insertProfile(
      ProfilesCompanion.insert(
        id: userId,
        userId: userId,
        createdAt: now,
        updatedAt: now,
        currencyCode: Value(currency),
      ),
    );

    test('without a currency, a running first pull keeps the splash', () async {
      final c = containerWith(InitialSyncStatus.running);
      expect(await statusOf(c), OnboardingStatus.unknown);
    });

    test('a pulled profile with a currency skips onboarding', () async {
      final c = containerWith(InitialSyncStatus.running);
      await pulledProfile(currency: 'LKR');
      initial.set(InitialSyncStatus.done);

      expect(await statusOf(c), OnboardingStatus.complete);
    });

    test('a pull that finds no currency asks for it', () async {
      final c = containerWith(InitialSyncStatus.running);
      initial.set(InitialSyncStatus.done);

      expect(await statusOf(c), OnboardingStatus.required);
    });

    test('a failed pull falls back to onboarding instead of hanging', () async {
      final c = containerWith(InitialSyncStatus.running);
      initial.set(InitialSyncStatus.failed);

      expect(await statusOf(c), OnboardingStatus.required);
    });

    test('a device that has a currency is never blocked', () async {
      await pulledProfile(currency: 'USD');
      final c = containerWith(InitialSyncStatus.running);

      expect(await statusOf(c), OnboardingStatus.complete);
    });
  });
}

/// [InitialSync] whose status the test sets.
class _ControlledInitialSync extends InitialSync {
  _ControlledInitialSync(this._start);

  final InitialSyncStatus _start;

  @override
  InitialSyncStatus build() => _start;

  void set(InitialSyncStatus value) => state = value;
}
