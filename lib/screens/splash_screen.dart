import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../main.dart';

// ============================================================
// SPLASH SCREEN — Screen #1
// ============================================================

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();

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

    _scale = Tween<double>(begin: 0.30, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.75, curve: Curves.easeOutBack),
      ),
    );

    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.35, curve: Curves.easeIn),
      ),
    );

    _runSequence();
  }

  Future<void> _runSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;

    await _ctrl.forward();
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    // Navigasi ke login menggunakan named route
    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
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
          // Ornamen lingkaran kiri atas
          Positioned(
            top: -90,
            left: -90,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),

          // Ornamen lingkaran kanan bawah
          Positioned(
            bottom: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),

          // Logo di tengah
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