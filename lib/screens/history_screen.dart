import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/care_history_model.dart';
import '../providers/plant_store.dart';
import '../widgets/app_widgets.dart';

// ============================================================
// HISTORY SCREEN — Tab Riwayat
// [4] Sorting tabs: Semua / Penyiraman / Pemupukan
// ============================================================

class HistoryTab extends StatefulWidget {
  final PlantStore store;

  const HistoryTab({super.key, required this.store});

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  int _selectedFilter = 0; // 0=Semua, 1=Penyiraman, 2=Pemupukan

  static const List<String> _filterLabels = [
    'Semua',
    'Penyiraman',
    'Pemupukan',
  ];

  List<CareHistory> get _filtered {
    final all = widget.store.histories;
    switch (_selectedFilter) {
      case 1:
        return all.where((h) => h.careType == CareType.watering).toList();
      case 2:
        return all.where((h) => h.careType == CareType.fertilizing).toList();
      default:
        return all;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final w = MediaQuery.of(context).size.width;
    final hPad = w < 400 ? 16.0 : 20.0;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──────────────────────────────────────
                Text(
                  'Riwayat Perawatan',
                  style: GoogleFonts.poppins(
                    fontSize: w < 360 ? 18 : 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Aktivitas perawatan tanaman Anda',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),

                // [4] Filter Tabs — persis seperti gambar referensi
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: List.generate(_filterLabels.length, (i) {
                      final isActive = _selectedFilter == i;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedFilter = i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? AppColors.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: isActive
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primary
                                            .withValues(alpha: 0.25),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      )
                                    ]
                                  : [],
                            ),
                            child: Text(
                              _filterLabels[i],
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: w < 360 ? 11 : 13,
                                fontWeight: isActive
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isActive
                                    ? Colors.white
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // ── Daftar Riwayat ───────────────────────────────────
          Expanded(
            child: filtered.isEmpty
                ? _EmptyHistoryWidget(
                    label: _filterLabels[_selectedFilter])
                : ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: hPad),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) =>
                        _HistoryCard(history: filtered[index]),
                  ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

// ── Kartu Riwayat ─────────────────────────────────────────────

class _HistoryCard extends StatelessWidget {
  final CareHistory history;

  const _HistoryCard({required this.history});

  @override
  Widget build(BuildContext context) {
    final isWatering = history.careType == CareType.watering;
    final color = isWatering ? AppColors.primary : const Color(0xFF8BC34A);
    final bgColor =
        isWatering ? AppColors.primaryBg : const Color(0xFFF1F8E9);
    final icon = isWatering ? Icons.water_drop_rounded : Icons.eco_rounded;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  history.plantName,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  history.careTypeLabel,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                DateFormat('dd MMM yyyy').format(history.performedAt),
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppColors.textHint,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                DateFormat('HH:mm').format(history.performedAt),
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppColors.textHint,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Widget Kosong ──────────────────────────────────────────────

class _EmptyHistoryWidget extends StatelessWidget {
  final String label;

  const _EmptyHistoryWidget({required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_rounded,
            size: 72,
            color: AppColors.textHint.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada riwayat',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label == 'Semua'
                ? 'Aktivitas penyiraman dan pemupukan\nakan muncul di sini.'
                : 'Belum ada riwayat $label.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.textHint,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
