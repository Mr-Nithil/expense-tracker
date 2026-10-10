import 'package:drift/drift.dart';

/// Local only. Device settings as key/value pairs (e.g. theme mode before it syncs).
@DataClassName('AppSettingRow')
class AppSettings extends Table {
  TextColumn get key => text()();

  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
