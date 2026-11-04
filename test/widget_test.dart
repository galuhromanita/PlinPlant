import 'package:flutter_test/flutter_test.dart';
import 'package:plinplant/main.dart';
import 'package:plinplant/screens/splash_screen.dart';

void main() {
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
}
