import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'locale_controller.g.dart';

/// The app locale. `null` follows the device. Persisted and synced in M9.3.
@Riverpod(keepAlive: true)
class LocaleController extends _$LocaleController {
  @override
  Locale? build() => null;

  void setLocale(Locale? locale) => state = locale;
}
