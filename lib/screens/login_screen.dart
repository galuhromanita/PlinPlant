import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../routes.dart';
import '../stores/user_session.dart';
import '../widgets/app_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with WidgetsBindingObserver {
  bool _isLoading = false;
  bool _navigated = false;
  bool _oauthInProgress = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Dengarkan perubahan auth — ketika OAuth selesai, user_session
    // akan set currentUser, dan listener ini menangkap perubahan itu.
    UserSession().addListener(_onAuthChanged);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    UserSession().removeListener(_onAuthChanged);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _oauthInProgress) {
      debugPrint('[AUTH DEBUG] Aplikasi kembali aktif setelah OAuth');
      unawaited(_restoreSessionAfterOAuth());
    }
  }

  void _onAuthChanged() {
    if (_navigated) return;
    if (UserSession().currentUser != null && mounted) {
      _navigated = true;
      _oauthInProgress = false;
      setState(() => _isLoading = false);
      debugPrint('[AUTH DEBUG] Navigasi ke Home setelah session tersedia');
      Navigator.of(context)
          .pushNamedAndRemoveUntil(AppRoutes.home, (_) => false);
    }
  }

  Future<void> _restoreSessionAfterOAuth() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));

    for (var attempt = 0; attempt < 10; attempt++) {
      if (!mounted || !_oauthInProgress) return;

      try {
        if (await UserSession().restoreCurrentSession()) return;
      } catch (error) {
        debugPrint(
          '[AUTH DEBUG] Pemulihan session gagal: ${error.runtimeType}',
        );
      }

      await Future<void>.delayed(const Duration(milliseconds: 500));
    }

    if (!mounted || !_oauthInProgress) return;
    _oauthInProgress = false;
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Session Google belum diterima aplikasi. Periksa konfigurasi OAuth '
          'dan coba lagi.',
        ),
      ),
    );
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    _oauthInProgress = true;

    try {
      await UserSession().loginWithGoogle();
    } catch (error) {
      debugPrint(
        '[AUTH DEBUG] Login Google gagal dimulai: ${error.runtimeType}',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Login Google tidak dapat dimulai. Periksa koneksi lalu coba lagi.',
          ),
        ),
      );
      _oauthInProgress = false;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final screenW = constraints.maxWidth;
            final screenH = constraints.maxHeight;

            final logoSize = (screenW * 0.22).clamp(60.0, 100.0);
            final titleSize = (screenW * 0.10).clamp(26.0, 42.0);
            final subtitleSize = (screenW * 0.038).clamp(12.0, 16.0);
            final btnFontSize = (screenW * 0.042).clamp(13.0, 17.0);
            // Login tetap responsif agar form tidak terlalu sempit pada layar kecil.
            final hPad = (screenW * 0.07).clamp(AppSpacing.page, 40.0);
            final privFontSize = (screenW * 0.028).clamp(10.0, 12.5);

            return Stack(
              children: [
                // ── Gelombang hijau pojok kanan atas ───────────────
                Positioned(
                  top: 0,
                  right: 0,
                  child: IgnorePointer(
                    child: CustomPaint(
                      size: Size(screenW * 0.78, screenH * 0.40),
                      painter: _TopWavePainter(),
                    ),
                  ),
                ),

                // [Fix] SafeArea + SingleChildScrollView agar tidak overflow
                SafeArea(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: ConstrainedBox(
                      // Minimum height = full screen agar tombol tetap
                      // di posisi yang baik di layar besar
                      constraints: BoxConstraints(
                        minHeight:
                            constraints.maxHeight -
                            MediaQuery.of(context).padding.top -
                            MediaQuery.of(context).padding.bottom,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
                            // ── Bagian atas: logo + teks + tombol ───
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: hPad),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(height: AppSpacing.section),

                                  // Logo
                                  Center(
                                    child: Image.asset(
                                      'assets/icon/plinplant_logo_green.png',
                                      width: logoSize,
                                      height: logoSize,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, _, _) => Icon(
                                        Icons.eco_rounded,
                                        size: logoSize,
                                        color: AppColors.success,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: AppSpacing.tight),

                                  // Nama App
                                  Text(
                                    'PlinPlant',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      color: AppColors.loginText,
                                      fontSize: titleSize,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -1.5,
                                      height: 1.0,
                                    ),
                                  ),
                                  SizedBox(height: AppSpacing.tight),

                                  Text(
                                    'Selamat datang!',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      color: AppColors.loginText,
                                      fontSize: (screenW * 0.055).clamp(
                                        16.0,
                                        24.0,
                                      ),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(height: AppSpacing.tight),

                                  Text(
                                    'Masuk untuk melanjutkan ke aplikasi PlinPlant.',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      color: AppColors.textSecondary,
                                      fontSize: subtitleSize,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  SizedBox(height: AppSpacing.section),

                                  // ── Tombol Login Google ────────────
                                  ElevatedButton(
                                    onPressed: _isLoading
                                        ? null
                                        : _handleGoogleLogin,
                                    style: ElevatedButton.styleFrom(
                                      disabledBackgroundColor: AppColors.primary
                                          .withValues(alpha: 0.7),
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2.5,
                                            ),
                                          )
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: 28,
                                                height: 28,
                                                decoration: const BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.circle,
                                                ),
                                                padding: const EdgeInsets.all(
                                                  5,
                                                ),
                                                child: Image.asset(
                                                  'assets/icon/google_g_logo.png',
                                                  fit: BoxFit.contain,
                                                  errorBuilder: (_, _, _) =>
                                                      const Icon(
                                                        Icons.g_mobiledata,
                                                        size: 18,
                                                      ),
                                                ),
                                              ),
                                              const SizedBox(
                                                width: AppSpacing.item,
                                              ),
                                              Text(
                                                'Lanjutkan dengan Google',
                                                style: GoogleFonts.poppins(
                                                  color: Colors.white,
                                                  fontSize: btnFontSize,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                  SizedBox(height: AppSpacing.item),
                                ],
                              ),
                            ),

                            // ── Gambar tanaman — mengisi sisa ruang ─
                            Expanded(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  minHeight: 120,
                                ),
                                child: Image.asset(
                                  'assets/images/gambar_login.png',
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  alignment: Alignment.topCenter,
                                  errorBuilder: (_, _, _) => const SizedBox(
                                    height: AppSpacing.section,
                                  ),
                                ),
                              ),
                            ),

                            // ── Teks privasi ───────────────────────
                            Container(
                              color: Colors.white,
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                horizontal: hPad,
                                vertical: AppSpacing.item,
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'Dengan melanjutkan, Anda menyetujui',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      color: AppColors.textHint,
                                      fontSize: privFontSize,
                                    ),
                                  ),
                                  RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(
                                      style: GoogleFonts.poppins(
                                        fontSize: privFontSize,
                                      ),
                                      children: const [
                                        TextSpan(
                                          text: 'Kebijakan Privasi',
                                          style: TextStyle(
                                            color: AppColors.loginGreen,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        TextSpan(
                                          text: ' dan ',
                                          style: TextStyle(
                                            color: AppColors.textHint,
                                          ),
                                        ),
                                        TextSpan(
                                          text: 'Ketentuan Layanan',
                                          style: TextStyle(
                                            color: AppColors.loginGreen,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        TextSpan(
                                          text: ' kami.',
                                          style: TextStyle(
                                            color: AppColors.textHint,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// GELOMBANG HIJAU BAGIAN ATAS
// ════════════════════════════════════════════════════════════════

class _TopWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.loginWave
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height * 0.60);
    path.cubicTo(
      size.width * 0.92,
      size.height * 0.50,
      size.width * 0.78,
      size.height * 0.45,
      size.width * 0.70,
      size.height * 0.34,
    );
    path.cubicTo(
      size.width * 0.62,
      size.height * 0.22,
      size.width * 0.54,
      size.height * 0.12,
      size.width * 0.40,
      0,
    );
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
