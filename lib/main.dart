import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/plant_detail_screen.dart';
import 'screens/add_plant_screen.dart';
import 'screens/profile_screen.dart';
import 'models/plant_model.dart'; // needed for editPlant route cast

// ============================================================
// ROUTING CONFIGURATION
// Named routes untuk navigasi terstruktur di PlinPlant.
// ============================================================

class AppRoutes {
  // Route name constants
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String plantDetail = '/plant-detail';
  static const String addPlant = '/add-plant';
  static const String editPlant = '/edit-plant';
  static const String aboutApp = '/about-app';
  static const String accountInfo = '/account-info';
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PlinPlantApp());
}

class PlinPlantApp extends StatelessWidget {
  const PlinPlantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PlinPlant',
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3D8B4A),
        ),
      ),
      // ── Named Routes ─────────────────────────────────────────
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}

// ============================================================
// ROUTER — Mengelola semua navigasi named route
// ============================================================

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _fadeRoute(const SplashScreen(), settings);

      case AppRoutes.login:
        return _fadeRoute(const LoginScreen(), settings);

      case AppRoutes.home:
        return _slideRoute(const HomeScreen(), settings);

      case AppRoutes.plantDetail:
        final plantId = settings.arguments as String;
        return _slideRoute(
          PlantDetailScreen(plantId: plantId),
          settings,
        );

      case AppRoutes.addPlant:
        return _slideRoute(const AddPlantScreen(), settings);

      case AppRoutes.editPlant:
        final plantToEdit = settings.arguments as PlantModel;
        return _slideRoute(
          AddPlantScreen(plantToEdit: plantToEdit),
          settings,
        );

      case AppRoutes.aboutApp:
        return _slideRoute(const AboutAppScreen(), settings);

      case AppRoutes.accountInfo:
        return _slideRoute(const AccountInfoScreen(), settings);

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Halaman tidak ditemukan: ${settings.name}'),
            ),
          ),
        );
    }
  }

  // ── Transition Helpers ────────────────────────────────────

  static PageRouteBuilder _fadeRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 600),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          ),
          child: child,
        );
      },
    );
  }

  static PageRouteBuilder _slideRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 350),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}