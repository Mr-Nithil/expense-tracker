import 'package:drift/drift.dart';

/// Local sync state of a row. Stored as its index: **only append new values, never reorder.**
enum SyncStatus { pending, synced }

/// Columns shared by every synced table (ARCHITECTURE §6.1).
///
/// Each table still declares `primaryKey => {id}` itself.
mixin SyncColumns on Table {
  /// UUID generated on the device (`IdGenerator.newId()`).
  TextColumn get id => text()();

  /// Owner (Supabase `auth.uid()`).
  TextColumn get userId => text()();

  /// UTC. Set once on insert.
  DateTimeColumn get createdAt => dateTime()();

  /// UTC. Set on every local change. Used for last-write-wins conflict resolution.
  DateTimeColumn get updatedAt => dateTime()();

  /// Soft-delete marker. Reads must filter `deletedAt IS NULL`.
  DateTimeColumn get deletedAt => dateTime().nullable()();

  /// Server timestamp. Written only by sync pull.
  DateTimeColumn get serverUpdatedAt => dateTime().nullable()();

  /// `pending` after a local write, `synced` after a successful push. Local only.
  IntColumn get syncStatus =>
      intEnum<SyncStatus>().withDefault(Constant(SyncStatus.pending.index))();
}
