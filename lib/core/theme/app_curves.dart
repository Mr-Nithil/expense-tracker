import 'package:flutter/animation.dart';

/// Motion curves (README §Interactions and motion).
abstract final class AppCurves {
  /// The design's overshoot: bar widths, switch knob, plant stage pop, bubble pop-in, Pip's eyes.
  static const elastic = Cubic(.34, 1.56, .64, 1);
}
