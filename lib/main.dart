import 'package:expense_tracker/app.dart';
import 'package:expense_tracker/core/config/env.dart';
import 'package:expense_tracker/core/logging/app_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Bootstrap only. Run with `flutter run --dart-define-from-file=env.json`.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // The bundled Nunito font's licence (SIL OFL 1.1) appears on the app's licence page.
  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks([
      'Nunito',
    ], await rootBundle.loadString('assets/fonts/OFL.txt'));
  });

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    AppLogger.error('Flutter error', details.exception, details.stack);
  };
  PlatformDispatcher.instance.onError = (error, stackTrace) {
    AppLogger.error('Uncaught error', error, stackTrace);
    return true;
  };

  Env.ensureConfigured();
  // Restores a persisted session from local storage without a network call (ARCHITECTURE §10).
  await Supabase.initialize(url: Env.supabaseUrl, publishableKey: Env.supabaseAnonKey);

  runApp(const ProviderScope(child: App()));
}
