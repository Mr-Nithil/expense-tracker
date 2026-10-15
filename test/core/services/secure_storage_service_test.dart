import 'package:expense_tracker/core/services/secure_storage_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockStorage extends Mock implements FlutterSecureStorage {}

void main() {
  test('deleteAll wipes user secrets but keeps the database key', () async {
    final plugin = _MockStorage();
    final values = <String, String>{
      SecureStorageService.databaseKeyName: 'db',
      'data_key': 'user',
      'app_lock': 'pin',
    };
    when(() => plugin.read(key: any(named: 'key'))).thenAnswer(
      (call) async => values[call.namedArguments[#key]],
    );
    when(plugin.deleteAll).thenAnswer((_) async => values.clear());
    when(
      () => plugin.write(
        key: any(named: 'key'),
        value: any(named: 'value'),
      ),
    ).thenAnswer(
      (call) async =>
          values[call.namedArguments[#key] as String] = call.namedArguments[#value] as String,
    );

    await SecureStorageService(plugin).deleteAll();

    expect(values, {SecureStorageService.databaseKeyName: 'db'});
  });
}
