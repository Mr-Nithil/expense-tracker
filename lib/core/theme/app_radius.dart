/// Corner radius scale. Use with `BorderRadius.circular(AppRadius.md)`.
abstract final class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 28;

  // Sprout design (README §Shape and elevation).
  /// Small icon tiles.
  static const double tile = 14;

  /// Buttons and input fields.
  static const double field = 18;

  /// Cards.
  static const double card = 20;

  /// Hero cards: balance, streak.
  static const double hero = 24;

  /// Bottom sheets (top corners).
  static const double sheet = 28;

  /// Chips and pills (fully round ends).
  static const double pill = 99;
}
