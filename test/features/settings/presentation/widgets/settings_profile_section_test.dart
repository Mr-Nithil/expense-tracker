import 'dart:async';

import 'package:expense_tracker/core/l10n/generated/app_localizations_en.dart';
import 'package:expense_tracker/features/auth/domain/entities/auth_snapshot.dart';
import 'package:expense_tracker/features/auth/domain/entities/auth_user.dart';
import 'package:expense_tracker/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:expense_tracker/features/profile/domain/entities/profile.dart';
import 'package:expense_tracker/features/profile/presentation/providers/profile_providers.dart';
import 'package:expense_tracker/features/settings/presentation/widgets/settings_profile_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  final l10n = AppLocalizationsEn();
  const user = AuthUser(id: 'u1', email: 'sam@example.com', displayName: 'Sam');

  Future<void> pump(
    WidgetTester tester, {
    required Stream<Profile?> profile,
    AuthUser? authUser = user,
    Brightness brightness = Brightness.light,
  }) async {
    await tester.pumpApp(
      const SettingsProfileSection(),
      brightness: brightness,
      overrides: [
        profileProvider.overrideWith((ref) => profile),
        authStateProvider.overrideWith((ref) => Stream.value(AuthSnapshot(user: authUser))),
      ],
    );
    await tester.pumpAndSettle();
  }

  testWidgetsBothThemes('shows name, email and the read-only currency', (tester, brightness) async {
    await pump(
      tester,
      profile: Stream.value(const Profile(id: 'u1', displayName: 'Sam', currencyCode: 'EUR')),
      brightness: brightness,
    );

    expect(find.text(l10n.settingsProfileLabel), findsOneWidget);
    expect(find.text('Sam'), findsOneWidget);
    expect(find.text('sam@example.com'), findsOneWidget);
    expect(find.text(l10n.settingsCurrency), findsOneWidget);
    expect(find.text(l10n.settingsCurrencyValue('EUR', '€')), findsOneWidget);
    expect(find.text(l10n.settingsCurrencyLocked), findsOneWidget);
  });

  testWidgets('the currency cannot be tapped (no way to change it)', (tester) async {
    await pump(
      tester,
      profile: Stream.value(const Profile(id: 'u1', currencyCode: 'USD')),
    );

    final tile = tester.widget<ListTile>(
      find.ancestor(of: find.text(l10n.settingsCurrency), matching: find.byType(ListTile)),
    );
    expect(tile.onTap, isNull);
    expect(tile.enabled, isTrue);
  });

  testWidgets('without a name, the email is the title', (tester) async {
    await pump(
      tester,
      profile: Stream.value(const Profile(id: 'u1', currencyCode: 'USD')),
      authUser: const AuthUser(id: 'u1', email: 'sam@example.com'),
    );

    final tile = tester.widget<ListTile>(
      find.ancestor(of: find.text('sam@example.com'), matching: find.byType(ListTile)),
    );
    expect(tile.subtitle, isNull);
  });

  testWidgets('the profile name wins over the account name', (tester) async {
    await pump(
      tester,
      profile: Stream.value(
        const Profile(id: 'u1', displayName: 'Samantha', currencyCode: 'USD'),
      ),
    );

    expect(find.text('Samantha'), findsOneWidget);
    expect(find.text('Sam'), findsNothing);
  });

  testWidgets('shows nothing until the profile has loaded', (tester) async {
    final pending = StreamController<Profile?>();
    addTearDown(pending.close);
    await tester.pumpApp(
      const SettingsProfileSection(),
      overrides: [
        profileProvider.overrideWith((ref) => pending.stream),
        authStateProvider.overrideWith((ref) => Stream.value(const AuthSnapshot(user: user))),
      ],
    );
    await tester.pump();

    expect(find.text(l10n.settingsProfileLabel), findsNothing);
    expect(find.byType(ListTile), findsNothing);
  });
}
