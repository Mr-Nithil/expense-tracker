import 'package:expense_tracker/features/profile/domain/entities/profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('isOnboarded once a currency is set', () {
    expect(const Profile(id: 'u1').isOnboarded, isFalse);
    expect(const Profile(id: 'u1', currencyCode: 'LKR').isOnboarded, isTrue);
  });
}
