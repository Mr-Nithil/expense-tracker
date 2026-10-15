import 'package:expense_tracker/core/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgetsBothThemes('shows title, actions, body and FAB', (tester, brightness) async {
    await tester.pumpApp(
      AppScaffold(
        title: 'Title',
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.add), tooltip: 'Add')],
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          tooltip: 'Edit',
          child: const Icon(Icons.edit),
        ),
        body: const Text('Body'),
      ),
      brightness: brightness,
    );
    expect(findText('Title'), findsOneWidget);
    expect(find.byTooltip('Add'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(findText('Body'), findsOneWidget);
    expect(find.byType(RefreshIndicator), findsNothing);
  });

  testWidgets('supports pull-to-refresh when onRefresh is set', (tester) async {
    var refreshed = 0;
    await tester.pumpApp(
      AppScaffold(
        title: 'Title',
        onRefresh: () async => refreshed++,
        body: ListView(children: const [SizedBox(height: 2000, child: Text('Item'))]),
      ),
    );
    await tester.fling(find.byType(ListView), const Offset(0, 300), 1000);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(refreshed, 1);
  });

  testWidgets('shows a bottom widget under the app bar', (tester) async {
    await tester.pumpApp(
      const DefaultTabController(
        length: 2,
        child: AppScaffold(
          title: 'Title',
          bottom: TabBar(
            tabs: [
              Tab(text: 'One'),
              Tab(text: 'Two'),
            ],
          ),
          body: SizedBox(),
        ),
      ),
    );
    expect(findText('One'), findsOneWidget);
    expect(find.descendant(of: find.byType(AppBar), matching: find.byType(TabBar)), findsOneWidget);
  });
}
