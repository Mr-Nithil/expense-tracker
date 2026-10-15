/// Fixed component sizes (logical pixels).
abstract final class AppSizes {
  /// Minimum tap target (Material guideline).
  static const double minTapTarget = 48;
  static const double buttonHeight = 48;

  /// Chunky primary and danger buttons (Sprout design).
  static const double chunkyButtonHeight = 54;

  /// Chunky outline buttons.
  static const double outlineButtonHeight = 52;

  /// The solid bottom shadow of chunky buttons, cards and outline controls.
  static const double chunkyDepth = 4;

  /// The deeper shadow under the FAB and the balance card.
  static const double chunkyDepthHero = 5;

  /// Border of chunky cards and outline controls.
  static const double chunkyBorder = 2;
  static const double iconSm = 16;
  static const double iconMd = 24;
  static const double iconLg = 48;
  static const double iconXl = 64;

  /// Circular avatar in list rows (e.g. `CategoryIcon`).
  static const double avatarMd = 40;
  static const double progressSm = 20;
  static const double progressStroke = 2;

  /// Thickness of `ProgressBar` (budget and goal progress).
  static const double progressBarHeight = 8;

  /// Bottom padding that keeps a list's last item clear of a floating action button.
  static const double fabClearance = 80;

  /// Calendar day row (day number + net amount), before text scaling.
  static const double calendarRowHeight = 60;

  /// Calendar weekday labels row, before text scaling.
  static const double calendarDaysOfWeekHeight = 20;

  /// One day of the dashboard's compact spending heatmap (7 per row).
  static const double heatmapCell = 32;

  /// Diameter and thickness of `ProgressRing` (goal progress).
  static const double progressRing = 48;

  /// The big ring at the top of a goal's page.
  static const double progressRingLarge = 120;
  static const double progressRingStroke = 4;

  /// Ring around the selected option in pickers (icons, colors).
  static const double selectionBorder = 2;

  /// One key of the PIN pad (app lock).
  static const double pinKey = 72;

  /// One dot of the PIN progress (app lock).
  static const double pinDot = 14;

  static const double sheetHandleWidth = 40;
  static const double sheetHandleHeight = 5;

  /// Max content width for empty/error states so text stays readable on tablets.
  static const double maxMessageWidth = 360;

  /// Max width of single-column forms (auth, onboarding) on tablets and in landscape.
  static const double maxFormWidth = 480;
}
