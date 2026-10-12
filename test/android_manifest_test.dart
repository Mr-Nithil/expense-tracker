import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards the Android setup that scheduled notifications need (M8.1, M8.7). It can't be
/// exercised by unit tests, so its pieces are checked here against accidental removal.
void main() {
  final manifest = File('android/app/src/main/AndroidManifest.xml').readAsStringSync();

  String receiver(String name) {
    final start = manifest.indexOf('android:name="com.dexterous.flutterlocalnotifications.$name"');
    expect(start, isNot(-1), reason: '$name is declared');
    final open = manifest.lastIndexOf('<receiver', start);
    // The receiver tag ends at its first '>': '/>' means it has no body.
    final tagEnd = manifest.indexOf('>', start);
    final selfClosing = manifest[tagEnd - 1] == '/';
    final end = selfClosing ? tagEnd : manifest.indexOf('</receiver>', start);
    return manifest.substring(open, end);
  }

  test('scheduled notifications are delivered by a private receiver', () {
    expect(receiver('ScheduledNotificationReceiver'), contains('android:exported="false"'));
  });

  test('reboots and app updates reschedule them', () {
    expect(manifest, contains('android.permission.RECEIVE_BOOT_COMPLETED'));
    final boot = receiver('ScheduledNotificationBootReceiver');
    expect(boot, contains('android:exported="false"'));
    for (final action in [
      'android.intent.action.BOOT_COMPLETED',
      'android.intent.action.MY_PACKAGE_REPLACED',
      'android.intent.action.QUICKBOOT_POWERON',
    ]) {
      expect(boot, contains(action), reason: action);
    }
  });

  test('no exact-alarm permission (reminders are inexact by design)', () {
    expect(manifest, isNot(contains('SCHEDULE_EXACT_ALARM')));
    expect(manifest, isNot(contains('USE_EXACT_ALARM')));
  });
}
