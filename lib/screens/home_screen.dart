import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/plant_store.dart';
import '../providers/user_session.dart';
import '../widgets/app_widgets.dart';
import '../main.dart';
import 'plant_list_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';

// ============================================================
// HOME SCREEN — Dashboard utama dengan bottom navigation
// ============================================================

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTab = 0;
  final PlantStore _store = PlantStore();
  final UserSession _session = UserSession();

  @override
  void initState() {
    super.initState();
    _store.addListener(_refresh);
    _session.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  void _changeTab(int idx) => setState(() => _currentTab = idx);

  @override
  void dispose() {
    _store.removeListener(_refresh);
    _session.removeListener(_refresh);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    final user = _session.currentUser;
    final userName = user?.name.split(' ').first ?? 'Pengguna';

    final tabs = <Widget>[
      _DashboardTab(
        store: _store,
        userName: userName,
        onTabChange: _changeTab,
      ),
      PlantListTab(store: _store),
      HistoryTab(store: _store),
      const ProfileTab(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentTab,
        children: tabs,
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentTab,
        onTap: _changeTab,
      ),
    );
  }
}

// ============================================================
// DASHBOARD TAB
// ============================================================

class _DashboardTab extends StatelessWidget {
  final PlantStore store;
  final String userName;
  final Function(int) onTabChange;

  const _DashboardTab({
    required this.store,
    required this.userName,
    required this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    // [6] Hanya tampilkan tanaman yang Perlu dan Terlambat
    final urgentPlants = store.plants
        .where((p) =>
            p.wateringStatus == 'Perlu' || p.wateringStatus == 'Terlambat')
        .toList();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hai, $userName 🌞',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Selamat datang kembali!',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                // [1] Ikon profil (bukan notifikasi)
                GestureDetector(
                  onTap: () => onTabChange(3),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Icon(
                      Icons.person_outline_rounded,
                      color: AppColors.textSecondary,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Total Tanaman Card ───────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4FA066), Color(0xFF3D8B4A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4FA066).withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Tanaman',
                          style: GoogleFonts.poppins(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${store.totalPlants}',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 44,
                            fontWeight: FontWeight.bold,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Image.asset(
                    'assets/images/gambar_total_tanaman.png',
                    height: 90,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.eco_rounded,
                          color: Colors.white, size: 44),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Status Cards ─────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _StatusCard(
                    title: 'Aman',
                    count: store.amanCount,
                    icon: Icons.check_circle_rounded,
                    iconColor: AppColors.success,
                    bgColor: AppColors.successBg,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatusCard(
                    title: 'Perlu',
                    count: store.perluCount,
                    icon: Icons.opacity_rounded,
                    iconColor: AppColors.warning,
                    bgColor: AppColors.warningBg,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatusCard(
                    title: 'Terlambat',
                    count: store.terlambatCount,
                    icon: Icons.warning_rounded,
                    iconColor: AppColors.danger,
                    bgColor: AppColors.dangerBg,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // [6] Judul: "Perlu Perhatian" bukan "Tanaman Saya"
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Perlu Perhatian',
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                GestureDetector(
                  onTap: () => onTabChange(1),
                  child: Text(
                    'Lihat Semua >',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // [6] Hanya tampilkan Perlu & Terlambat
            if (urgentPlants.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 28),
                decoration: BoxDecoration(
                  color: AppColors.successBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.2)),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        color: AppColors.success, size: 40),
                    const SizedBox(height: 10),
                    Text(
                      'Semua tanaman dalam kondisi baik!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...urgentPlants.take(3).map((plant) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: PlantListCard(
                    name: plant.name,
                    species: plant.species,
                    status: plant.wateringStatus,
                    timeText: plant.wateringTimeText,
                    imagePath: plant.imagePath,
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.plantDetail,
                      arguments: plant.id,
                    ),
                  ),
                );
              }),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

// ── Status Card ───────────────────────────────────────────────

class _StatusCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;

  const _StatusCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: iconColor.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: iconColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$count tanaman',
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
