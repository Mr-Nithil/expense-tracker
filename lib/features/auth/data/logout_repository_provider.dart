import 'package:expense_tracker/core/db/database_provider.dart';
import 'package:expense_tracker/features/auth/data/auth_repository_provider.dart';
import 'package:expense_tracker/features/auth/data/local_data_repository_provider.dart';
import 'package:expense_tracker/features/auth/data/logout_repository_impl.dart';
import 'package:expense_tracker/features/auth/domain/logout_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'logout_repository_provider.g.dart';

/// The logout repository, exposed as its interface. Other features use it through
/// `LogoutController` (ARCHITECTURE §3, cross-feature UI).
@Riverpod(keepAlive: true)
LogoutRepository logoutRepository(Ref ref) => LogoutRepositoryImpl(
  auth: ref.watch(authRepositoryProvider),
  db: ref.watch(databaseProvider),
  localData: ref.watch(localDataRepositoryProvider),
);
