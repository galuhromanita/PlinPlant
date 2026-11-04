import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/app_widgets.dart';

class SuccessActionScreen extends StatelessWidget {
  final String plantName;
  final String action;
  final IconData icon;
  final String plantId;

  const SuccessActionScreen({
    super.key,
    required this.plantName,
    required this.action,
    required this.icon,
    required this.plantId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.page),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: AppColors.primaryBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primary, size: 64),
              ),
              const SizedBox(height: AppSpacing.item),
              Text(
                'Tanaman Sudah $action!',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.item),
              Text(
                '$plantName\nberhasil ${action.toLowerCase()} pada hari ini.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              PrimaryButton(
                label: 'Lihat Detail Tanaman',
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: AppSpacing.section),
              SecondaryButton(
                label: 'Kembali ke Daftar',
                onPressed: () =>
                    Navigator.popUntil(context, (route) => route.isFirst),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
