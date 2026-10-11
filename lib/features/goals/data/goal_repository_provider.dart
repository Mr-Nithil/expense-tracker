import 'package:expense_tracker/core/db/database_provider.dart';
import 'package:expense_tracker/core/session/session.dart';
import 'package:expense_tracker/core/sync/sync_trigger.dart';
import 'package:expense_tracker/core/utils/clock.dart';
import 'package:expense_tracker/features/goals/data/goal_repository_impl.dart';
import 'package:expense_tracker/features/goals/domain/goal_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'goal_repository_provider.g.dart';

/// The goal repository, exposed as its interface.
@Riverpod(keepAlive: true)
GoalRepository goalRepository(Ref ref) => GoalRepositoryImpl(
  dao: ref.watch(databaseProvider).goalsDao,
  clock: ref.watch(clockProvider),
  session: ref.watch(sessionProvider.notifier),
  syncTrigger: ref.watch(syncTriggerProvider),
);
