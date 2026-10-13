import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Native setup that biometric unlock (M7.2, `local_auth`) needs. A regression here only shows on
/// a real device, so it is checked on every test run.
void main() {
  test('Android: MainActivity is a FlutterFragmentActivity', () {
    final source = File(
      'android/app/src/main/kotlin/com/example/expense_tracker/MainActivity.kt',
    ).readAsStringSync();

    expect(source, contains('class MainActivity : FlutterFragmentActivity()'));
  });

  test('Android: launch themes are AppCompat (Android 8 and older)', () {
    for (final path in [
      'android/app/src/main/res/values/styles.xml',
      'android/app/src/main/res/values-night/styles.xml',
    ]) {
      final parents = RegExp(
        r'parent="([^"]+)"',
      ).allMatches(File(path).readAsStringSync()).map((m) => m.group(1)!);
      expect(parents, isNotEmpty, reason: path);
      expect(parents, everyElement(startsWith('Theme.AppCompat')), reason: path);
    }
  });

  test('iOS: Info.plist explains Face ID', () {
    final plist = File('ios/Runner/Info.plist').readAsStringSync();

    expect(
      RegExp(r'<key>NSFaceIDUsageDescription</key>\s*<string>[^<]+</string>').hasMatch(plist),
      isTrue,
    );
  });
}
