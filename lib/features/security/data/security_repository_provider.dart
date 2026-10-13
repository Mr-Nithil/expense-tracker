import 'package:expense_tracker/core/services/secure_storage_service.dart';
import 'package:expense_tracker/core/session/session.dart';
import 'package:expense_tracker/features/security/data/pin_hasher.dart';
import 'package:expense_tracker/features/security/data/security_repository_impl.dart';
import 'package:expense_tracker/features/security/domain/security_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'security_repository_provider.g.dart';

/// The app lock repository, exposed as its interface.
@Riverpod(keepAlive: true)
SecurityRepository securityRepository(Ref ref) => SecurityRepositoryImpl(
  storage: ref.watch(secureStorageServiceProvider),
  session: ref.watch(sessionProvider.notifier),
  hasher: const PinHasher(),
);
