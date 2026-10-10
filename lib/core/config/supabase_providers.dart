import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'supabase_providers.g.dart';

/// The Supabase client. Only `core/sync`, `features/auth/data` and `features/agent/data` may
/// depend on this (ARCHITECTURE §2).
@Riverpod(keepAlive: true)
SupabaseClient supabaseClient(Ref ref) => Supabase.instance.client;
