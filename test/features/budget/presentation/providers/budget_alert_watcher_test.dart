import 'package:drift/drift.dart' show Value;
import 'package:expense_tracker/core/db/app_database.dart';
import 'package:expense_tracker/core/l10n/generated/app_localizations_en.dart';
import 'package:expense_tracker/core/services/notification_service.dart';
import 'package:expense_tracker/core/session/session.dart';
import 'package:expense_tracker/core/utils/clock.dart';
import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/features/budget/data/budget_repository_provider.dart';
import 'package:expense_tracker/features/budget/domain/services/budget_alert_check.dart';
import 'package:expense_tracker/features/budget/presentation/providers/budget_alert_watcher.dart';
import 'package:expense_tracker/features/budget/presentation/providers/budget_alerts_controller.dart';
import 'package:expense_tracker/features/budget/presentation/providers/budget_providers.dart';
import 'package:expense_tracker/features/profile/presentation/providers/profile_providers.dart';
import 'package:expense_tracker/features/transactions/data/transaction_repository_provider.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fake_notification_service.dart';
import '../../../../helpers/test_database.dart';

void main() {
  final l10n = AppLocalizationsEn();
  final now = DateTime(2026, 10, 11, 9);
  final october = DateTime(2026, 10);

  late AppDatabase db;
  late ProviderContainer container;
  late FakeNotificationService notifications;

  setUp(() async {
    db = createTestDatabase();
    notifications = FakeNotificationService();
    container = createTestContainer(
      db: db,
      overrides: [
        clockProvider.overrideWithValue(FixedClock(now)),
        notifications.providerOverride,
        currencyCodeProvider.overrideWith((ref) async => 'USD'),
      ],
    );
    container.read(sessionProvider.notifier).set(const SessionUser(userId: 'u1'));
    await db.categoriesDao.insertCategory(
      CategoriesCompanion.insert(
        id: 'food',
        userId: 'u1',
        createdAt: now.toUtc(),
        updatedAt: now.toUtc(),
        name: 'Food',
        icon: 'food',
        color: 0,
        type: 'expense',
        sortOrder: const Value(0),
      ),
    );
    await db.categoriesDao.insertCategory(
      CategoriesCompanion.insert(
        id: 'salary',
        userId: 'u1',
        createdAt: now.toUtc(),
        updatedAt: now.toUtc(),
        name: 'Salary',
        icon: 'salary',
        color: 0,
        type: 'income',
        sortOrder: const Value(1),
      ),
    );
    final budgets = container.read(budgetRepositoryProvider);
    await budgets.set(month: october, limit: const Money(100000));
    await budgets.set(month: october, categoryId: 'food', limit: const Money(10000));
  });

  Future<void> start({bool enabled = true}) async {
    await container.read(budgetAlertPreferencesProvider).setEnabled(enabled: enabled);
    container.listen(budgetAlertWatcherProvider, (_, _) {});
    await pumpEventQueue();
  }

  Future<void> spend(int amount, {TransactionType type = TransactionType.expense}) async {
    final result = await container
        .read(transactionRepositoryProvider)
        .create(
          TransactionDraft(
            type: type,
            amount: Money(amount),
            categoryId: type == TransactionType.income ? 'salary' : 'food',
            occurredOn: DateTime(2026, 10, 5),
          ),
        );
    expect(result.isSuccess, isTrue);
    await pumpEventQueue();
  }

  String foodBudgetId() =>
      container.read(budgetOverviewProvider(october)).requireValue.categories.single.budget.id;

  test('crossing 80% of a category budget alerts with its name and amounts', () async {
    await start();

    await spend(8200);

    final alert = notifications.shown.single;
    expect(alert.title, l10n.budgetAlertWarningTitle('Food', 82));
    expect(alert.body, l10n.budgetAlertBody(r'$82.00', r'$100.00'));
    expect(alert.channel, NotificationChannel.budgetAlerts);
    expect(alert.id, BudgetAlertIds.of(foodBudgetId()));
  });

  test('reaching 100% alerts again on the same id (replacing the 80% one)', () async {
    await start();
    await spend(8200);

    await spend(2000);

    expect(notifications.shown.map((a) => a.title), [
      l10n.budgetAlertWarningTitle('Food', 82),
      l10n.budgetAlertExceededTitle('Food'),
    ]);
    expect(notifications.shown.map((a) => a.id).toSet(), hasLength(1));
  });

  test('the overall budget is named "Overall budget"', () async {
    await start();

    await spend(85000);

    expect(
      notifications.shown.map((a) => a.title),
      contains(l10n.budgetAlertWarningTitle(l10n.budgetOverallTitle, 85)),
    );
  });

  test('budgets already over when the app opens do not alert (baseline)', () async {
    await spend(9000);

    await start();
    await spend(100);

    expect(notifications.shown, isEmpty);
  });

  test('nothing while alerts are off', () async {
    await start(enabled: false);

    await spend(9500);

    expect(notifications.shown, isEmpty);
  });

  test('income never alerts', () async {
    await start();

    await spend(50000, type: TransactionType.income);

    expect(notifications.shown, isEmpty);
  });

  test('the switch saves the choice and asks for permission only when turning on', () async {
    final controller = container.read(budgetAlertsControllerProvider.notifier);
    notifications.permissionGranted = false;

    final on = await controller.setEnabled(enabled: true);
    expect(on.saved.isSuccess, isTrue);
    expect(on.permitted, isFalse);
    expect(notifications.permissionRequests, 1);

    final off = await controller.setEnabled(enabled: false);
    expect(off.permitted, isTrue);
    expect(notifications.permissionRequests, 1);
    expect(await container.read(budgetAlertPreferencesProvider).watchEnabled().first, isFalse);
  });
}
