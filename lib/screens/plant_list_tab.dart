import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/plant_model.dart';
import '../models/plant_status.dart';
import '../routes.dart';
import '../stores/plant_store.dart';
import '../widgets/app_widgets.dart';

class PlantListTab extends StatefulWidget {
  final PlantStore store;

  const PlantListTab({super.key, required this.store});

  @override
  State<PlantListTab> createState() => _PlantListTabState();
}

class _PlantListTabState extends State<PlantListTab> {
  String _searchQuery = '';
  PlantStatus? _filterStatus;

  List<PlantModel> _getFilteredPlants() {
    return widget.store.plants.where((plant) {
      final matchSearch =
          plant.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          plant.species.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchFilter =
          _filterStatus == null || plant.overallStatus == _filterStatus;
      return matchSearch && matchFilter;
    }).toList();
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.card),
        ),
      ),
      builder: (sheetContext) {
        final filterOptions = <PlantStatus?>[null, ...PlantStatus.values];
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.page),
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
              const SizedBox(height: AppSpacing.item),
              ...filterOptions.map((option) {
                final isSelected = _filterStatus == option;
                return ListTile(
                  onTap: () {
                    setState(() => _filterStatus = option);
                    Navigator.pop(sheetContext);
                  },
                  title: Text(
                    option?.label ?? 'Semua',
                    style: GoogleFonts.poppins(
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(
                          Icons.check_rounded,
                          color: AppColors.primary,
                        )
                      : null,
                  contentPadding: EdgeInsets.zero,
                );
              }),
              const SizedBox(height: AppSpacing.item),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openDetail(PlantModel plant) async {
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.plantDetail,
      arguments: plant.id,
    );
    if (!mounted || result == null) return;

    final message = result == PlantDetailResult.deleted
        ? 'Tanaman ${plant.name} berhasil dihapus.'
        : 'Data tanaman ${plant.name} berhasil diperbarui.';
    showSuccessPopup(
      context,
      title: result == PlantDetailResult.deleted
          ? 'Tanaman Berhasil Dihapus!'
          : 'Perubahan Tanaman Berhasil!',
      message: message,
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredPlants = _getFilteredPlants();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.page),
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
            const SizedBox(height: AppSpacing.section),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: TextField(
                      onChanged: (value) =>
                          setState(() => _searchQuery = value),
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
                        contentPadding: const EdgeInsets.all(AppSpacing.card),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.item),
                GestureDetector(
                  onTap: () => _showFilterSheet(context),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _filterStatus != null
                          ? AppColors.primaryBg
                          : Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      border: Border.all(
                        color: _filterStatus != null
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                    ),
                    child: Icon(
                      Icons.filter_list_rounded,
                      color: _filterStatus != null
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.section),
            if (_filterStatus != null) ...[
              FilterChip(
                label: Text(
                  _filterStatus!.label,
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
                onSelected: (_) => setState(() => _filterStatus = null),
              ),
              const SizedBox(height: AppSpacing.item),
            ],
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
                          const SizedBox(height: AppSpacing.section),
                          Text(
                            _searchQuery.isNotEmpty || _filterStatus != null
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
                      padding: const EdgeInsets.only(
                        bottom: AppSpacing.fabClearance,
                      ),
                      itemCount: filteredPlants.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.item),
                      itemBuilder: (context, index) {
                        final plant = filteredPlants[index];
                        return PlantListCard(
                          name: plant.name,
                          species: plant.species,
                          status: plant.overallStatus,
                          timeText: plant.nextCareText,
                          imagePath: plant.imagePath,
                          onTap: () => _openDetail(plant),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
