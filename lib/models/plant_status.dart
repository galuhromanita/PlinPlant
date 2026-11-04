enum PlantStatus { safe, due, overdue }

extension PlantStatusLabel on PlantStatus {
  String get label {
    switch (this) {
      case PlantStatus.safe:
        return 'Aman';
      case PlantStatus.due:
        return 'Perlu';
      case PlantStatus.overdue:
        return 'Terlambat';
    }
  }
}
