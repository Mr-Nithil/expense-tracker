/// Compile-time configuration from `--dart-define-from-file=env.json`.
///
/// See `env.example.json` for the expected keys. Never hard-code these values.
abstract final class Env {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');

  /// The project's publishable key (`sb_publishable_...`) or legacy anon key. Safe to ship
  /// only because RLS is enforced on every table.
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool get isConfigured => supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  /// Throws a [StateError] with setup instructions when the app was started without env values.
  static void ensureConfigured() {
    if (!isConfigured) {
      throw StateError(
        'Missing SUPABASE_URL / SUPABASE_ANON_KEY. Copy env.example.json to env.json, fill it in, '
        'and run with --dart-define-from-file=env.json',
      );
    }
  }
}
