import 'package:flutter_test/flutter_test.dart';

import 'package:budget_app/main.dart';

void main() {
  testWidgets('App renders home page', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Home page'), findsOneWidget);
  });
}
