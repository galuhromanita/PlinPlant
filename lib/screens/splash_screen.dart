import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  // Logo zoom in dari 0.30 → 1.0, fade in bersamaan
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();

    // Set status bar transparan supaya full-screen
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Scale: 0.30 → 1.0 dengan easeOutBack (efek overshoot halus)
    _scale = Tween<double>(begin: 0.30, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.75, curve: Curves.easeOutBack),
      ),
    );

    // Opacity: 0 → 1 pada 35% pertama animasi
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.35, curve: Curves.easeIn),
      ),
    );

    _runSequence();
  }

  Future<void> _runSequence() async {
    // Tunggu sebentar sebelum mulai
    await Future.delayed(const Duration(milliseconds: 200));

    if (!mounted) return;

    // Jalankan animasi zoom-in
    await _ctrl.forward();

    // Tahan sebentar di posisi akhir
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    // Navigasi ke LoginScreen dengan smooth fade transition
    Navigator.of(context).pushReplacement(
      _FadeRoute(page: const LoginScreen()),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3D8C2F),
      body: Stack(
        children: [
          // -------------------------------------------------------
          // ORNAMEN LINGKARAN TRANSPARAN KIRI ATAS
          // -------------------------------------------------------
          Positioned(
            top: -90,
            left: -90,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ),

          // -------------------------------------------------------
          // ORNAMEN LINGKARAN TRANSPARAN KANAN BAWAH
          // -------------------------------------------------------
          Positioned(
            bottom: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ),

          // -------------------------------------------------------
          // HANYA LOGO DI TENGAH — TANPA TEKS / TAGLINE
          // -------------------------------------------------------
          Center(
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (context, _) {
                return Opacity(
                  opacity: _opacity.value,
                  child: Transform.scale(
                    scale: _scale.value,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Responsif: ukuran logo menyesuaikan layar
                        final screenW = MediaQuery.of(context).size.width;
                        final logoSize = (screenW * 0.38).clamp(100.0, 160.0);
                        return Image.asset(
                          'assets/icon/plinplant_logo_white.png',
                          width: logoSize,
                          height: logoSize,
                          fit: BoxFit.contain,
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// =================================================================
// CUSTOM PAGE ROUTE — SMOOTH FADE TRANSITION
// =================================================================

class _FadeRoute extends PageRouteBuilder {
  final Widget page;

  _FadeRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 700),
          reverseTransitionDuration: const Duration(milliseconds: 400),
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