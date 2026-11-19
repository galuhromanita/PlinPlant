import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../models/plant_model.dart';
import '../models/plant_status.dart';
import '../stores/plant_store.dart';
import '../widgets/app_widgets.dart';
import '../routes.dart';

class PlantDetailScreen extends StatefulWidget {
  final String plantId;

  const PlantDetailScreen({super.key, required this.plantId});

  @override
  State<PlantDetailScreen> createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends State<PlantDetailScreen> {
  final PlantStore _store = PlantStore();
  bool _isActionLoading = false;
  bool _isDeleting = false;

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
    Navigator.pushNamed(
      context,
      AppRoutes.successAction,
      arguments: SuccessActionArguments(
        plantName: plant.name,
        action: 'Disiram',
        icon: Icons.water_drop_rounded,
        plantId: plant.id,
      ),
    );
  }

  // ── Aksi Pupuk (Async) ──────────────────────────────────────

  Future<void> _handleFertilize(PlantModel plant) async {
    setState(() => _isActionLoading = true);

    await _store.fertilizePlant(plant.id);

    if (!mounted) return;
    setState(() => _isActionLoading = false);

    Navigator.pushNamed(
      context,
      AppRoutes.successAction,
      arguments: SuccessActionArguments(
        plantName: plant.name,
        action: 'Dipupuk',
        icon: Icons.eco_rounded,
        plantId: plant.id,
      ),
    );
  }

  // ── Aksi Hapus (Async + Konfirmasi) ──────────────────────────

  Future<void> _handleDelete(PlantModel plant) async {
    final confirm = await showDeleteConfirmDialog(context, plant.name);
    if (confirm != true) return;

    _isDeleting = true;
    setState(() => _isActionLoading = true);
    await _store.deletePlant(plant.id);

    if (!mounted) return;
    setState(() => _isActionLoading = false);

    Navigator.pop(context, PlantDetailResult.deleted);
  }

