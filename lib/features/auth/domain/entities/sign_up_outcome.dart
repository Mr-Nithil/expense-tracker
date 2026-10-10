/// Result of a successful sign-up.
enum SignUpOutcome {
  /// A session was created; the user is signed in.
  signedIn,

  /// Email confirmation is enabled: the user must click the link before signing in (M1.7).
  emailConfirmationRequired,
}
