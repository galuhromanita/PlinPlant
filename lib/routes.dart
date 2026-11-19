import 'package:flutter/material.dart';

import 'models/plant_model.dart';
import 'screens/about_app_screen.dart';
import 'screens/account_info_screen.dart';
import 'screens/add_plant_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/plant_detail_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/success_action_screen.dart';
import 'stores/user_session.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String plantDetail = '/plant-detail';
  static const String addPlant = '/add-plant';
  static const String editPlant = '/edit-plant';
  static const String aboutApp = '/about-app';
  static const String accountInfo = '/account-info';
  static const String successAction = '/success-action';
}

class SuccessActionArguments {
  final String plantName;
  final String action;
  final IconData icon;
  final String plantId;

  const SuccessActionArguments({
    required this.plantName,
    required this.action,
    required this.icon,
    required this.plantId,
  });
}

enum PlantDetailResult { edited, deleted }

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
        final plantId = settings.arguments;
        if (plantId is! String) return _notFound(settings);
        return _slideRoute(PlantDetailScreen(plantId: plantId), settings);
      case AppRoutes.addPlant:
        return _slideRoute(const AddPlantScreen(), settings);
      case AppRoutes.editPlant:
        final plant = settings.arguments;
        if (plant is! PlantModel) return _notFound(settings);
        return _slideRoute(AddPlantScreen(plantToEdit: plant), settings);
      case AppRoutes.aboutApp:
        return _slideRoute(const AboutAppScreen(), settings);
      case AppRoutes.accountInfo:
        return _slideRoute(const AccountInfoScreen(), settings);
      case AppRoutes.successAction:
        final arguments = settings.arguments;
        if (arguments is! SuccessActionArguments) {
          return _notFound(settings);
        }
        return _slideRoute(
          SuccessActionScreen(
            plantName: arguments.plantName,
            action: arguments.action,
            icon: arguments.icon,
            plantId: arguments.plantId,
          ),
          settings,
        );
      default:
        // ── Tangani deep link OAuth callback dari Supabase ──────────
        //
        // Alur OAuth:
        // 1. Browser redirect ke io.supabase.plinplant://login-callback?code=...
        // 2. Android intent filter menangkap deep link, membuka app
        // 3. supabase_flutter (via app_links) mengekstrak URI:
        //    - Flutter deep link handler menghilangkan scheme+host
        //    - Hanya path (/) + query (?code=...) dikirim ke Navigator
        //    - Route name menjadi: "/?code=UUID..." atau "/login-callback?code=..."
        //      atau terkadang path lengkap dengan scheme
        // 4. Route ini TIDAK cocok dengan case '/' (exact match) → masuk default
        //
        // Solusi: deteksi kehadiran "code=" di route name (parameter OAuth),
        // atau "login-callback", atau "io.supabase" sebagai penanda callback.
        // Render _OAuthCallbackPage yang secara aktif menunggu auth selesai
        // lalu navigasi ke home, menghilangkan flash "halaman tidak ditemukan".
        final routeName = settings.name ?? '';
        if (routeName.contains('code=') ||
            routeName.contains('login-callback') ||
            routeName.startsWith('io.supabase')) {
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => const _OAuthCallbackPage(),
          );
        }
        return _notFound(settings);
    }
  }

  static MaterialPageRoute<void> _notFound(RouteSettings settings) {
    return MaterialPageRoute(
      settings: settings,
      builder: (_) => Scaffold(
        body: Center(child: Text('Halaman tidak ditemukan: ${settings.name}')),
      ),
    );
  }

  static PageRouteBuilder<void> _fadeRoute(
    Widget page,
    RouteSettings settings,
  ) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 600),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          child: child,
        );
      },
    );
  }

  static PageRouteBuilder<void> _slideRoute(
    Widget page,
    RouteSettings settings,
  ) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 350),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }
}

// ════════════════════════════════════════════════════════════════
// OAUTH CALLBACK PAGE
// ════════════════════════════════════════════════════════════════
//
// Widget yang ditampilkan saat deep link OAuth callback masuk
// sebagai route (misalnya "/?code=UUID").
//
// Halaman ini mendengarkan UserSession: begitu auth berhasil dan
// currentUser terisi, langsung navigasi ke home — menghilangkan
// flash "halaman tidak ditemukan" sepenuhnya.
//
// Jika setelah 5 detik auth belum selesai, fallback navigasi ke
// login agar pengguna tidak terjebak di halaman kosong.
// ════════════════════════════════════════════════════════════════

class _OAuthCallbackPage extends StatefulWidget {
  const _OAuthCallbackPage();

  @override
  State<_OAuthCallbackPage> createState() => _OAuthCallbackPageState();
}

class _OAuthCallbackPageState extends State<_OAuthCallbackPage> {
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    // Dengarkan perubahan auth state
    UserSession().addListener(_onAuthChanged);
    // Cek apakah user sudah login (mungkin callback sudah diproses)
    _checkAlreadyLoggedIn();
  }

  @override
  void dispose() {
    UserSession().removeListener(_onAuthChanged);
    super.dispose();
  }

  void _checkAlreadyLoggedIn() {
    // Gunakan addPostFrameCallback agar navigasi tidak terjadi saat build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _navigated) return;
      if (UserSession().currentUser != null) {
        _navigateToHome();
      } else {
        // Fallback: jika setelah 5 detik auth belum selesai, kembali ke login
        Future.delayed(const Duration(seconds: 5), () {
          if (!mounted || _navigated) return;
          if (UserSession().currentUser == null) {
            _navigated = true;
            Navigator.of(context).pushReplacementNamed(AppRoutes.login);
          }
        });
      }
    });
  }

  void _onAuthChanged() {
    if (!mounted || _navigated) return;
    if (UserSession().currentUser != null) {
      _navigateToHome();
    }
  }

  void _navigateToHome() {
    if (_navigated) return;
    _navigated = true;
    // pushNamedAndRemoveUntil agar seluruh stack (termasuk LoginScreen
    // dan halaman ini) dibersihkan, hanya HomeScreen yang tersisa.
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.home,
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Tampilkan layar putih kosong (tanpa teks error) selama menunggu
    // auth callback diproses oleh Supabase SDK
    return const Scaffold(backgroundColor: Colors.white);
  }
}
