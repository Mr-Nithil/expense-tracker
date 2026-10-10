/// Custom-scheme deep links. Must match the Android intent filter (`AndroidManifest.xml`), the
/// iOS `CFBundleURLTypes` (`Info.plist`) and the Supabase "Redirect URLs" allow list.
abstract final class DeepLinks {
  static const scheme = 'expensetracker';
  static const authCallbackHost = 'auth-callback';

  /// Where Supabase auth emails (confirmation, password reset) send the user back to.
  /// `supabase_flutter` detects it and exchanges the code for a session.
  static const authCallback = '$scheme://$authCallbackHost';
}
