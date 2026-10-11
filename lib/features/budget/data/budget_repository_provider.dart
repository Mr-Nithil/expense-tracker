import 'package:expense_tracker/core/db/database_provider.dart';
import 'package:expense_tracker/core/session/session.dart';
import 'package:expense_tracker/core/sync/sync_trigger.dart';
import 'package:expense_tracker/core/utils/clock.dart';
import 'package:expense_tracker/features/budget/data/budget_repository_impl.dart';
import 'package:expense_tracker/features/budget/domain/budget_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'budget_repository_provider.g.dart';

/// The budget repository, exposed as its interface.
@Riverpod(keepAlive: true)
BudgetRepository budgetRepository(Ref ref) {
  final db = ref.watch(databaseProvider);
  return BudgetRepositoryImpl(
    dao: db.budgetsDao,
    categoriesDao: db.categoriesDao,
    clock: ref.watch(clockProvider),
    session: ref.watch(sessionProvider.notifier),
    syncTrigger: ref.watch(syncTriggerProvider),
  );
}
