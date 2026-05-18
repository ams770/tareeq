import 'package:flutter_test/flutter_test.dart';
import 'package:tareeq/app/app.dart';
import 'package:tareeq/app/di.dart';

void main() {
  testWidgets('App loads cleanly without crash', (WidgetTester tester) async {
    // Initialize dependency injection for testing scope
    await initDI();

    // Pump the primary TareeqApp widget
    await tester.pumpWidget(const TareeqApp());

    // Expect the main TareeqApp shell is rendered successfully
    expect(find.byType(TareeqApp), findsOneWidget);
  });
}
