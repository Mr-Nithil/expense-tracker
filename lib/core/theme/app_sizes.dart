/// Fixed component sizes (logical pixels).
abstract final class AppSizes {
  /// Minimum tap target (Material guideline).
  static const double minTapTarget = 48;
  static const double buttonHeight = 48;
  static const double iconSm = 16;
  static const double iconMd = 24;
  static const double iconLg = 48;
  static const double iconXl = 64;
  static const double progressSm = 20;
  static const double progressStroke = 2;
  static const double sheetHandleWidth = 32;
  static const double sheetHandleHeight = 4;

  /// Max content width for empty/error states so text stays readable on tablets.
  static const double maxMessageWidth = 360;

  /// Max width of single-column forms (auth, onboarding) on tablets and in landscape.
  static const double maxFormWidth = 480;
}
