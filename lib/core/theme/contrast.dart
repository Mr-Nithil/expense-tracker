import 'package:flutter/painting.dart';

/// WCAG contrast helpers (M9.5).
abstract final class Contrast {
  /// Pure black and white, the ends [ensure] mixes toward.
  static const _black = Color(0xFF000000);
  static const _white = Color(0xFFFFFFFF);

  /// The WCAG contrast ratio of [a] and [b], from 1 (same) to 21 (black on white).
  static double ratio(Color a, Color b) {
    final (la, lb) = (a.computeLuminance(), b.computeLuminance());
    final (lighter, darker) = la > lb ? (la, lb) : (lb, la);
    return (lighter + 0.05) / (darker + 0.05);
  }

  /// [color] if it already reaches [min] against [on]; otherwise the closest mix of [color]
  /// toward white or black (whichever can get there) that does. For drawing user-chosen colors
  /// (e.g. category icons) readably in both themes; the stored color is unchanged.
  static Color ensure(Color color, {required Color on, double min = 3}) {
    if (ratio(color, on) >= min) return color;
    final toward = ratio(_white, on) >= ratio(_black, on) ? _white : _black;
    for (var step = 1; step <= 20; step++) {
      final mixed = Color.lerp(color, toward, step / 20)!;
      if (ratio(mixed, on) >= min) return mixed;
    }
    return toward;
  }
}
