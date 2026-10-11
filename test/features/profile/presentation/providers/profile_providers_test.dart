import 'package:expense_tracker/core/session/session.dart';
import 'package:expense_tracker/core/utils/currencies.dart';
import 'package:expense_tracker/features/profile/data/profile_repository_provider.dart';
import 'package:expense_tracker/features/profile/presentation/providers/profile_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/test_database.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = createTestContainer();
    container.read(sessionProvider.notifier).set(const SessionUser(userId: 'u1'));
    container.listen(currencyCodeProvider, (_, _) {});
  });

  test('is the stored currency', () async {
    await container.read(profileRepositoryProvider).setCurrency('LKR');
    await pumpEventQueue();

    expect(await container.read(currencyCodeProvider.future), 'LKR');
  });

  test('falls back without a profile', () async {
    expect(await container.read(currencyCodeProvider.future), Currencies.fallback);
  });
}
