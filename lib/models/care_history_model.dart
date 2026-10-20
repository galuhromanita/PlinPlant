// ============================================================
// MODEL DATA RIWAYAT PERAWATAN
// ============================================================

enum CareType { watering, fertilizing }

class CareHistory {
  final String id;
  final String plantId;
  final String plantName;
  final CareType careType;
  final DateTime performedAt;

  const CareHistory({
    required this.id,
    required this.plantId,
    required this.plantName,
    required this.careType,
    required this.performedAt,
  });

  String get careTypeLabel {
    switch (careType) {
      case CareType.watering:
        return 'Disiram';
      case CareType.fertilizing:
        return 'Dipupuk';
    }
  }
}
