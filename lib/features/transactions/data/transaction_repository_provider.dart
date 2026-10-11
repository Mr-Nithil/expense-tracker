import 'package:expense_tracker/core/db/database_provider.dart';
import 'package:expense_tracker/core/session/session.dart';
import 'package:expense_tracker/core/sync/sync_trigger.dart';
import 'package:expense_tracker/core/utils/clock.dart';
import 'package:expense_tracker/features/transactions/data/transaction_repository_impl.dart';
import 'package:expense_tracker/features/transactions/domain/transaction_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'transaction_repository_provider.g.dart';

/// The transaction repository, exposed as its interface.
@Riverpod(keepAlive: true)
TransactionRepository transactionRepository(Ref ref) {
  final db = ref.watch(databaseProvider);
  return TransactionRepositoryImpl(
    dao: db.transactionsDao,
    categoriesDao: db.categoriesDao,
    clock: ref.watch(clockProvider),
    session: ref.watch(sessionProvider.notifier),
    syncTrigger: ref.watch(syncTriggerProvider),
  );
}
