// Drift CHECK constraints reference their own column getter; drift_dev parses, never runs, it.
// ignore_for_file: recursive_getters

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

  /// Who created the row: [ChangeSource.user] or [ChangeSource.agent] (M10.14). Never changes.
  TextColumn get createdBy => text()
      .check(createdBy.isIn(ChangeSource.values))
      .withDefault(const Constant(ChangeSource.user))();

  /// Who made the last change. Local edits reset it to [ChangeSource.user] (trigger in
  /// `change_source.drift`); the agent's changes arrive by sync as [ChangeSource.agent].
  TextColumn get updatedBy => text()
      .check(updatedBy.isIn(ChangeSource.values))
      .withDefault(const Constant(ChangeSource.user))();

  /// The approved agent proposal behind the last change; null when the user made it.
  TextColumn get agentProposalId => text().nullable()();
}

/// Values of `created_by` / `updated_by` (M10.14, ARCHITECTURE §14).
abstract final class ChangeSource {
  static const user = 'user';
  static const agent = 'agent';
  static const values = [user, agent];
}
