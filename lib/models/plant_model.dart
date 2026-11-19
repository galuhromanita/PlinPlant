// ============================================================
// MODEL DATA TANAMAN — disesuaikan dengan kolom tabel `tanaman`
// ============================================================

import 'dart:math';

import 'plant_status.dart';

class PlantModel {
  final String id; // id_tanaman (BIGINT → String)
  String name; // nama_tanaman
  String species; // jenis_tanaman
  String? imagePath; // foto_url
  int wateringIntervalDays; // interval_siram
  DateTime? lastWatered; // terakhir_siram
  bool fertilizerEnabled; // aktif_pupuk
  int fertilizerIntervalDays; // interval_pupuk
  DateTime? lastFertilized; // terakhir_pupuk

  PlantModel({
    required this.id,
    required this.name,
    required this.species,
    this.imagePath,
    this.wateringIntervalDays = 3,
    this.lastWatered,
    this.fertilizerEnabled = false,
    this.fertilizerIntervalDays = 7,
    this.lastFertilized,
  });

  // ── Konversi dari baris Supabase (tabel `tanaman`) ───────────
  factory PlantModel.fromMap(Map<String, dynamic> map) {
    return PlantModel(
      // id_tanaman adalah BIGINT, dikonversi ke String
      id: map['id_tanaman'].toString(),
      name: map['nama_tanaman'] as String,
      species: map['jenis_tanaman'] as String,
      imagePath: map['foto_url'] as String?,
      wateringIntervalDays: (map['interval_siram'] as int?) ?? 3,
      lastWatered: map['terakhir_siram'] != null
          ? DateTime.parse(map['terakhir_siram'] as String)
          : null,
      fertilizerEnabled: (map['aktif_pupuk'] as bool?) ?? false,
      fertilizerIntervalDays: (map['interval_pupuk'] as int?) ?? 7,
      lastFertilized: map['terakhir_pupuk'] != null
          ? DateTime.parse(map['terakhir_pupuk'] as String)
          : null,
    );
  }

  // ── Konversi ke Map untuk INSERT/UPDATE Supabase ─────────────
  // Tidak menyertakan id_tanaman (auto-generated) dan id_user
  Map<String, dynamic> toMap() {
    return {
      'nama_tanaman': name,
      'jenis_tanaman': species,
      'foto_url': imagePath,
      'interval_siram': wateringIntervalDays,
      'terakhir_siram': lastWatered?.toIso8601String(),
      'aktif_pupuk': fertilizerEnabled,
      'interval_pupuk': fertilizerIntervalDays,
      'terakhir_pupuk': lastFertilized?.toIso8601String(),
    };
  }

  PlantStatus get wateringStatus {
    if (lastWatered == null) return PlantStatus.due;
    final daysSince = DateTime.now().difference(lastWatered!).inDays;
    if (daysSince < wateringIntervalDays) return PlantStatus.safe;
    if (daysSince == wateringIntervalDays) return PlantStatus.due;
    return PlantStatus.overdue;
  }

  String get wateringTimeText {
    if (lastWatered == null) return 'Belum pernah';
    final daysSince = DateTime.now().difference(lastWatered!).inDays;
    final daysLeft = wateringIntervalDays - daysSince;
    if (daysLeft > 0) return '$daysLeft hari lagi';
    if (daysLeft == 0) return 'Hari ini';
    return '${daysLeft.abs()} hari lalu';
  }

  PlantStatus? get fertilizingStatus {
    if (!fertilizerEnabled) return null;
    if (lastFertilized == null) return PlantStatus.due;
    final daysSince = DateTime.now().difference(lastFertilized!).inDays;
    if (daysSince < fertilizerIntervalDays) return PlantStatus.safe;
    if (daysSince == fertilizerIntervalDays) return PlantStatus.due;
    return PlantStatus.overdue;
  }

  PlantStatus get overallStatus {
    final fertilizing = fertilizingStatus;
    if (fertilizing == null) return wateringStatus;
    return PlantStatus.values[max(wateringStatus.index, fertilizing.index)];
  }

  String get fertilizerTimeText {
    if (!fertilizerEnabled || lastFertilized == null) return '-';
    final daysSince = DateTime.now().difference(lastFertilized!).inDays;
    final daysLeft = fertilizerIntervalDays - daysSince;
    if (daysLeft > 0) return '$daysLeft hari lagi';
    if (daysLeft == 0) return 'Hari ini';
    return '${daysLeft.abs()} hari lalu';
  }

  bool get canFertilize {
    return fertilizerEnabled && fertilizingStatus != PlantStatus.safe;
  }

  String get nextCareText {
    final fertilizing = fertilizingStatus;
    if (fertilizing == null || wateringStatus.index >= fertilizing.index) {
      return 'Siram · $wateringTimeText';
    }
    return 'Pupuk · $fertilizerTimeText';
  }

  PlantModel copyWith({
    String? id,
    String? name,
    String? species,
    String? imagePath,
    int? wateringIntervalDays,
    DateTime? lastWatered,
    bool? fertilizerEnabled,
    int? fertilizerIntervalDays,
    DateTime? lastFertilized,
    bool clearLastWatered = false,
    bool clearLastFertilized = false,
    bool clearImagePath = false,
  }) {
    return PlantModel(
      id: id ?? this.id,
      name: name ?? this.name,
      species: species ?? this.species,
      imagePath: clearImagePath ? null : imagePath ?? this.imagePath,
      wateringIntervalDays: wateringIntervalDays ?? this.wateringIntervalDays,
      lastWatered: clearLastWatered ? null : lastWatered ?? this.lastWatered,
      fertilizerEnabled: fertilizerEnabled ?? this.fertilizerEnabled,
      fertilizerIntervalDays:
          fertilizerIntervalDays ?? this.fertilizerIntervalDays,
      lastFertilized: clearLastFertilized
          ? null
          : lastFertilized ?? this.lastFertilized,
    );
  }
}
