import 'dart:io';

import 'package:drift/drift.dart' show DriftSqlType;
import 'package:expense_tracker/core/db/app_database.dart';
import 'package:expense_tracker/core/sync/sync_registry.dart';
import 'package:expense_tracker/core/sync/syncable_table.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_database.dart';

/// Columns and foreign keys of every `create table public.<name>` in the Supabase migrations,
/// plus columns added later with `alter table … add column`.
({Map<String, Map<String, String>> columns, Map<String, Set<String>> parents}) readRemoteSchema() {
  final sql = [
    for (final file in _migrationFiles())
      if (file.path.endsWith('.sql')) file.readAsStringSync(),
  ].join('\n');

  final columns = <String, Map<String, String>>{};
  final parents = <String, Set<String>>{};
  final tables = RegExp(r'create table public\.(\w+) \((.*?)\n\);', dotAll: true);
  final column = RegExp(
    r'^\s+([a-z_]+)\s+(uuid|text|bigint|integer|smallint|boolean|date|timestamptz)\b',
    multiLine: true,
  );
  final reference = RegExp(r'references public\.(\w+)');
  for (final table in tables.allMatches(sql)) {
    final name = table.group(1)!;
    final body = table.group(2)!;
    columns[name] = {for (final c in column.allMatches(body)) c.group(1)!: c.group(2)!};
    parents[name] = {for (final r in reference.allMatches(body)) r.group(1)!}..remove(name);
  }
  // Later migrations: `alter table public.<t> add column <c> <type>` (e.g. 0003).
  final added = RegExp(
    r'alter table public\.(\w+)\s+add column ([a-z_]+)\s+'
    r'(uuid|text|bigint|integer|smallint|boolean|date|timestamptz)\b',
  );
  for (final match in added.allMatches(sql)) {
    columns[match.group(1)!]![match.group(2)!] = match.group(3)!;
  }
  return (columns: columns, parents: parents);
}

List<File> _migrationFiles() =>
    Directory('supabase/migrations').listSync().whereType<File>().toList()
      ..sort((a, b) => a.path.compareTo(b.path));

void main() {
  late AppDatabase db;
  late List<SyncableTable> registry;

  setUp(() {
    db = createTestDatabase();
    registry = syncableTables(db);
  });

  test('registers every table with sync columns exactly once, and nothing else', () {
    final synced = {
      for (final table in db.allTables)
        if (table.$columns.any((c) => c.name == SyncableTable.syncStatusColumn))
          table.actualTableName,
    };
    final names = registry.map((t) => t.name).toList();

    expect(names.toSet(), synced);
    expect(names, hasLength(synced.length));
  });

  test('parents come before their children (remote foreign keys)', () {
    final parents = readRemoteSchema().parents;
    final order = registry.map((t) => t.name).toList();

    for (final (index, name) in order.indexed) {
      for (final parent in parents[name] ?? const <String>{}) {
        expect(order.indexOf(parent), lessThan(index), reason: '$parent before $name');
      }
    }
  });

  test('local and remote columns match, with compatible types', () {
    final remote = readRemoteSchema().columns;
    const compatible = {
      DriftSqlType.string: {'uuid', 'text', 'date'},
      DriftSqlType.int: {'bigint', 'integer', 'smallint'},
      DriftSqlType.bool: {'boolean'},
      DriftSqlType.dateTime: {'timestamptz'},
    };

    for (final table in registry) {
      final remoteColumns = remote[table.name];
      expect(remoteColumns, isNotNull, reason: 'no remote table ${table.name}');
      final local = {
        for (final c in table.table.$columns)
          if (c.name != SyncableTable.syncStatusColumn) c.name: c.type,
      };

      expect(local.keys.toSet(), remoteColumns!.keys.toSet(), reason: table.name);
      for (final MapEntry(key: name, value: type) in local.entries) {
        expect(
          compatible[type],
          contains(remoteColumns[name]),
          reason: '${table.name}.$name: $type vs ${remoteColumns[name]}',
        );
      }
    }
  });

  test('encrypted columns match the server list in 0004_encryption.sql (M11)', () {
    final sql = File('supabase/migrations/0004_encryption.sql').readAsStringSync();
    final server = {
      for (final match in RegExp(r"\('(\w+)',\s*array\[([^\]]*)\]").allMatches(sql))
        match.group(1)!: {
          for (final column in RegExp(r"'(\w+)'").allMatches(match.group(2)!)) column.group(1)!,
        },
    };

    for (final table in registry) {
      expect(table.encryptedColumns, server[table.name] ?? const <String>{}, reason: table.name);
      final local = {for (final c in table.table.$columns) c.name};
      expect(local, containsAll(table.encryptedColumns), reason: table.name);
    }
    expect(server.keys, everyElement(isIn(registry.map((t) => t.name))));
  });
}
