import 'package:drift/drift.dart';
import 'package:expense_tracker/core/db/tables/sync_columns.dart';

/// What [SyncableTable.merge] did with a pulled row.
enum MergeOutcome {
  /// Not on this device yet: inserted.
  inserted,

  /// Replaced the local copy (synced, or pending but not newer).
  updated,

  /// The local copy is pending and newer: kept, to be pushed (last-write-wins).
  keptLocal,

  /// Belongs to another user: ignored.
  skipped,
}

/// One synced table: converts its rows to the JSON Supabase expects and back.
///
/// Generic over every table with `SyncColumns`: it uses Drift's own column metadata
/// (`toColumns` for SQL-level values, `TableInfo.map` to read them back), so local and remote
/// stay in step without hand-written mappers. Local and remote tables share their name and
/// snake_case columns (ARCHITECTURE §6.2).
class SyncableTable<T extends Table, R extends DataClass> {
  const SyncableTable(this.db, this.table, {this.encryptedColumns = const {}});

  final GeneratedDatabase db;
  final TableInfo<T, R> table;

  /// Private columns sealed into `payload_enc` before upload (M11, ARCHITECTURE §13).
  final Set<String> encryptedColumns;

  /// Local only: never sent.
  static const syncStatusColumn = 'sync_status';

  /// Set by the server trigger: never sent, always read.
  static const serverUpdatedAtColumn = 'server_updated_at';

  /// Local and remote table name.
  String get name => table.actualTableName;

  /// The row as a JSON object for an upsert: every column except [syncStatusColumn] and
  /// [serverUpdatedAtColumn]. Timestamps are UTC ISO-8601; date-only columns are `yyyy-MM-dd`.
  Map<String, Object?> toRemote(R row) {
    final columns = (row as Insertable<R>).toColumns(false);
    return {
      for (final MapEntry(key: column, value: expression) in columns.entries)
        if (column != syncStatusColumn && column != serverUpdatedAtColumn)
          column: _encode((expression as Variable).value),
    };
  }

  /// A row from Supabase JSON, marked [SyncStatus.synced]. Unknown keys (e.g. a column added by
  /// a newer server schema) are ignored.
  ///
  /// Timestamps are normalized to UTC: Drift would otherwise read `…+00:00` as a local time and
  /// store it with the device's offset, so pulled rows wouldn't sort with local (`…Z`) ones.
  Future<R> fromRemote(Map<String, Object?> json) async {
    final columns = {for (final column in table.$columns) column.name};
    final dateTimes = {
      for (final column in table.$columns)
        if (column.type == DriftSqlType.dateTime) column.name,
    };
    final data = <String, Object?>{
      // Rows from a server without `0006` (or older fixtures) carry no change source: the user's,
      // like the server's own defaults.
      for (final MapEntry(:key, :value) in _changeSourceDefaults.entries)
        if (columns.contains(key)) key: value,
      for (final MapEntry(:key, :value) in json.entries)
        if (columns.contains(key)) key: _decode(value, isDateTime: dateTimes.contains(key)),
      syncStatusColumn: SyncStatus.synced.index,
    };
    return table.map(data);
  }

  static const _changeSourceDefaults = {
    'created_by': ChangeSource.user,
    'updated_by': ChangeSource.user,
  };

  /// Rows of [userId] waiting to be pushed, soft-deleted ones included (a deletion must reach
  /// the server too). Oldest change first, so batches are stable.
  Future<List<R>> pendingRows(String userId) {
    final query = db.select(table)
      ..where(
        (_) =>
            _column<String>('user_id').equals(userId) &
            _column<int>(syncStatusColumn).equals(SyncStatus.pending.index),
      )
      ..orderBy([(_) => OrderingTerm.asc(_column<DateTime>('updated_at'))]);
    return query.get();
  }

  /// Marks the rows [ids] pending again without touching `updated_at`, so the next push sends
  /// them unchanged (M11.7: re-upload a plain row sealed). Returns how many were marked.
  Future<int> markPending(Iterable<String> ids) async {
    var marked = 0;
    for (final id in ids) {
      marked += await db.customUpdate(
        'UPDATE "$name" SET $syncStatusColumn = ? WHERE id = ?',
        variables: [Variable<int>(SyncStatus.pending.index), Variable<String>(id)],
        updates: {table},
        updateKind: UpdateKind.update,
      );
    }
    return marked;
  }

