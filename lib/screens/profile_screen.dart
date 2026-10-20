import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/user_session.dart';
import '../widgets/app_widgets.dart';
import '../main.dart';

// ============================================================
// PROFILE SCREEN — Tab Profil (Screen #11)
// [5] Responsive layout
// ============================================================

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final session = UserSession();
    final user = session.currentUser;
    final w = MediaQuery.of(context).size.width;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: w < 400 ? 16 : 20,
          vertical: 20,
        ),
        child: Column(
          children: [
            // ── Header ────────────────────────────────────────────
            Row(
              children: [
                Text(
                  'Profil',
                  style: GoogleFonts.poppins(
                    fontSize: w < 360 ? 18 : 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // ── Avatar & Info ──────────────────────────────────────
            Center(
              child: Column(
                children: [
                  Container(
                    width: w < 400 ? 80 : 100,
                    height: w < 400 ? 80 : 100,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBg,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.person_rounded,
                      size: w < 400 ? 40 : 50,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    user?.name ?? 'Pengguna',
                    style: GoogleFonts.poppins(
                      fontSize: w < 360 ? 16 : 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    user?.email ?? '-',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ── Menu Items ─────────────────────────────────────────
            _ProfileMenuTile(
              icon: Icons.info_outline_rounded,
              title: 'Tentang Aplikasi',
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.aboutApp),
            ),
            const SizedBox(height: 14),
            _ProfileMenuTile(
              icon: Icons.person_outline_rounded,
              title: 'Informasi Akun',
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.accountInfo),
            ),
            const SizedBox(height: 40),

            // ── Tombol Logout ──────────────────────────────────────
            SizedBox(
              height: 52,
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showLogoutDialog(context),
                icon: const Icon(Icons.logout_rounded),
                label: Text(
                  'Logout',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.dangerBg,
                  foregroundColor: AppColors.danger,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: AppColors.dangerBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.logout_rounded,
                    color: AppColors.danger, size: 32),
              ),
              const SizedBox(height: 16),
              Text(
                'Keluar dari Akun?',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Anda akan keluar dari akun PlinPlant Anda.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlineButton(
                      label: 'Batal',
                      onPressed: () => Navigator.pop(context, false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.danger,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Keluar',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirm == true && context.mounted) {
      await UserSession().logout();
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true)
            .pushReplacementNamed(AppRoutes.login);
      }
    }
  }
}

// ── Profile Menu Tile ──────────────────────────────────────────

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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// ABOUT APP SCREEN — [3] Tampilan lebih menarik & engaging
// ============================================================

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  static const String _appVersion = '1.0.0';

  static const List<Map<String, dynamic>> _features = [
    {
      'icon': Icons.water_drop_rounded,
      'color': Color(0xFF2196F3),
      'bg': Color(0xFFE3F2FD),
      'title': 'Pengingat Penyiraman',
      'desc':
          'Pantau jadwal siram tanaman dan dapatkan notifikasi tepat waktu.',
    },
    {
      'icon': Icons.eco_rounded,
      'color': Color(0xFF4CAF50),
      'bg': Color(0xFFE8F5E9),
      'title': 'Manajemen Pupuk',
      'desc':
          'Atur jadwal pemupukan dan catat riwayat nutrisi tanaman Anda.',
    },
    {
      'icon': Icons.history_rounded,
      'color': Color(0xFFFF9800),
      'bg': Color(0xFFFFF3E0),
      'title': 'Riwayat Perawatan',
      'desc':
          'Lihat seluruh aktivitas perawatan tanaman Anda secara lengkap.',
    },
    {
      'icon': Icons.dashboard_rounded,
      'color': Color(0xFF9C27B0),
      'bg': Color(0xFFF3E5F5),
      'title': 'Dashboard Cerdas',
      'desc': 'Pantau status seluruh tanaman dari satu layar utama.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final hPad = w < 400 ? 16.0 : 20.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── SliverAppBar Hijau Gradient ───────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF4FA066), Color(0xFF2E6B38)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  Positioned(
                    top: -40,
                    right: -40,
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -30,
                    left: -30,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 28),
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Image.asset(
                            'assets/icon/plinplant_logo_white.png',
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) => const Icon(
                              Icons.eco_rounded,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'PlinPlant',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Rawat Tanaman, Nikmati Kehidupan Hijau',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: hPad, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Badge versi ─────────────────────────────
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        '⚡  Versi $_appVersion — Terbaru',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Tentang ─────────────────────────────────
                  Text(
                    'Tentang PlinPlant',
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'PlinPlant hadir sebagai teman setia dalam merawat '
                    'tanaman Anda. Dengan tampilan yang sederhana namun '
                    'penuh fitur, PlinPlant membantu Anda tidak pernah '
                    'lupa menyiram atau memupuk tanaman kesayangan.',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.7,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Fitur Unggulan ───────────────────────────
                  Text(
                    'Fitur Unggulan',
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Grid 2 kolom
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: _features.length,
                    itemBuilder: (context, i) {
                      final f = _features[i];
                      return _FeatureCard(
                        icon: f['icon'] as IconData,
                        iconColor: f['color'] as Color,
                        bgColor: f['bg'] as Color,
                        title: f['title'] as String,
                        desc: f['desc'] as String,
                      );
                    },
                  ),
                  const SizedBox(height: 28),

                  // ── Kutipan motivasi ─────────────────────────
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBg,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Text('🌱', style: TextStyle(fontSize: 32)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                '"Rawat satu tanaman,\nsirami seribu ketenangan."',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontStyle: FontStyle.italic,
                                  color: AppColors.primaryDark,
                                  fontWeight: FontWeight.w600,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Footer card ──────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4FA066), Color(0xFF2E6B38)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Dibuat dengan 💚',
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'PlinPlant © 2025\nSemua Hak Dilindungi',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.8),
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.eco_rounded,
                            color: Colors.white, size: 48),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Feature Card ───────────────────────────────────────────────

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String title;
  final String desc;

  const _FeatureCard({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              desc,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ACCOUNT INFO SCREEN — [2] Hanya nama & email
// ============================================================

class AccountInfoScreen extends StatelessWidget {
  const AccountInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = UserSession().currentUser;
    final w = MediaQuery.of(context).size.width;
    final hPad = w < 400 ? 16.0 : 20.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Informasi Akun',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(hPad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Avatar ──────────────────────────────────────────
            Center(
              child: Column(
                children: [
                  Container(
                    width: w < 400 ? 80 : 100,
                    height: w < 400 ? 80 : 100,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBg,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.person_rounded,
                      size: w < 400 ? 40 : 50,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.name ?? '-',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // [2] Hanya Nama Lengkap & Email saja
            _AccountInfoTile(
              label: 'Nama Lengkap',
              value: user?.name ?? '-',
              icon: Icons.person_outline_rounded,
            ),
            const SizedBox(height: 12),
            _AccountInfoTile(
              label: 'Email',
              value: user?.email ?? '-',
              icon: Icons.email_outlined,
            ),
            const SizedBox(height: 28),

            // ── Info note ──────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primaryBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: AppColors.primary, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Informasi akun dikelola oleh Google. '
                      'Untuk mengubah profil, kunjungi pengaturan akun Google Anda.',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.primary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Account Info Tile ──────────────────────────────────────────

class _AccountInfoTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _AccountInfoTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.textHint,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
