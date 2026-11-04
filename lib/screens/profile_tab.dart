import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../routes.dart';
import '../stores/plant_store.dart';
import '../stores/user_session.dart';
import '../widgets/app_widgets.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = UserSession().currentUser;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.page),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Profil',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.section),
            const Icon(
              Icons.person_rounded,
              color: AppColors.primary,
              size: 72,
            ),
            const SizedBox(height: AppSpacing.item),
            Text(
              user?.name ?? 'Pengguna',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.micro),
            Text(
              user?.email ?? '-',
              style: GoogleFonts.poppins(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.section),
            _ProfileMenuTile(
              icon: Icons.info_outline_rounded,
              title: 'Tentang Aplikasi',
              onTap: () => Navigator.pushNamed(context, AppRoutes.aboutApp),
            ),
            const SizedBox(height: AppSpacing.item),
            _ProfileMenuTile(
              icon: Icons.person_outline_rounded,
              title: 'Informasi Akun',
              onTap: () => Navigator.pushNamed(context, AppRoutes.accountInfo),
            ),
            const SizedBox(height: AppSpacing.section),
            // minimumSize sudah diatur di ElevatedButtonTheme (main.dart)
            ElevatedButton.icon(
              onPressed: () => _showLogoutDialog(context),
              icon: const Icon(Icons.logout_rounded),
              label: Text(
                'Logout',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.dangerBg,
                foregroundColor: AppColors.danger,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.input),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final confirm = await showConfirmDialog(
      context,
      title: 'Keluar dari Akun?',
      message: 'Anda akan keluar dari akun PlinPlant Anda.',
      confirmLabel: 'Keluar',
      icon: Icons.logout_rounded,
    );

    if (confirm != true || !context.mounted) return;
    await UserSession().logout();
    PlantStore().clear();
    if (!context.mounted) return;
    Navigator.of(
      context,
      rootNavigator: true,
    ).pushReplacementNamed(AppRoutes.login);
  }
}

class _ProfileMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ProfileMenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.card),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: AppSpacing.item),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}
