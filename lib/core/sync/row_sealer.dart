import 'package:expense_tracker/core/crypto/row_cipher.dart';
import 'package:expense_tracker/core/sync/syncable_table.dart';
import 'package:meta/meta.dart';

/// Seals a table's private columns into `payload_enc` before upload and opens them after
/// download (M11.6, ARCHITECTURE §13). One per sync run, with the user's data key.
class RowSealer {
  RowSealer(RowCipher this._cipher);

  /// Passes rows through unchanged. Only for tests of push/pull mechanics.
  @visibleForTesting
  static final none = RowSealer._none();

  RowSealer._none() : _cipher = null;

  /// Server-only column holding the sealed fields.
  static const payloadColumn = 'payload_enc';

  final RowCipher? _cipher;

  /// [json] (from `SyncableTable.toRemote`) with its private columns moved into
  /// [payloadColumn] and sent as `null`.
  Future<Map<String, Object?>> seal(SyncableTable table, Map<String, Object?> json) async {
    final cipher = _cipher;
    if (cipher == null || table.encryptedColumns.isEmpty) return json;
    final payload = await cipher.seal(
      {for (final column in table.encryptedColumns) column: json[column]},
      table: table.name,
      id: json['id']! as String,
      userId: json['user_id']! as String,
    );
    return {
      ...json,
      for (final column in table.encryptedColumns) column: null,
      payloadColumn: payload,
    };
  }

  /// Whether [json] from the server holds [table]'s private columns in plain text (before M11, or
  /// edited by an old app version). Such rows are pushed again sealed (M11.7).
  bool isPlain(SyncableTable table, Map<String, Object?> json) =>
      _cipher != null &&
      table.encryptedColumns.isNotEmpty &&
      (json[payloadColumn] is! String ||
          table.encryptedColumns.any((column) => json[column] != null));

  /// [json] from the server with its private columns restored. A row without a payload, or with
  /// its plain private columns filled (from before M11, or edited by an old app version), is
  /// used as it is. Throws `RowCipherException` when the payload can't be opened.
  Future<Map<String, Object?>> open(SyncableTable table, Map<String, Object?> json) async {
    final cipher = _cipher;
    final payload = json[payloadColumn];
    if (cipher == null ||
        table.encryptedColumns.isEmpty ||
        payload is! String ||
        table.encryptedColumns.any((column) => json[column] != null)) {
      return json;
    }
    final fields = await cipher.open(
      payload,
      table: table.name,
      id: json['id']! as String,
      userId: json['user_id']! as String,
    );
    return {
      ...json,
      for (final column in table.encryptedColumns) column: fields[column],
    };
  }
}