  /// Marks every synced row of [userId] pending again, `updated_at` unchanged (M11.7).
  Future<int> markAllSyncedPending(String userId) => db.customUpdate(
    'UPDATE "$name" SET $syncStatusColumn = ? WHERE user_id = ? AND $syncStatusColumn = ?',
    variables: [
      Variable<int>(SyncStatus.pending.index),
      Variable<String>(userId),
      Variable<int>(SyncStatus.synced.index),
    ],
    updates: {table},
    updateKind: UpdateKind.update,
  );

  /// Marks pushed [rows] as synced, but only where `updated_at` still equals the pushed value:
  /// a row edited while the push was in flight stays pending for the next run. Returns how many
  /// rows were marked.
  Future<int> markSynced(List<R> rows) => db.transaction(() async {
    var marked = 0;
    for (final row in rows) {
      final columns = (row as Insertable<R>).toColumns(false);
      marked += await db.customUpdate(
        'UPDATE "$name" SET $syncStatusColumn = ? WHERE id = ? AND updated_at = ?',
        variables: [
          Variable<int>(SyncStatus.synced.index),
          columns['id']! as Variable<String>,
          // Same encoding Drift used to store it, so equal instants compare equal.
          columns['updated_at']! as Variable<DateTime>,
        ],
        updates: {table},
        updateKind: UpdateKind.update,
      );
    }
    return marked;
  });

  /// Merges a pulled row ([fromRemote]) into the local table, last-write-wins (ARCHITECTURE §7):
  /// no local copy → insert; a pending local copy with a strictly newer `updated_at` → keep it;
  /// otherwise → overwrite (an equal `updated_at` is our own push coming back).
  ///
  /// Overwrites update in place (an `UPDATE` of every column, nulls included), never delete and
  /// re-insert, so local foreign keys (e.g. transactions → their category) hold.
  Future<MergeOutcome> merge(R remote, {required String userId}) async {
    final row = remote as Insertable<R>;
    final incoming = row.toColumns(false);
    Object? valueOf(Map<String, Expression> columns, String name) =>
        (columns[name]! as Variable).value;

    if (valueOf(incoming, 'user_id') != userId) return MergeOutcome.skipped;

    final id = valueOf(incoming, 'id')! as String;
    final local = await (db.select(
      table,
    )..where((_) => _column<String>('id').equals(id))).getSingleOrNull();
    if (local == null) {
      await db.into(table).insert(row);
      return MergeOutcome.inserted;
    }

    final current = (local as Insertable<R>).toColumns(false);
    final isPending = valueOf(current, syncStatusColumn) == SyncStatus.pending.index;
    final localUpdated = valueOf(current, 'updated_at')! as DateTime;
    final remoteUpdated = valueOf(incoming, 'updated_at')! as DateTime;
    if (isPending && localUpdated.isAfter(remoteUpdated)) return MergeOutcome.keptLocal;

    // Every column, nulls included: Drift's insertOnConflictUpdate skips nulls on the update side,
    // so a value cleared on another device (a note, a deletion undone) would never arrive.
    final changes = Map.of(incoming)..remove('id');
    await db.customUpdate(
      'UPDATE "$name" SET ${changes.keys.map((column) => '"$column" = ?').join(', ')} '
      'WHERE id = ?',
      variables: [for (final value in changes.values) value as Variable, Variable<String>(id)],
      updates: {table},
      updateKind: UpdateKind.update,
    );
    return MergeOutcome.updated;
  }

  /// A sync column by name; every synced table has them (`SyncColumns`).
  GeneratedColumn<C> _column<C extends Object>(String name) =>
      table.columnsByName[name]! as GeneratedColumn<C>;

  static Object? _encode(Object? value) =>
      value is DateTime ? value.toUtc().toIso8601String() : value;

  static Object? _decode(Object? value, {required bool isDateTime}) => switch (value) {
    final bool flag => flag ? 1 : 0,
    final String text when isDateTime => DateTime.parse(text).toUtc().toIso8601String(),
    _ => value,
  };
}
