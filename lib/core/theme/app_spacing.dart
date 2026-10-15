/// Spacing scale (logical pixels). Use with `Gap(AppSpacing.md)` or `EdgeInsets`.
abstract final class AppSpacing {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  // Sprout design steps between the base ones (README §Spacing).
  static const double s6 = 6;
  static const double s10 = 10;
  static const double s12 = 12;
  static const double s14 = 14;
  static const double s20 = 20;

  /// Side padding of app screens.
  static const double screen = 20;

  /// Side padding of auth screens.
  static const double screenAuth = 24;
}
