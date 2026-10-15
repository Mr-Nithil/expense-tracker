import 'package:expense_tracker/core/crypto/row_cipher.dart';
import 'package:expense_tracker/core/sync/row_sealer.dart';
import 'package:expense_tracker/core/sync/sync_registry.dart';
import 'package:expense_tracker/core/sync/syncable_table.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_database.dart';

void main() {
  final key = List<int>.generate(32, (i) => i);
  late SyncableTable transactions;
  late SyncableTable profiles;
  late RowSealer sealer;

  setUp(() {
    final tables = syncableTables(createTestDatabase());
    transactions = tables.firstWhere((t) => t.name == 'transactions');
    profiles = tables.firstWhere((t) => t.name == 'profiles');
    sealer = RowSealer(RowCipher(key));
  });

  Map<String, Object?> row({int? amount = 1250, String? note = 'Lunch'}) => {
    'id': 't1',
    'user_id': 'u1',
    'type': 'expense',
    'amount_minor': amount,
    'category_id': 'c1',
    'occurred_on': '2026-10-13',
    'note': note,
  };

  test('seals the private columns and sends them empty; opens them back', () async {
    final sealed = await sealer.seal(transactions, row());

    expect(sealed['amount_minor'], isNull);
    expect(sealed['note'], isNull);
    expect(sealed[RowSealer.payloadColumn], startsWith('v1.'));
    expect(sealed['type'], 'expense');
    expect(sealed['occurred_on'], '2026-10-13');

    expect(await sealer.open(transactions, sealed), {
      ...row(),
      RowSealer.payloadColumn: sealed[RowSealer.payloadColumn],
    });
  });

  test('a null private value survives', () async {
    final opened = await sealer.open(
      transactions,
      await sealer.seal(transactions, row(note: null)),
    );
    expect(opened['note'], isNull);
    expect(opened['amount_minor'], 1250);
  });

  test('tables without private columns are untouched', () async {
    final profile = {'id': 'u1', 'user_id': 'u1', 'display_name': 'Nithil'};
    expect(await sealer.seal(profiles, profile), profile);
    expect(await sealer.open(profiles, profile), profile);
  });

  test('a plain row (before M11) is used as it is', () async {
    expect(await sealer.open(transactions, row()), row());
  });

  test('an edit by an old app version (plain values over an old payload) wins', () async {
    final sealed = await sealer.seal(transactions, row(amount: 1000));
    final editedByOldApp = {...sealed, 'amount_minor': 2000, 'note': 'Edited'};

    final opened = await sealer.open(transactions, editedByOldApp);

    expect(opened['amount_minor'], 2000);
    expect(opened['note'], 'Edited');
  });

  test('a payload that does not open throws', () async {
    final sealed = await sealer.seal(transactions, row());
    final otherKey = RowSealer(RowCipher(List<int>.filled(32, 9)));

    await expectLater(otherKey.open(transactions, sealed), throwsA(isA<RowCipherException>()));
    await expectLater(
      sealer.open(transactions, {...sealed, 'id': 't2'}),
      throwsA(isA<RowCipherException>()),
    );
  });
}
