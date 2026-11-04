import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/app_widgets.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tentang Aplikasi')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.page),
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.stretch
            children: [
              const SizedBox(height: AppSpacing.item),
              Image.asset(
                'assets/icon/plinplant_logo_green.png',
                height: 120,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: AppSpacing.item),
              Text(
                'PlinPlant',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 38,
                  fontWeight: FontWeight.w800,
                  color: AppColors.loginText,
                ),
              ),
              const SizedBox(height: AppSpacing.item),
              Text(
                'Rawat Tanaman,\nNikmati Kehidupan yang Lebih Hijau',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: AppColors.primaryDark,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppSpacing.item),
              Container(
                padding: const EdgeInsets.all(AppSpacing.card),
                decoration: BoxDecoration(
                  color: AppColors.primaryBg,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Image.asset(
                        'assets/images/gambar_login.png',
                        height: 110,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.item),
                    Expanded(
                      flex: 3,
                      child: Text(
                        'PlinPlant membantu Anda merawat tanaman dengan lebih mudah, praktis, dan menyenangkan.',
                        textAlign: TextAlign.justify,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.primaryDark,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.item),
              const _AboutFeature(
                icon: Icons.eco_outlined,
                title: 'Pengingat Perawatan',
                description:
                    'Pantau jadwal siram dan pupuk tanaman sesuai kebutuhan.',
              ),
              const SizedBox(height: AppSpacing.item),
              const _AboutFeature(
                icon: Icons.description_outlined,
                title: 'Catatan Tanaman',
                description: 'Simpan informasi tanaman seperti nama, jenis, dan tanggal perawatan.',
              ),
              const SizedBox(height: AppSpacing.item),
              const _AboutFeature(
                icon: Icons.local_florist_outlined,
                title: 'Perawatan Lebih Teratur',
                description: 'Pantau perkembangan tanaman dan jaga kesehatannya dengan lebih mudah.',
              ),
              const SizedBox(height: AppSpacing.section),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.item,
                    vertical: AppSpacing.tight,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBg,
                    borderRadius: BorderRadius.circular(AppRadius.input),
                  ),
                  child: Text(
                    'Versi 1.0.0',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.item),
              Text(
                'Dibuat dengan 🌱 untuk pecinta tanaman',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AboutFeature extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _AboutFeature({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.primaryBg,
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: Icon(icon, color: AppColors.primaryDark, size: 32),
        ),
        const SizedBox(width: AppSpacing.item),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: AppSpacing.micro),
              Text(
                description,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