  @override
  Widget build(BuildContext context) {
    final plant = _store.getById(widget.plantId);

    if (plant == null) {
      if (_isDeleting) {
        return const Scaffold(backgroundColor: Colors.white);
      }
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
                          child: plant.imagePath != null &&
                                  plant.imagePath!.isNotEmpty
                              ? Image.network(
                                  plant.imagePath!,
                                  key: ValueKey(plant.imagePath),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: heroH,
                                  loadingBuilder: (_, child, progress) =>
                                      progress == null
                                          ? child
                                          : const Center(
                                              child: CircularProgressIndicator(
                                                color: AppColors.primary,
                                              ),
                                            ),
                                  errorBuilder: (ctx, err, stack) => Icon(
                                    Icons.eco_rounded,
                                    size: (w * 0.25).clamp(64.0, 120.0),
                                    color: AppColors.primary.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                )
                              : Icon(
                                  Icons.eco_rounded,
                                  size: (w * 0.25).clamp(64.0, 120.0),
                                  color: AppColors.primary.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                        ),
                        SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.item),
                            child: Row(
                              children: [
                                // Hanya tombol back — titik 3 dihapus karena
                                // tombol Edit & Hapus sudah ada di bawah
                                CircleAvatar(
                                  backgroundColor: Colors.white.withValues(
                                    alpha: 0.85,
                                  ),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.arrow_back,
                                      color: AppColors.textPrimary,
                                    ),
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
                      padding: const EdgeInsets.all(AppSpacing.page),
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
                          const SizedBox(height: AppSpacing.micro),
                          StatusBadge(status: plant.overallStatus),
                          const SizedBox(height: AppSpacing.section),

                          // Info Cards
                          Row(
                            children: [
                              Expanded(
                                child: _InfoCard(
                                  icon: Icons.opacity_rounded,
                                  title: 'Interval Siram',
                                  value: '${plant.wateringIntervalDays} hari',
                                ),
                              ),
                              const SizedBox(width: AppSpacing.item),
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
                            const SizedBox(height: AppSpacing.item),
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
                                const SizedBox(width: AppSpacing.item),
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
                          const SizedBox(height: AppSpacing.section),

                          // ── Tombol Aksi ─────────────────────────────
                          // Nonaktif jika tanaman belum perlu disiram.
                          _ActionButton(
                            label: 'Sudah Disiram',
                            icon: Icons.water_drop_outlined,
                            isEnabled:
                                !_isActionLoading &&
                                plant.wateringStatus != PlantStatus.safe,
                            disabledMessage:
                                plant.wateringStatus == PlantStatus.safe
                                ? 'Tanaman masih aman, belum perlu disiram'
                                : null,
                            isPrimary: true,
                            onPressed: () => _handleWater(plant),
                          ),
                          if (plant.fertilizerEnabled) ...[
                            const SizedBox(height: AppSpacing.item),
                            _ActionButton(
                              label: 'Sudah Dipupuk',
                              icon: Icons.eco_outlined,
                              isEnabled:
                                  !_isActionLoading && plant.canFertilize,
                              disabledMessage: plant.canFertilize
                                  ? null
                                  : 'Pupuk ${plant.fertilizerTimeText}',
                              isPrimary: false,
                              onPressed: () => _handleFertilize(plant),
                            ),
                            const SizedBox(height: AppSpacing.section),
                          ] else
                            const SizedBox(height: AppSpacing.section),

                          // ── Edit & Hapus ────────────────────────────
                          Row(
                            children: [
                              Expanded(
                                child: SecondaryButton(
                                  label: 'Edit',
                                  icon: Icons.edit_outlined,
                                  onPressed: () async {
                                    final result = await Navigator.pushNamed(
                                      context,
                                      AppRoutes.editPlant,
                                      arguments: plant,
                                    );
                                    if (result == true && context.mounted) {
                                      showSuccessPopup(
                                        context,
                                        title: 'Berhasil Mengedit Tanaman!',
                                        message:
                                            'Data tanaman ${plant.name} telah diperbarui.',
                                      );
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: AppSpacing.item),
                              Expanded(
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
                                      borderRadius: BorderRadius.circular(
                                        AppRadius.input,
                                      ),
                                      side: const BorderSide(
                                        color: AppColors.danger,
                                        width: 1.5,
                                      ),
                                    ),
                                    elevation: 0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.section),
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
                    child: CircularProgressIndicator(color: AppColors.primary),
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
      padding: const EdgeInsets.all(AppSpacing.card),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: AppSpacing.item),
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
                const SizedBox(height: AppSpacing.micro),
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
// Tombol aksi yang bisa dinonaktifkan dengan keterangan.

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
    final baseColor = AppColors.primary;
    final disabledColor = AppColors.textHint;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: isEnabled ? onPressed : null,
          icon: Icon(
            icon,
            size: 20,
            color: isEnabled ? Colors.white : disabledColor,
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
                  backgroundColor: isEnabled ? baseColor : AppColors.disabled,
                  foregroundColor: isEnabled ? Colors.white : disabledColor,
                  disabledBackgroundColor: AppColors.disabled,
                  disabledForegroundColor: disabledColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.input),
                  ),
                  elevation: 0,
                )
              : ElevatedButton.styleFrom(
                  backgroundColor: isEnabled
                      ? Colors.white
                      : AppColors.disabledBg,
                  foregroundColor: isEnabled ? baseColor : disabledColor,
                  disabledBackgroundColor: AppColors.disabledBg,
                  disabledForegroundColor: disabledColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.input),
                    side: BorderSide(
                      color: isEnabled ? baseColor : AppColors.disabled,
                      width: 1.5,
                    ),
                  ),
                  elevation: 0,
                ),
        ),
        // Tampilkan pesan jika disabled
        if (!isEnabled && disabledMessage != null) ...[
          const SizedBox(height: AppSpacing.item),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.info_outline_rounded,
                size: 13,
                color: AppColors.textHint,
              ),
              const SizedBox(width: AppSpacing.tight),
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
