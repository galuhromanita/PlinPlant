// ============================================================
// MODEL DATA TANAMAN
// ============================================================

import 'dart:math';

import 'plant_status.dart';

class PlantModel {
  final String id;
  String name;
  String species;
  String? imagePath;
  int wateringIntervalDays;
  DateTime? lastWatered;
  bool fertilizerEnabled;
  int fertilizerIntervalDays;
  DateTime? lastFertilized;

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

  PlantStatus get wateringStatus {
    if (lastWatered == null) return PlantStatus.due;
    final daysSince = DateTime.now().difference(lastWatered!).inDays;
    if (daysSince < wateringIntervalDays) return PlantStatus.safe;
    if (daysSince == wateringIntervalDays) return PlantStatus.due;
    return PlantStatus.overdue;
  }

  /// Berapa hari lagi / lalu disiram
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

  /// Berapa hari lagi / lalu dipupuk
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
