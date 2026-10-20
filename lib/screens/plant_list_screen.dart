import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/plant_store.dart';
import '../widgets/app_widgets.dart';
import '../main.dart';

// ============================================================
// PLANT LIST SCREEN — Tab Tanaman (Screen #4)
// ============================================================

class PlantListTab extends StatefulWidget {
  final PlantStore store;

  const PlantListTab({super.key, required this.store});

  @override
  State<PlantListTab> createState() => _PlantListTabState();
}

class _PlantListTabState extends State<PlantListTab> {
  String _searchQuery = '';
  String _filterStatus = 'Semua'; // Semua | Aman | Perlu | Terlambat

  final List<String> _filterOptions = ['Semua', 'Aman', 'Perlu', 'Terlambat'];

  List _getFilteredPlants() {
    return widget.store.plants.where((p) {
      final matchSearch =
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              p.species.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchFilter =
          _filterStatus == 'Semua' || p.wateringStatus == _filterStatus;
      return matchSearch && matchFilter;
    }).toList();
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter Status',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              ..._filterOptions.map((option) {
                final isSelected = _filterStatus == option;
                return ListTile(
                  onTap: () {
                    setState(() => _filterStatus = option);
                    Navigator.pop(context);
                  },
                  title: Text(
                    option,
                    style: GoogleFonts.poppins(
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_rounded,
                          color: AppColors.primary)
                      : null,
                  contentPadding: EdgeInsets.zero,
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredPlants = _getFilteredPlants();

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            Navigator.pushNamed(context, AppRoutes.addPlant),
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tanaman Saya',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),

              // ── Search & Filter Row ──────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: TextField(
                        onChanged: (val) =>
                            setState(() => _searchQuery = val),
                        style: GoogleFonts.poppins(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Cari tanaman...',
                          hintStyle: GoogleFonts.poppins(
                            color: AppColors.textHint,
                            fontSize: 14,
                          ),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: AppColors.textHint,
                          ),
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => _showFilterSheet(context),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _filterStatus != 'Semua'
                            ? AppColors.primaryBg
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _filterStatus != 'Semua'
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                      ),
                      child: Icon(
                        Icons.filter_list_rounded,
                        color: _filterStatus != 'Semua'
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Filter chip aktif ─────────────────────────────
              if (_filterStatus != 'Semua') ...[
                Row(
                  children: [
                    FilterChip(
                      label: Text(
                        _filterStatus,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      selected: true,
                      selectedColor: AppColors.primaryBg,
                      checkmarkColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      onSelected: (_) =>
                          setState(() => _filterStatus = 'Semua'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],

              // ── Daftar tanaman ────────────────────────────────
              Expanded(
                child: filteredPlants.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.eco_outlined,
                              size: 64,
                              color: AppColors.textHint.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isNotEmpty
                                  ? 'Tanaman tidak ditemukan.'
                                  : 'Belum ada tanaman.\nTekan + untuk menambahkan.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                color: AppColors.textSecondary,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: filteredPlants.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final plant = filteredPlants[index];
                          return PlantListCard(
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
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
