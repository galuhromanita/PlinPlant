import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/plant_model.dart';
import '../models/plant_status.dart';
import '../models/care_history_model.dart';
import '../services/photo_service.dart';

// PLANT STORE — CRUD ke Supabase

// Tabel yang digunakan:
//   tanaman            → data tanaman (soft delete via deleted_at)
//   riwayat_penyiraman → setiap penyiraman
//   riwayat_pemupukan  → setiap pemupukan

class PlantStore extends ChangeNotifier {
  static final PlantStore _instance = PlantStore._internal();
  factory PlantStore() => _instance;
  PlantStore._internal();

  final _supabase = Supabase.instance.client;
  final _photoService = PhotoService();

  List<PlantModel> _plants = [];
  List<CareHistory> _histories = [];
  bool _isLoading = false;

  List<PlantModel> get plants => List.unmodifiable(_plants);
  List<CareHistory> get histories => List.unmodifiable(_histories);
  bool get isLoading => _isLoading;

  int get totalPlants => _plants.length;

  int get amanCount =>
      _plants.where((p) => p.overallStatus == PlantStatus.safe).length;

  int get perluCount =>
      _plants.where((p) => p.overallStatus == PlantStatus.due).length;

  int get terlambatCount =>
      _plants.where((p) => p.overallStatus == PlantStatus.overdue).length;

  PlantModel? getById(String id) {
    final i = _plants.indexWhere((p) => p.id == id);
    return i == -1 ? null : _plants[i];
  }

  String generateId() => '0';

