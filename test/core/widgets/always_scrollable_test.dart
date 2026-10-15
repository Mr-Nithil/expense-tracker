import 'package:expense_tracker/core/widgets/always_scrollable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('gives short content the full height and still lets it be pulled', (tester) async {
    var refreshed = 0;
    await tester.pumpApp(
      RefreshIndicator(
        onRefresh: () async => refreshed++,
        child: const AlwaysScrollable(child: Center(child: Text('Nothing here'))),
      ),
    );

    final viewport = tester.getSize(find.byType(AlwaysScrollable));
    expect(tester.getSize(find.byType(SizedBox).last).height, viewport.height);

    await tester.fling(findText('Nothing here'), const Offset(0, 400), 1000);
    await tester.pumpAndSettle();

    expect(refreshed, 1);
  });
}
