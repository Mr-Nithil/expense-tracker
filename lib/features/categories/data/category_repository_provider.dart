import 'package:expense_tracker/core/db/database_provider.dart';
import 'package:expense_tracker/core/session/session.dart';
import 'package:expense_tracker/core/sync/sync_trigger.dart';
import 'package:expense_tracker/core/utils/clock.dart';
import 'package:expense_tracker/features/categories/data/category_repository_impl.dart';
import 'package:expense_tracker/features/categories/domain/category_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'category_repository_provider.g.dart';

/// The category repository, exposed as its interface.
@Riverpod(keepAlive: true)
CategoryRepository categoryRepository(Ref ref) => CategoryRepositoryImpl(
  dao: ref.watch(databaseProvider).categoriesDao,
  clock: ref.watch(clockProvider),
  session: ref.watch(sessionProvider.notifier),
  syncTrigger: ref.watch(syncTriggerProvider),
);
