import 'dart:async';

import 'package:expense_tracker/core/l10n/generated/app_localizations_en.dart';
import 'package:expense_tracker/core/l10n/generated/app_localizations_si.dart';
import 'package:expense_tracker/core/l10n/locale_controller.dart';
import 'package:expense_tracker/core/services/local_notification_service.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_notification_service.dart';

/// The app language, driven by the test.
class _FakeLocale extends LocaleController {
  _FakeLocale(this._locales);

  final Stream<Locale?> _locales;

  @override
  Stream<Locale?> build() => _locales;
}

void main() {
  final en = AppLocalizationsEn();
  final si = AppLocalizationsSi();

  late FakeNotificationService notifications;
  late StreamController<Locale?> appLocale;
  late ProviderContainer container;

  /// Like a phone: the primary locale and the list change together.
  void setDeviceLocale(WidgetTester tester, Locale locale) {
    tester.platformDispatcher
      ..localeTestValue = locale
      ..localesTestValue = [locale];
  }

  Future<void> start(WidgetTester tester, {Locale device = const Locale('en', 'US')}) async {
    setDeviceLocale(tester, device);
    addTearDown(tester.platformDispatcher.clearLocaleTestValue);
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    notifications = FakeNotificationService();
    appLocale = StreamController<Locale?>();
    addTearDown(appLocale.close);
    container = ProviderContainer(
      overrides: [
        notifications.providerOverride,
        localeControllerProvider.overrideWith(() => _FakeLocale(appLocale.stream)),
      ],
    );
    addTearDown(container.dispose);
    container.listen(notificationChannelLanguageProvider, (_, _) {});
    await tester.pump();
  }

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 5; i++) {
      await tester.pump();
    }
  }

  testWidgets('choosing Sinhala in the app renames the channels', (tester) async {
    await start(tester);
    appLocale.add(null);
    await settle(tester);
    expect(notifications.labels?.reminders, en.notificationsChannelReminders);

    appLocale.add(const Locale('si'));
    await settle(tester);

    expect(notifications.labelUpdates.last.reminders, si.notificationsChannelReminders);
    expect(notifications.labelUpdates.last.budgetAlerts, si.notificationsChannelBudgetAlerts);
    expect(
      notifications.labelUpdates.last.budgetAlertsDescription,
      si.notificationsChannelBudgetAlertsDescription,
    );
  });

  testWidgets('the same language again renames nothing', (tester) async {
    await start(tester);
    appLocale.add(const Locale('si'));
    await settle(tester);
    final count = notifications.labelUpdates.length;

    appLocale.add(const Locale('si'));
    await settle(tester);

    expect(notifications.labelUpdates, hasLength(count));
  });

  testWidgets('following the phone, a phone language change renames them', (tester) async {
    await start(tester);
    appLocale.add(null);
    await settle(tester);

    setDeviceLocale(tester, const Locale('si', 'LK'));
    await settle(tester);

    expect(notifications.labelUpdates.last.reminders, si.notificationsChannelReminders);
  });

  testWidgets('a failure is logged, never thrown, and the next change still works', (tester) async {
    await start(tester);
    appLocale.add(null);
    await settle(tester);

    notifications.failRenames = true;
    appLocale.add(const Locale('si'));
    await settle(tester);
    expect(tester.takeException(), isNull);

    notifications.failRenames = false;
    appLocale.add(const Locale('en'));
    await settle(tester);
    appLocale.add(const Locale('si'));
    await settle(tester);
    expect(notifications.labelUpdates.last.reminders, si.notificationsChannelReminders);
  });
}