  // ── UPLOAD FOTO TANAMAN ───────────────────────────────────────
  // Mengunggah foto ke Supabase Storage, mengembalikan public URL.
  // Dipanggil dari AddPlantScreen sebelum addPlant/updatePlant.
  Future<String?> uploadPlantPhoto({
    required XFile file,
    required String plantId,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;
    return _photoService.uploadPhoto(
      file: file,
      userId: userId,
      plantId: plantId,
    );
  }

  // FETCH TANAMAN AKTIF
  Future<void> fetchPlants() async {
    _isLoading = true;
    notifyListeners();

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        _plants = [];
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Filter: id_user = userId AND deleted_at IS NULL (aktif)
      final data = await _supabase
          .from('tanaman')
          .select()
          .eq('id_user', userId)
          .isFilter('deleted_at', null)
          .order('created_at', ascending: true);

      _plants = (data as List)
          .map((row) => PlantModel.fromMap(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _plants = [];
      debugPrint('[PlantStore] fetchPlants error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // FETCH RIWAYAT (PENYIRAMAN + PEMUPUKAN)
  Future<void> fetchHistories() async {
    try {
      // Riwayat penyiraman — join tanaman untuk nama_tanaman
      // RLS sudah filter berdasarkan id_user otomatis
      final siramData = await _supabase
          .from('riwayat_penyiraman')
          .select('id_siram, id_tanaman, tanggal_siram, tanaman(nama_tanaman)')
          .order('tanggal_siram', ascending: false)
          .limit(30);

      // Riwayat pemupukan — join tanaman untuk nama_tanaman
      final pupukData = await _supabase
          .from('riwayat_pemupukan')
          .select('id_pupuk, id_tanaman, tanggal_pupuk, tanaman(nama_tanaman)')
          .order('tanggal_pupuk', ascending: false)
          .limit(30);

      final siramList = (siramData as List).map((row) {
        final r = row as Map<String, dynamic>;
        final tanamanMap = r['tanaman'] as Map<String, dynamic>?;
        return CareHistory(
          id: r['id_siram'].toString(),
          plantId: r['id_tanaman'].toString(),
          plantName: (tanamanMap?['nama_tanaman'] as String?) ?? '-',
          careType: CareType.watering,
          performedAt: DateTime.parse(r['tanggal_siram'] as String),
        );
      }).toList();

      final pupukList = (pupukData as List).map((row) {
        final r = row as Map<String, dynamic>;
        final tanamanMap = r['tanaman'] as Map<String, dynamic>?;
        return CareHistory(
          id: r['id_pupuk'].toString(),
          plantId: r['id_tanaman'].toString(),
          plantName: (tanamanMap?['nama_tanaman'] as String?) ?? '-',
          careType: CareType.fertilizing,
          performedAt: DateTime.parse(r['tanggal_pupuk'] as String),
        );
      }).toList();

      // Gabungkan dan urutkan berdasarkan waktu terbaru
      _histories = [...siramList, ...pupukList];
      _histories.sort((a, b) => b.performedAt.compareTo(a.performedAt));
      notifyListeners();
    } catch (e) {
      _histories = [];
      debugPrint('[PlantStore] fetchHistories error: $e');
      notifyListeners();
    }
  }

  // TAMBAH TANAMAN (INSERT ke tabel `tanaman`)
  Future<PlantModel?> addPlant(PlantModel plant) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;

    try {
      final inserted = await _supabase
          .from('tanaman')
          .insert({...plant.toMap(), 'id_user': userId})
          .select()
          .single();

      final newPlant = PlantModel.fromMap(inserted);
      _plants.add(newPlant);
      notifyListeners();
      return newPlant;
    } catch (e) {
      debugPrint('[PlantStore] addPlant error: $e');
      return null;
    }
  }

  // UPDATE TANAMAN
  // Jika foto_url berubah, foto lama dihapus dari Storage secara async.
  Future<void> updatePlant(PlantModel updated) async {
    final idTanaman = int.parse(updated.id);

    // Cek apakah foto berubah → hapus foto lama dari Storage
    final oldPlant = _plants.firstWhere(
      (p) => p.id == updated.id,
      orElse: () => updated,
    );
    // Simpan URL lama sebelum overwrite agar bisa dihapus setelah update
    final String? oldPhotoUrl = oldPlant.imagePath;
    final String? newPhotoUrl = updated.imagePath;

    await _supabase
        .from('tanaman')
        .update(updated.toMap())
        .eq('id_tanaman', idTanaman);

    final idx = _plants.indexWhere((p) => p.id == updated.id);
    if (idx != -1) _plants[idx] = updated;
    notifyListeners();

    // Hapus foto lama dari Storage setelah update DB berhasil (non-blocking).
    // Hanya hapus jika ada foto lama dan URL-nya berbeda dengan yang baru.
    if (oldPhotoUrl != null && oldPhotoUrl != newPhotoUrl) {
      _photoService.deletePhoto(fotoUrl: oldPhotoUrl);
    }
  }

  // SOFT DELETE TANAMAN
  Future<void> deletePlant(String id) async {
    final idTanaman = int.parse(id);

    // Ambil foto_url sebelum di-soft-delete untuk dihapus dari Storage
    final plant = _plants.firstWhere(
      (p) => p.id == id,
      orElse: () => PlantModel(id: id, name: '', species: ''),
    );

    await _supabase
        .from('tanaman')
        .update({'deleted_at': DateTime.now().toIso8601String()})
        .eq('id_tanaman', idTanaman);

    // Hapus foto dari Storage jika ada (tidak fatal jika gagal)
    if (plant.imagePath != null && plant.imagePath!.isNotEmpty) {
      await _photoService.deletePhoto(fotoUrl: plant.imagePath!);
    }

    // Hapus dari list lokal agar UI langsung update
    _plants.removeWhere((p) => p.id == id);
    _histories.removeWhere((h) => h.plantId == id);
    notifyListeners();
  }

  // CATAT PENYIRAMAN
  // Update terakhir_siram + INSERT ke riwayat_penyiraman
  Future<void> waterPlant(String id) async {
    final idx = _plants.indexWhere((p) => p.id == id);
    if (idx == -1) return;

    final now = DateTime.now();
    final plant = _plants[idx];
    final idTanaman = int.parse(id);

    // 1. Update terakhir_siram di tabel tanaman
    await _supabase
        .from('tanaman')
        .update({'terakhir_siram': now.toIso8601String()})
        .eq('id_tanaman', idTanaman);

    // 2. Insert ke riwayat_penyiraman
    final inserted = await _supabase
        .from('riwayat_penyiraman')
        .insert({
          'id_tanaman': idTanaman,
          'tanggal_siram': now.toIso8601String(),
        })
        .select('id_siram')
        .single();

    // 3. Update list lokal
    _plants[idx] = plant.copyWith(lastWatered: now);
    _histories.insert(
      0,
      CareHistory(
        id: inserted['id_siram'].toString(),
        plantId: id,
        plantName: plant.name,
        careType: CareType.watering,
        performedAt: now,
      ),
    );
    notifyListeners();
  }

  // CATAT PEMUPUKAN
  // Update terakhir_pupuk + INSERT ke riwayat_pemupukan
  Future<void> fertilizePlant(String id) async {
    final idx = _plants.indexWhere((p) => p.id == id);
    if (idx == -1) return;

    final now = DateTime.now();
    final plant = _plants[idx];
    final idTanaman = int.parse(id);

    // 1. Update terakhir_pupuk di tabel tanaman
    await _supabase
        .from('tanaman')
        .update({'terakhir_pupuk': now.toIso8601String()})
        .eq('id_tanaman', idTanaman);

    // 2. Insert ke riwayat_pemupukan
    final inserted = await _supabase
        .from('riwayat_pemupukan')
        .insert({
          'id_tanaman': idTanaman,
          'tanggal_pupuk': now.toIso8601String(),
        })
        .select('id_pupuk')
        .single();

    // 3. Update list lokal
    _plants[idx] = plant.copyWith(lastFertilized: now);
    _histories.insert(
      0,
      CareHistory(
        id: inserted['id_pupuk'].toString(),
        plantId: id,
        plantName: plant.name,
        careType: CareType.fertilizing,
        performedAt: now,
      ),
    );
    notifyListeners();
  }

  // ── Reset saat logout ─────────────────────────────────────────
  void clear() {
    _plants.clear();
    _histories.clear();
    notifyListeners();
  }
}
