import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinplant/config/supabase_config.dart';
import 'package:plinplant/main.dart';
import 'package:plinplant/routes.dart';
import 'package:plinplant/screens/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.anonKey,
    );
  });

  testWidgets('PlinPlant membuka splash screen', (tester) async {
    await tester.pumpWidget(const PlinPlantApp());
    expect(find.byType(SplashScreen), findsOneWidget);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pump(const Duration(milliseconds: 600));
  });

  test('OAuth callback code menghasilkan route aplikasi', () {
    final route = AppRouter.generateRoute(
      const RouteSettings(name: '/?code=test-code'),
    );

    expect(route, isA<PageRoute<dynamic>>());
  });
}
