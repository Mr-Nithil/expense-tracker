/// How grown a goal's plant is, from the percent saved (README §Core components 8).
enum GoalStage {
  /// 0–4 %.
  seed,

  /// 5–24 %.
  sprout,

  /// 25–59 %.
  seedling,

  /// 60–99 %.
  youngPlant,

  /// 100 % or more: in bloom.
  bloom
  ;

  /// The stage for a whole [percent] saved (`GoalProgress.percent`, rounded down).
  static GoalStage of(int percent) => switch (percent) {
    >= 100 => bloom,
    >= 60 => youngPlant,
    >= 25 => seedling,
    >= 5 => sprout,
    _ => seed,
  };

  /// 1 to 5, for "Stage 3 of 5".
  int get number => index + 1;
}
