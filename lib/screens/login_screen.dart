import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import '../providers/user_session.dart';

// ============================================================
// LOGIN SCREEN — Screen #2
// [Fix] Tidak overflow di layar kecil — pakai SingleChildScrollView
// ============================================================

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);

    // Async: simulasi proses login Google
    await UserSession().loginWithGoogle();

    if (!mounted) return;
    setState(() => _isLoading = false);

    // Navigasi ke home menggunakan named route
    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenW = constraints.maxWidth;
          final screenH = constraints.maxHeight;

          final logoSize = (screenW * 0.22).clamp(60.0, 100.0);
          final titleSize = (screenW * 0.10).clamp(26.0, 42.0);
          final subtitleSize = (screenW * 0.038).clamp(12.0, 16.0);
          final btnFontSize = (screenW * 0.042).clamp(13.0, 17.0);
          final hPad = (screenW * 0.07).clamp(20.0, 40.0);
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
                      minHeight: constraints.maxHeight -
                          MediaQuery.of(context).padding.top -
                          MediaQuery.of(context).padding.bottom,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          // ── Bagian atas: logo + teks + tombol ───
                          Padding(
                            padding:
                                EdgeInsets.symmetric(horizontal: hPad),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                    height: (screenH * 0.09).clamp(
                                        24.0, 80.0)),

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
                                      color: const Color(0xFF4FA066),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                    height:
                                        (screenH * 0.018).clamp(8.0, 20.0)),

                                // Nama App
                                Text(
                                  'PlinPlant',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF1A3C34),
                                    fontSize: titleSize,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -1.5,
                                    height: 1.0,
                                  ),
                                ),
                                SizedBox(
                                    height:
                                        (screenH * 0.012).clamp(6.0, 16.0)),

                                Text(
                                  'Selamat datang!',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF1A3C34),
                                    fontSize: (screenW * 0.055)
                                        .clamp(16.0, 24.0),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(
                                    height:
                                        (screenH * 0.005).clamp(4.0, 8.0)),

                                Text(
                                  'Masuk untuk melanjutkan ke aplikasi PlinPlant.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF6B7280),
                                    fontSize: subtitleSize,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                SizedBox(
                                    height:
                                        (screenH * 0.028).clamp(16.0, 36.0)),

                                // ── Tombol Login Google ────────────
                                SizedBox(
                                  width: double.infinity,
                                  height: (screenH * 0.068).clamp(48.0, 62.0),
                                  child: ElevatedButton(
                                    onPressed: _isLoading
                                        ? null
                                        : _handleGoogleLogin,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          const Color(0xFF4E6B50),
                                      foregroundColor: Colors.white,
                                      disabledBackgroundColor: const Color(
                                              0xFF4E6B50)
                                          .withValues(alpha: 0.7),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      elevation: 0,
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
                                                decoration:
                                                    const BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.circle,
                                                ),
                                                padding:
                                                    const EdgeInsets.all(5),
                                                child: Image.network(
                                                  'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/120px-Google_%22G%22_logo.svg.png',
                                                  fit: BoxFit.contain,
                                                  errorBuilder: (_, __,
                                                          ___) =>
                                                      const Icon(
                                                    Icons.g_mobiledata,
                                                    size: 18,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
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
                                ),
                                SizedBox(
                                    height:
                                        (screenH * 0.014).clamp(8.0, 20.0)),
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
                                  height: 120,
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
                              vertical: (screenH * 0.016).clamp(10.0, 22.0),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Dengan melanjutkan, Anda menyetujui',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF9CA3AF),
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
                                          color: Color(0xFF2E7D32),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      TextSpan(
                                        text: ' dan ',
                                        style: TextStyle(
                                            color: Color(0xFF9CA3AF)),
                                      ),
                                      TextSpan(
                                        text: 'Ketentuan Layanan',
                                        style: TextStyle(
                                          color: Color(0xFF2E7D32),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      TextSpan(
                                        text: ' kami.',
                                        style: TextStyle(
                                            color: Color(0xFF9CA3AF)),
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
      ..color = const Color(0xFFDCEAD6)
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