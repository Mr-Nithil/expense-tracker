import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/l10n/generated/app_localizations_en.dart';
import 'package:expense_tracker/core/widgets/async_value_view.dart';
import 'package:expense_tracker/core/widgets/empty_state.dart';
import 'package:expense_tracker/core/widgets/error_view.dart';
import 'package:expense_tracker/core/widgets/loading_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  final l10n = AppLocalizationsEn();

  group('EmptyState', () {
    testWidgetsBothThemes('shows title, message and action', (tester, brightness) async {
      var taps = 0;
      await tester.pumpApp(
        EmptyState(
          title: 'Nothing',
          message: 'Add one',
          actionLabel: 'Add',
          onAction: () => taps++,
        ),
        brightness: brightness,
      );
      expect(findText('Nothing'), findsOneWidget);
      expect(findText('Add one'), findsOneWidget);
      await tester.tap(findText('Add'));
      expect(taps, 1);
    });

    testWidgets('hides the action without a callback', (tester) async {
      await tester.pumpApp(const EmptyState(message: 'Empty', actionLabel: 'Add'));
      expect(findText('Add'), findsNothing);
    });
  });

  group('LoadingView', () {
    testWidgetsBothThemes('shows a labelled spinner and message', (tester, brightness) async {
      await tester.pumpApp(const LoadingView(message: 'Syncing'), brightness: brightness);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.bySemanticsLabel(l10n.commonLoading), findsOneWidget);
      expect(findText('Syncing'), findsOneWidget);
    });
  });

  group('ErrorView', () {
    testWidgetsBothThemes('shows the message and a localized retry', (tester, brightness) async {
      var retries = 0;
      await tester.pumpApp(
        ErrorView(message: 'Failed', onRetry: () => retries++),
        brightness: brightness,
      );
      expect(findText('Failed'), findsOneWidget);
      await tester.tap(findText(l10n.commonRetry));
      expect(retries, 1);
    });

    testWidgets('hides retry without a callback', (tester) async {
      await tester.pumpApp(const ErrorView(message: 'Failed'));
      expect(findText(l10n.commonRetry), findsNothing);
    });
  });

  group('AsyncValueView', () {
    Widget view(AsyncValue<int> value) => AsyncValueView<int>(
      value: value,
      data: (v) => Text('value $v'),
    );

    testWidgets('renders data', (tester) async {
      await tester.pumpApp(view(const AsyncData(3)));
      expect(findText('value 3'), findsOneWidget);
    });

    testWidgets('renders loading', (tester) async {
      await tester.pumpApp(view(const AsyncLoading()));
      expect(find.byType(LoadingView), findsOneWidget);
    });

    testWidgets('renders a localized error for failures and unknown errors', (tester) async {
      await tester.pumpApp(view(const AsyncError(NetworkFailure('x'), StackTrace.empty)));
      expect(findText(l10n.errorNetwork), findsOneWidget);

      await tester.pumpApp(view(AsyncError(StateError('internal'), StackTrace.empty)));
      expect(findText(l10n.errorUnexpected), findsOneWidget);
      expect(find.textContaining('internal'), findsNothing);
    });
  });
}
