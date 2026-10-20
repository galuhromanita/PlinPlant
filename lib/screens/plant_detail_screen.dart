import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/plant_model.dart';
import '../providers/plant_store.dart';
import '../widgets/app_widgets.dart';
import '../main.dart';

// ============================================================
// PLANT DETAIL SCREEN — Screen #6
// ============================================================

class PlantDetailScreen extends StatefulWidget {
  final String plantId;

  const PlantDetailScreen({super.key, required this.plantId});

  @override
  State<PlantDetailScreen> createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends State<PlantDetailScreen> {
  final PlantStore _store = PlantStore();
  bool _isActionLoading = false;

  @override
  void initState() {
    super.initState();
    _store.addListener(_onStoreChanged);
  }

  void _onStoreChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _store.removeListener(_onStoreChanged);
    super.dispose();
  }

  // ── Aksi Siram (Async) ──────────────────────────────────────

  Future<void> _handleWater(PlantModel plant) async {
    setState(() => _isActionLoading = true);

    await _store.waterPlant(plant.id);

    if (!mounted) return;
    setState(() => _isActionLoading = false);

    // Navigasi ke success screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SuccessActionScreen(
          plantName: plant.name,
          action: 'Disiram',
          icon: Icons.water_drop_rounded,
          plantId: plant.id,
        ),
      ),
    );
  }

  // ── Aksi Pupuk (Async) ──────────────────────────────────────

  Future<void> _handleFertilize(PlantModel plant) async {
    setState(() => _isActionLoading = true);

    await _store.fertilizePlant(plant.id);

    if (!mounted) return;
    setState(() => _isActionLoading = false);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SuccessActionScreen(
          plantName: plant.name,
          action: 'Dipupuk',
          icon: Icons.eco_rounded,
          plantId: plant.id,
        ),
      ),
    );
  }

  // ── Aksi Hapus (Async + Konfirmasi) ──────────────────────────

  Future<void> _handleDelete(PlantModel plant) async {
    final confirm = await showDeleteConfirmDialog(context, plant.name);
    if (confirm != true) return;

    setState(() => _isActionLoading = true);
    await _store.deletePlant(plant.id);

    if (!mounted) return;
    setState(() => _isActionLoading = false);

    Navigator.pop(context);
    showSuccessPopup(
      context,
      title: 'Berhasil Menghapus Tanaman!',
      message: 'Tanaman ${plant.name} telah dihapus dari daftar.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final plant = _store.getById(widget.plantId);

    if (plant == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Tanaman')),
        body: const Center(child: Text('Tanaman tidak ditemukan')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final heroH = (w * 0.7).clamp(220.0, 340.0);
          final hPad = (w * 0.055).clamp(16.0, 28.0);
          final titleSize = (w * 0.06).clamp(18.0, 26.0);
          final subSize = (w * 0.04).clamp(13.0, 17.0);
          return Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                // ── Gambar & AppBar Overlay ─────────────────────
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: heroH,
                      color: AppColors.primaryBg,
                      child: plant.imagePath != null
                          ? Image.asset(plant.imagePath!, fit: BoxFit.cover)
                          : Icon(
                              Icons.eco_rounded,
                              size: (w * 0.25).clamp(64.0, 120.0),
                              color: AppColors.primary.withValues(alpha: 0.5),
                            ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            // Hanya tombol back — titik 3 dihapus karena
                            // tombol Edit & Hapus sudah ada di bawah
                            CircleAvatar(
                              backgroundColor:
                                  Colors.white.withValues(alpha: 0.85),
                              child: IconButton(
                                icon: const Icon(Icons.arrow_back,
                                    color: AppColors.textPrimary),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // ── Info Tanaman ────────────────────────────────
                Padding(
                  padding: EdgeInsets.fromLTRB(hPad, hPad, hPad, hPad),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plant.name,
                        style: GoogleFonts.poppins(
                          fontSize: titleSize,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        plant.species,
                        style: GoogleFonts.poppins(
                          fontSize: subSize,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      StatusBadge(status: plant.wateringStatus),
                      const SizedBox(height: 24),

                      // Info Cards
                      Row(
                        children: [
                          Expanded(
                            child: _InfoCard(
                              icon: Icons.opacity_rounded,
                              title: 'Interval Siram',
                              value:
                                  '${plant.wateringIntervalDays} hari',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _InfoCard(
                              icon: Icons.calendar_today_rounded,
                              title: 'Terakhir Disiram',
                              value: plant.lastWatered != null
                                  ? DateFormat('dd MMM yyyy')
                                      .format(plant.lastWatered!)
                                  : '-',
                            ),
                          ),
                        ],
                      ),

                      // Info pupuk (jika aktif)
                      if (plant.fertilizerEnabled) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _InfoCard(
                                icon: Icons.eco_outlined,
                                title: 'Interval Pupuk',
                                value:
                                    '${plant.fertilizerIntervalDays} hari',
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _InfoCard(
                                icon: Icons.calendar_today_rounded,
                                title: 'Terakhir Dipupuk',
                                value: plant.lastFertilized != null
                                    ? DateFormat('dd MMM yyyy')
                                        .format(plant.lastFertilized!)
                                    : '-',
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 32),

                      // ── Tombol Aksi ─────────────────────────────
                      // [7] Disabled jika status masih Aman
                      _ActionButton(
                        label: 'Sudah Disiram',
                        icon: Icons.water_drop_outlined,
                        isEnabled: !_isActionLoading &&
                            plant.wateringStatus != 'Aman',
                        disabledMessage:
                            plant.wateringStatus == 'Aman'
                                ? 'Tanaman masih aman, belum perlu disiram'
                                : null,
                        isPrimary: true,
                        onPressed: () => _handleWater(plant),
                      ),
                      const SizedBox(height: 12),
                      // [6] Disabled dengan pesan jika pupuk tidak aktif
                      _ActionButton(
                        label: 'Sudah Dipupuk',
                        icon: Icons.eco_outlined,
                        isEnabled: !_isActionLoading &&
                            plant.fertilizerEnabled,
                        disabledMessage: !plant.fertilizerEnabled
                            ? 'Anda tidak mengaktifkan pupuk'
                            : null,
                        isPrimary: false,
                        onPressed: () => _handleFertilize(plant),
                      ),
                      const SizedBox(height: 32),

                      // ── Edit & Hapus ────────────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: OutlineButton(
                              label: 'Edit',
                              icon: Icons.edit_outlined,
                              onPressed: () => Navigator.pushNamed(
                                context,
                                AppRoutes.editPlant,
                                arguments: plant,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 52,
                              child: ElevatedButton.icon(
                                onPressed: _isActionLoading
                                    ? null
                                    : () => _handleDelete(plant),
                                icon: const Icon(Icons.delete_outline),
                                label: Text(
                                  'Hapus',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppColors.danger,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    side: const BorderSide(
                                      color: AppColors.danger,
                                      width: 1.5,
                                    ),
                                  ),
                                  elevation: 0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Loading overlay ────────────────────────────────────
          if (_isActionLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
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

// ── Info Card kecil ───────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: AppColors.textHint,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
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

// ── Action Button dengan disabled state & pesan ───────────────
// [6] & [7] Tombol aksi yang bisa di-disable dengan keterangan

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isEnabled;
  final String? disabledMessage;
  final bool isPrimary;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.isEnabled,
    required this.isPrimary,
    required this.onPressed,
    this.disabledMessage,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = isPrimary ? AppColors.primary : AppColors.primary;
    final disabledColor = AppColors.textHint;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 52,
          child: ElevatedButton.icon(
            onPressed: isEnabled ? onPressed : null,
            icon: Icon(
              icon,
              size: 20,
              color: isEnabled
                  ? Colors.white
                  : (isPrimary ? disabledColor : disabledColor),
            ),
            label: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: isPrimary
                ? ElevatedButton.styleFrom(
                    backgroundColor:
                        isEnabled ? baseColor : const Color(0xFFE5E7EB),
                    foregroundColor:
                        isEnabled ? Colors.white : disabledColor,
                    disabledBackgroundColor: const Color(0xFFE5E7EB),
                    disabledForegroundColor: disabledColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  )
                : ElevatedButton.styleFrom(
                    backgroundColor:
                        isEnabled ? Colors.white : const Color(0xFFF9FAFB),
                    foregroundColor:
                        isEnabled ? baseColor : disabledColor,
                    disabledBackgroundColor: const Color(0xFFF9FAFB),
                    disabledForegroundColor: disabledColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color: isEnabled
                            ? baseColor
                            : const Color(0xFFE5E7EB),
                        width: 1.5,
                      ),
                    ),
                    elevation: 0,
                  ),
          ),
        ),
        // Tampilkan pesan jika disabled
        if (!isEnabled && disabledMessage != null) ...[
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.info_outline_rounded,
                  size: 13, color: AppColors.textHint),
              const SizedBox(width: 5),
              Text(
                disabledMessage!,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppColors.textHint,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}



// ============================================================
// SUCCESS ACTION SCREEN — Screen #7 & #8
// Halaman setelah "Sudah Disiram" / "Sudah Dipupuk"
// ============================================================

class SuccessActionScreen extends StatelessWidget {
  final String plantName;
  final String action; // "Disiram" | "Dipupuk"
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
          padding: const EdgeInsets.all(24),
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
              const SizedBox(height: 32),
              Text(
                'Tanaman Sudah $action!',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '$plantName\nberhasil ${action.toLowerCase()} pada hari ini.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const Spacer(),
              PrimaryButton(
                label: 'Lihat Detail Tanaman',
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 16),
              OutlineButton(
                label: 'Kembali ke Daftar',
                onPressed: () =>
                    Navigator.popUntil(context, (route) => route.isFirst),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
