import 'package:flutter_test/flutter_test.dart';
import 'package:traveless/main.dart';

void main() {
  testWidgets('Traveless App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TravelessApp());

    // Verify that our home screen loads and displays the main text
    expect(find.textContaining('Explore'), findsOneWidget);
  });
}
