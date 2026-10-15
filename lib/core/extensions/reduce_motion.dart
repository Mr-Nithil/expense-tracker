import 'package:flutter/widgets.dart';

/// Whether the user asked for less motion (system setting). Animated widgets then skip
/// decorative motion (bob, sway, wave, confetti) and apply state changes instantly.
extension ReduceMotion on BuildContext {
  bool get reduceMotion => MediaQuery.maybeDisableAnimationsOf(this) ?? false;
}
