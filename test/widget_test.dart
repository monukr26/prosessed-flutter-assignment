import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/app.dart';

void main() {
  testWidgets('ShopSphereApp smoke test - renders Splash branding', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: ShopSphereApp()));

    // Verify initial splash screen shows ShopSphere branding
    expect(find.text('ShopSphere'), findsOneWidget);
    expect(find.text('Smart shopping, curated for you'), findsOneWidget);
  });
}
