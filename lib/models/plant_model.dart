// ============================================================
// MODEL DATA TANAMAN
// ============================================================

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
  DateTime? fertilizerLastDate;

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
    this.fertilizerLastDate,
  });

  /// Status penyiraman: 'Aman', 'Perlu', 'Terlambat'
  String get wateringStatus {
    if (lastWatered == null) return 'Perlu';
    final daysSince =
        DateTime.now().difference(lastWatered!).inDays;
    if (daysSince < wateringIntervalDays) return 'Aman';
    if (daysSince == wateringIntervalDays) return 'Perlu';
    return 'Terlambat';
  }

  /// Berapa hari lagi / lalu disiram
  String get wateringTimeText {
    if (lastWatered == null) return 'Belum pernah';
    final daysSince =
        DateTime.now().difference(lastWatered!).inDays;
    final daysLeft = wateringIntervalDays - daysSince;
    if (daysLeft > 0) return '$daysLeft hari lagi';
    if (daysLeft == 0) return 'Hari ini';
    return '${daysLeft.abs()} hari lalu';
  }

  /// Status pemupukan
  String get fertilizerStatus {
    if (!fertilizerEnabled || lastFertilized == null) return 'Tidak aktif';
    final daysSince =
        DateTime.now().difference(lastFertilized!).inDays;
    if (daysSince < fertilizerIntervalDays) return 'Aman';
    return 'Perlu dipupuk';
  }

  /// Berapa hari lagi / lalu dipupuk
  String get fertilizerTimeText {
    if (!fertilizerEnabled || lastFertilized == null) return '-';
    final daysSince =
        DateTime.now().difference(lastFertilized!).inDays;
    final daysLeft = fertilizerIntervalDays - daysSince;
    if (daysLeft > 0) return '$daysLeft hari lagi';
    if (daysLeft == 0) return 'Hari ini';
    return '${daysLeft.abs()} hari lalu';
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
    DateTime? fertilizerLastDate,
  }) {
    return PlantModel(
      id: id ?? this.id,
      name: name ?? this.name,
      species: species ?? this.species,
      imagePath: imagePath ?? this.imagePath,
      wateringIntervalDays:
          wateringIntervalDays ?? this.wateringIntervalDays,
      lastWatered: lastWatered ?? this.lastWatered,
      fertilizerEnabled: fertilizerEnabled ?? this.fertilizerEnabled,
      fertilizerIntervalDays:
          fertilizerIntervalDays ?? this.fertilizerIntervalDays,
      lastFertilized: lastFertilized ?? this.lastFertilized,
      fertilizerLastDate:
          fertilizerLastDate ?? this.fertilizerLastDate,
    );
  }
}
