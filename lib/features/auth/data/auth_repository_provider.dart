import 'package:expense_tracker/core/config/supabase_providers.dart';
import 'package:expense_tracker/features/auth/data/auth_repository_impl.dart';
import 'package:expense_tracker/features/auth/domain/auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_repository_provider.g.dart';

/// The auth repository, exposed as its interface. Lives in `data/` because it needs the
/// Supabase client, which presentation may not import.
@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) =>
    AuthRepositoryImpl(ref.watch(supabaseClientProvider).auth);
