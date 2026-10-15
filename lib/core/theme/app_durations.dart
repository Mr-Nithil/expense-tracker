/// Animation and UI timing tokens.
abstract final class AppDurations {
  static const short = Duration(milliseconds: 150);
  static const medium = Duration(milliseconds: 300);
  static const snackBar = Duration(seconds: 4);

  // Sprout design (README §Interactions and motion).
  /// Chunky press: translate down by the shadow height.
  static const press = Duration(milliseconds: 80);

  /// Elastic pops: bubbles, switch knob, plant stage.
  static const pop = Duration(milliseconds: 450);

  /// Pip covering his eyes.
  static const eyeCover = Duration(milliseconds: 380);

  /// Progress bar width tween.
  static const barGrow = Duration(milliseconds: 500);

  /// One SproutLoader cycle.
  static const loaderLoop = Duration(milliseconds: 1800);

  /// Toasts (replaces [snackBar] in M12.2).
  static const toast = Duration(seconds: 3);
}
