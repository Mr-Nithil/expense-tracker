import 'package:expense_tracker/core/db/database_provider.dart';
import 'package:expense_tracker/core/services/secure_storage_service.dart';
import 'package:expense_tracker/features/auth/data/local_data_repository_impl.dart';
import 'package:expense_tracker/features/auth/domain/local_data_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'local_data_repository_provider.g.dart';

/// The local data repository, exposed as its interface.
@Riverpod(keepAlive: true)
LocalDataRepository localDataRepository(Ref ref) => LocalDataRepositoryImpl(
  db: ref.watch(databaseProvider),
  secureStorage: ref.watch(secureStorageServiceProvider),
);
