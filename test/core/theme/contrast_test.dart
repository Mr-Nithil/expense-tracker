import 'package:expense_tracker/core/theme/contrast.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const white = Color(0xFFFFFFFF);
  const black = Color(0xFF000000);
  const darkSurface = Color(0xFF1D1B20);

  test('ratio follows WCAG', () {
    expect(Contrast.ratio(black, white), closeTo(21, 0.01));
    expect(Contrast.ratio(white, black), closeTo(21, 0.01));
    expect(Contrast.ratio(white, white), 1);
  });

  test('ensure keeps a color that already passes', () {
    const indigo = Color(0xFF3949AB);
    expect(Contrast.ensure(indigo, on: white), indigo);
  });

  test('ensure lightens on a dark background just enough', () {
    const indigo = Color(0xFF3949AB);
    final shown = Contrast.ensure(indigo, on: darkSurface);

    expect(Contrast.ratio(shown, darkSurface), greaterThanOrEqualTo(3));
    expect(shown.computeLuminance(), greaterThan(indigo.computeLuminance()));
    expect(shown, isNot(white));
  });

  test('ensure darkens on a light background', () {
    const yellow = Color(0xFFFDD835);
    final shown = Contrast.ensure(yellow, on: white, min: 4.5);

    expect(Contrast.ratio(shown, white), greaterThanOrEqualTo(4.5));
    expect(shown.computeLuminance(), lessThan(yellow.computeLuminance()));
  });
}
