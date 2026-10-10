import 'package:expense_tracker/core/widgets/section_header.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgetsBothThemes('shows the title and fires the action', (tester, brightness) async {
    var taps = 0;
    await tester.pumpApp(
      SectionHeader(title: 'Recent', actionLabel: 'See all', onAction: () => taps++),
      brightness: brightness,
    );
    expect(find.text('Recent'), findsOneWidget);
    await tester.tap(find.text('See all'));
    expect(taps, 1);
  });

  testWidgets('hides the action without a callback', (tester) async {
    await tester.pumpApp(const SectionHeader(title: 'Recent', actionLabel: 'See all'));
    expect(find.text('See all'), findsNothing);
  });
}
