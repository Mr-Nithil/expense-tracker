import 'package:expense_tracker/core/services/secure_storage_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late _MockStorage storage;
  late SecureStorageService service;

  setUp(() {
    storage = _MockStorage();
    service = SecureStorageService(storage);
  });

  test('read, write and delete pass through to secure storage', () async {
    when(() => storage.read(key: 'pin')).thenAnswer((_) async => 'hash');
    when(() => storage.write(key: 'pin', value: 'hash')).thenAnswer((_) async {});
    when(() => storage.delete(key: 'pin')).thenAnswer((_) async {});

    expect(await service.read('pin'), 'hash');
    await service.write('pin', 'hash');
    await service.delete('pin');

    verify(() => storage.write(key: 'pin', value: 'hash')).called(1);
    verify(() => storage.delete(key: 'pin')).called(1);
  });

  test('deleteAll clears everything', () async {
    when(() => storage.deleteAll()).thenAnswer((_) async {});
    await service.deleteAll();
    verify(() => storage.deleteAll()).called(1);
  });
}
