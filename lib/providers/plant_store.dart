import 'package:flutter/material.dart';
import '../models/plant_model.dart';
import '../models/care_history_model.dart';

// ============================================================
// PLANT STORE — STATE MANAGEMENT TANAMAN
// Data disimpan di memory (in-RAM).
// Tidak ada backend → data hilang jika app ditutup.
// ============================================================

class PlantStore extends ChangeNotifier {
  static final PlantStore _instance = PlantStore._internal();
  factory PlantStore() => _instance;
  PlantStore._internal();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final List<PlantModel> _plants = [
    PlantModel(
      id: '1',
      name: 'Monstera Deliciosa',
      species: 'Monstera',
      wateringIntervalDays: 3,
      lastWatered: DateTime.now().subtract(const Duration(days: 3)),
      fertilizerEnabled: false,
    ),
    PlantModel(
      id: '2',
      name: 'Kaktus',
      species: 'Cactus',
      wateringIntervalDays: 7,
      lastWatered: DateTime.now().subtract(const Duration(days: 2)),
      fertilizerEnabled: false,
    ),
    PlantModel(
      id: '3',
      name: 'Sirih Gading',
      species: 'Epipremnum aureum',
      wateringIntervalDays: 2,
      lastWatered: DateTime.now().subtract(const Duration(days: 4)),
      fertilizerEnabled: true,
      fertilizerIntervalDays: 7,
      lastFertilized: DateTime.now().subtract(const Duration(days: 2)),
    ),
    PlantModel(
      id: '4',
      name: 'Lidah Mertua',
      species: 'Sansevieria',
      wateringIntervalDays: 10,
      lastWatered: DateTime.now().subtract(const Duration(days: 3)),
      fertilizerEnabled: false,
    ),
    PlantModel(
      id: '5',
      name: 'Calathea',
      species: 'Calathea',
      wateringIntervalDays: 3,
      lastWatered: DateTime.now().subtract(const Duration(days: 3)),
      fertilizerEnabled: true,
      fertilizerIntervalDays: 14,
      lastFertilized: DateTime.now().subtract(const Duration(days: 4)),
    ),
  ];

  final List<CareHistory> _histories = [];

  // ── Getters ─────────────────────────────────────────────────

  List<PlantModel> get plants => List.unmodifiable(_plants);
  List<CareHistory> get histories => List.unmodifiable(_histories);

  int get totalPlants => _plants.length;

  int get amanCount =>
      _plants.where((p) => p.wateringStatus == 'Aman').length;

  int get perluCount =>
      _plants.where((p) => p.wateringStatus == 'Perlu').length;

  int get terlambatCount =>
      _plants.where((p) => p.wateringStatus == 'Terlambat').length;

  PlantModel? getById(String id) {
    try {
      return _plants.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  String generateId() => DateTime.now().millisecondsSinceEpoch.toString();

  // ── Async Operations (simulasi delay seperti network call) ──

  /// Tambah tanaman baru — async simulasi
  Future<void> addPlant(PlantModel plant) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 400));

    _plants.add(plant);
    _isLoading = false;
    notifyListeners();
  }

  /// Update tanaman — async simulasi
  Future<void> updatePlant(PlantModel updated) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 400));

    final idx = _plants.indexWhere((p) => p.id == updated.id);
    if (idx != -1) {
      _plants[idx] = updated;
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Hapus tanaman — async simulasi
  Future<void> deletePlant(String id) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 400));

    _plants.removeWhere((p) => p.id == id);
    _isLoading = false;
    notifyListeners();
  }

  /// Catat penyiraman — async simulasi
  Future<void> waterPlant(String id) async {
    final idx = _plants.indexWhere((p) => p.id == id);
    if (idx == -1) return;

    final plant = _plants[idx];
    _plants[idx] = plant.copyWith(lastWatered: DateTime.now());

    // Tambah ke riwayat
    _histories.insert(
      0,
      CareHistory(
        id: generateId(),
        plantId: id,
        plantName: plant.name,
        careType: CareType.watering,
        performedAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  /// Catat pemupukan — async simulasi
  Future<void> fertilizePlant(String id) async {
    final idx = _plants.indexWhere((p) => p.id == id);
    if (idx == -1) return;

    final plant = _plants[idx];
    _plants[idx] = plant.copyWith(lastFertilized: DateTime.now());

    // Tambah ke riwayat
    _histories.insert(
      0,
      CareHistory(
        id: generateId(),
        plantId: id,
        plantName: plant.name,
        careType: CareType.fertilizing,
        performedAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  /// Reset semua data (saat logout)
  void clearAll() {
    _plants.clear();
    _histories.clear();
    notifyListeners();
  }
}
