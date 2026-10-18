import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopsphere/app.dart';
import 'package:shopsphere/core/di/service_locator.dart';

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await sl.reset();
    await initDependencies();
  });

  tearDown(() async {
    await sl.reset();
  });

  testWidgets('ShopSphereApp smoke test - renders Splash branding', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: ShopSphereApp()));

    // Verify initial splash screen shows ShopSphere branding
    expect(find.text('ShopSphere'), findsOneWidget);
    expect(find.text('Smart shopping, curated for you'), findsOneWidget);
  });
}
