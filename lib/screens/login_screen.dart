import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
          final screenH = constraints.maxHeight;
          final screenW = constraints.maxWidth;

          // Responsif
          final logoSize = (screenW * 0.22).clamp(70.0, 100.0);
          final titleSize = (screenW * 0.100).clamp(28.0, 42.0);
          final subtitleSize = (screenW * 0.038).clamp(12.0, 16.0);
          final btnFontSize = (screenW * 0.042).clamp(13.5, 17.0);
          final hPad = (screenW * 0.07).clamp(20.0, 40.0);
          final privFontSize = (screenW * 0.028).clamp(10.0, 12.5);

          return Stack(
            children: [
              // =====================================================
              // GELOMBANG HIJAU DI POJOK KANAN ATAS
              // =====================================================
              Positioned(
                top: 0,
                right: 0,
                child: IgnorePointer(
                  child: CustomPaint(
                    size: Size(
                      screenW * 0.78,
                      screenH * 0.40,
                    ),
                    painter: _TopWavePainter(),
                  ),
                ),
              ),

              // =====================================================
              // ISI HALAMAN LOGIN
              // =====================================================
              Column(
                children: [
                  // ── BAGIAN ATAS: logo + teks + tombol ──────────────
                  Expanded(
                    flex: 51,
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: hPad),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: screenH * 0.10),

                            // LOGO
                            Center(
                              child: Image.asset(
                                'assets/icon/plinplant_logo_green.png',
                                width: logoSize,
                                height: logoSize,
                                fit: BoxFit.contain,
                              ),
                            ),

                            SizedBox(height: screenH * 0.020),

                            // NAMA APP
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

                            SizedBox(height: screenH * 0.015),

                            // HEADING
                            Text(
                              'Selamat datang!',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF1A3C34),
                                fontSize:
                                    (screenW * 0.055).clamp(18.0, 24.0),
                                fontWeight: FontWeight.w700,
                              ),
                            ),

                            SizedBox(height: screenH * 0.006),

                            // SUBTITLE
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Masuk untuk melanjutkan ke aplikasi PlinPlant.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF6B7280),
                                  fontSize: subtitleSize,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),

                            SizedBox(height: screenH * 0.030),

                            // =================================================
                            // TOMBOL GOOGLE
                            // =================================================
                            SizedBox(
                              width: double.infinity,
                              height: (screenH * 0.072).clamp(50.0, 62.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (_) => const HomeScreen(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4E6B50),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: Row(
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
                                      padding: const EdgeInsets.all(5),
                                      child: Image.network(
                                        'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/120px-Google_%22G%22_logo.svg.png',
                                        fit: BoxFit.contain,
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

                            SizedBox(height: screenH * 0.015),

                            // =================================================
                            // GARIS PEMBATAS
                            // =================================================
                            Row(
                              children: [
                                const Expanded(
                                  child: Divider(
                                    color: Color(0xFFE5E7EB),
                                    thickness: 1,
                                  ),
                                ),
                                SizedBox(width: screenW * 0.1),
                                const Expanded(
                                  child: Divider(
                                    color: Color(0xFFE5E7EB),
                                    thickness: 1,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ── GAMBAR TANAMAN DI BAGIAN BAWAH ─────────────────
                  Expanded(
                    flex: 40,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          'assets/images/gambar_login.png',
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                        ),
                      ],
                    ),
                  ),

                  // ── TEKS PRIVASI ───────────────────────────────────
                  Container(
                    color: Colors.white,
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: hPad,
                      vertical: screenH * 0.018,
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
                                  color: Color(0xFF9CA3AF),
                                ),
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
                                  color: Color(0xFF9CA3AF),
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

    // Mulai dari pojok kiri atas area gelombang
    path.moveTo(0, 0);

    // Bagian atas
    path.lineTo(size.width, 0);

    // Turun di sisi kanan
    path.lineTo(
      size.width,
      size.height * 0.60,
    );

    // Gelombang utama
    path.cubicTo(
      size.width * 0.92,
      size.height * 0.50,
      size.width * 0.78,
      size.height * 0.45,
      size.width * 0.70,
      size.height * 0.34,
    );

    // Gelombang kedua
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

// ════════════════════════════════════════════════════════════════
// LOGO GOOGLE — putih lingkaran di dalam tombol hijau
// ════════════════════════════════════════════════════════════════

class _GoogleLogoWhiteBg extends StatelessWidget {
  final double size;

  const _GoogleLogoWhiteBg({
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      padding: EdgeInsets.all(size * 0.12),
      child: CustomPaint(
        painter: _GoogleLogoPainter(),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    const colorBlue = Color(0xFF4285F4);
    const colorRed = Color(0xFFEA4335);
    const colorYellow = Color(0xFFFBBC05);
    const colorGreen = Color(0xFF34A853);

    final sw = w * 0.175;

    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = sw
      ..strokeCap = StrokeCap.butt;

    final radius = w * 0.44;
    final cx = w / 2;
    final cy = h / 2;

    final rect = Rect.fromCircle(
      center: Offset(cx, cy),
      radius: radius,
    );

    final deg = math.pi / 180;

    canvas.drawArc(
      rect,
      207 * deg,
      123 * deg,
      false,
      strokePaint..color = colorRed,
    );

    canvas.drawArc(
      rect,
      330 * deg,
      57 * deg,
      false,
      strokePaint..color = colorYellow,
    );

    canvas.drawArc(
      rect,
      27 * deg,
      148 * deg,
      false,
      strokePaint..color = colorGreen,
    );

    canvas.drawArc(
      rect,
      175 * deg,
      32 * deg,
      false,
      strokePaint..color = colorBlue,
    );

    canvas.drawLine(
      Offset(cx, cy),
      Offset(
        cx + radius + sw / 2,
        cy,
      ),
      Paint()
        ..color = colorBlue
        ..style = PaintingStyle.stroke
        ..strokeWidth = sw
        ..strokeCap = StrokeCap.butt,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}