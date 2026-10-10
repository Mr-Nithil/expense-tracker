import 'package:expense_tracker/core/db/database_provider.dart';
import 'package:expense_tracker/core/session/session.dart';
import 'package:expense_tracker/core/utils/clock.dart';
import 'package:expense_tracker/features/profile/data/profile_repository_impl.dart';
import 'package:expense_tracker/features/profile/domain/profile_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_repository_provider.g.dart';

/// The profile repository, exposed as its interface.
@Riverpod(keepAlive: true)
ProfileRepository profileRepository(Ref ref) => ProfileRepositoryImpl(
  dao: ref.watch(databaseProvider).profilesDao,
  clock: ref.watch(clockProvider),
  session: ref.watch(sessionProvider.notifier),
);
