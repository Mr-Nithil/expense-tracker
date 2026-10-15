import 'package:expense_tracker/core/l10n/generated/app_localizations_en.dart';
import 'package:expense_tracker/core/widgets/password_strength_meter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  final l10n = AppLocalizationsEn();

  group('PasswordStrength (the prototype\'s rule)', () {
    test('under 8 characters: score 1 and how many are missing', () {
      expect(PasswordStrength.of('abc').score, 1);
      expect(PasswordStrength.of('abc').missing, 5);
      expect(PasswordStrength.of('abc').label(l10n), '5 more');
      expect(PasswordStrength.of('abcdefg').label(l10n), '1 more');
    });

    test('one point each: length, mixed case, digit, symbol or 12+', () {
      expect(PasswordStrength.of('abcdefgh').score, 1);
      expect(PasswordStrength.of('abcdEfgh').score, 2);
      expect(PasswordStrength.of('abcdEfg1').score, 3);
      expect(PasswordStrength.of('abcdEf1!').score, 4);
      expect(PasswordStrength.of('abcdefghijkl').score, 2, reason: '12+ counts like a symbol');
      expect(PasswordStrength.of('abcdEfgh1!xyz').score, 4, reason: 'capped at 4');
    });

    test('labels', () {
      expect(PasswordStrength.of('abcdefgh').label(l10n), l10n.passwordStrengthOkay);
      expect(PasswordStrength.of('abcdEfgh').label(l10n), l10n.passwordStrengthGood);
      expect(PasswordStrength.of('abcdEfg1').label(l10n), l10n.passwordStrengthGreat);
      expect(PasswordStrength.of('abcdEf1!').label(l10n), l10n.passwordStrengthStrong);
    });
  });

  testWidgets('nothing for an empty password', (tester) async {
    await tester.pumpApp(const PasswordStrengthMeter(password: ''));
    expect(find.byType(Row), findsNothing);
  });

  testWidgetsBothThemes('fills the segments and announces the level', (tester, brightness) async {
    await tester.pumpApp(const PasswordStrengthMeter(password: 'abcdEfg1'), brightness: brightness);

    expect(find.text(l10n.passwordStrengthGreat), findsOneWidget);
    expect(
      find.bySemanticsLabel(l10n.passwordStrengthLabel(l10n.passwordStrengthGreat)),
      findsOneWidget,
    );
    final segments = tester
        .widgetList<Container>(find.byType(Container))
        .map((c) => (c.decoration! as BoxDecoration).color)
        .toList();
    final scheme = Theme.of(tester.element(find.byType(Row))).colorScheme;
    expect(segments.where((c) => c == scheme.primary), hasLength(3));
  });
}
