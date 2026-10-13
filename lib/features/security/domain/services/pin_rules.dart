/// What makes a valid app-lock PIN: exactly 4 digits (decided by the user 2026-10-13; was 4–6).
abstract final class PinRules {
  static const length = 4;

  static final _digits = RegExp(r'^\d+$');

  static bool isValid(String pin) => pin.length == length && _digits.hasMatch(pin);
}
