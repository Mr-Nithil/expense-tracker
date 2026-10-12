import 'package:drift/drift.dart' show Value;
import 'package:expense_tracker/core/db/app_database.dart';
import 'package:expense_tracker/core/utils/id.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_database.dart';

void main() {
  const userId = 'u1';
  final now = DateTime.utc(2026, 10, 10, 12);

  late AppDatabase db;

  setUp(() => db = createTestDatabase());

  Future<String> reminder(
    String time, {
    String title = 'Log expenses',
    String repeat = 'daily',
    int? weekdays,
    int? dayOfMonth,
    bool enabled = true,
    bool deleted = false,
    String user = userId,
  }) async {
    final id = IdGenerator.newId();
    await db.remindersDao.insertReminder(
      RemindersCompanion.insert(
        id: id,
        userId: user,
        createdAt: now,
        updatedAt: now,
        title: title,
        timeOfDay: time,
        repeatRule: repeat,
        weekdays: Value(weekdays),
        dayOfMonth: Value(dayOfMonth),
        enabled: Value(enabled),
        deletedAt: Value(deleted ? now : null),
      ),
    );
    return id;
  }

  test('watchAll lists live reminders by time, then title', () async {
    final late = await reminder('21:00');
    final earlyB = await reminder('08:00', title: 'B');
    final earlyA = await reminder('08:00', title: 'A');
    await reminder('09:00', deleted: true);
    await reminder('07:00', user: 'u2');

    final rows = await db.remindersDao.watchAll(userId).first;

    expect(rows.map((r) => r.id), [earlyA, earlyB, late]);
  });

  test('getEnabled reads only live, enabled reminders', () async {
    final on = await reminder('08:00');
    await reminder('09:00', enabled: false);
    await reminder('10:00', deleted: true);

    expect((await db.remindersDao.getEnabled(userId)).map((r) => r.id), [on]);
  });

  test('stores the monthly day and the weekly mask', () async {
    final monthly = await reminder('09:00', repeat: 'monthly', dayOfMonth: 31);
    final weekly = await reminder('18:00', repeat: 'weekly', weekdays: 0x05);

    expect((await db.remindersDao.getById(userId, monthly))?.dayOfMonth, 31);
    expect((await db.remindersDao.getById(userId, weekly))?.weekdays, 0x05);
  });

  test('the day of the month must be 1..31', () async {
    expect(() => reminder('09:00', repeat: 'monthly', dayOfMonth: 32), throwsA(anything));
    expect(() => reminder('09:00', repeat: 'monthly', dayOfMonth: 0), throwsA(anything));
  });

  test('watchById is null for deleted or other users\' rows; getById includes deleted', () async {
    final gone = await reminder('08:00', deleted: true);

    expect(await db.remindersDao.watchById(userId, gone).first, isNull);
    expect((await db.remindersDao.getById(userId, gone))?.deletedAt, isNotNull);
    expect(await db.remindersDao.getById('u2', gone), isNull);
  });

  test('updateReminder only touches the user\'s own row', () async {
    final id = await reminder('08:00');

    expect(
      await db.remindersDao.updateReminder('u2', id, const RemindersCompanion(title: Value('x'))),
      0,
    );
    expect(
      await db.remindersDao.updateReminder(
        userId,
        id,
        const RemindersCompanion(enabled: Value(false)),
      ),
      1,
    );
    expect((await db.remindersDao.getById(userId, id))?.enabled, isFalse);
  });
}
