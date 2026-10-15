import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The Sprout design's Nunito font ships with the app (M12.1): four static weights and the OFL
/// licence, declared in pubspec.yaml.
void main() {
  test('the four Nunito weights and the licence are bundled and declared', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    for (final (file, weight) in [
      ('Nunito-SemiBold.ttf', 600),
      ('Nunito-Bold.ttf', 700),
      ('Nunito-ExtraBold.ttf', 800),
      ('Nunito-Black.ttf', 900),
    ]) {
      expect(File('assets/fonts/$file').existsSync(), isTrue, reason: file);
      expect(
        RegExp('asset: assets/fonts/$file\\s+weight: $weight').hasMatch(pubspec),
        isTrue,
        reason: '$file declared with weight $weight',
      );
    }
    expect(File('assets/fonts/OFL.txt').readAsStringSync(), contains('SIL Open Font License'));
    expect(pubspec, contains('- assets/fonts/OFL.txt'));
  });
}
