// ============================================================
// PHOTO SERVICE — Pilih, ambil, upload & hapus foto tanaman
//
// Bucket  : plant-photos (public, buat di Supabase Dashboard → Storage)
// Path    : {userId}/{plantId}/{timestamp}.jpg
//
// Alur permission:
//   - Galeri  : image_picker menggunakan Android Photo Picker (Android 13+)
//               secara otomatis — tidak perlu izin READ_MEDIA_IMAGES.
//               Untuk Android ≤12, permission_handler meminta
//               READ_EXTERNAL_STORAGE sebelum membuka picker.
//   - Kamera  : permission_handler meminta CAMERA; jika ditolak permanen
//               arahkan ke Settings.
// ============================================================

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PhotoService {
  // ── Singleton ──────────────────────────────────────────────
  static final PhotoService _instance = PhotoService._internal();
  factory PhotoService() => _instance;
  PhotoService._internal();

  // ── Konstanta ──────────────────────────────────────────────
  static const String _bucket = 'plant-photos';

  final _supabase = Supabase.instance.client;
  final _picker = ImagePicker();

  // ════════════════════════════════════════════════════════════
  // PERMISSION
  // ════════════════════════════════════════════════════════════

  /// Minta izin kamera. Mengembalikan true jika diizinkan.
  Future<bool> requestCameraPermission() async {
    if (kIsWeb) return true;
    if (!Platform.isAndroid && !Platform.isIOS) return true;
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// Apakah izin kamera ditolak permanen (tidak muncul dialog lagi).
  Future<bool> isCameraPermissionPermanentlyDenied() async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) return false;
    return Permission.camera.isPermanentlyDenied;
  }

  /// Minta izin baca galeri.
  /// Android 13+ (SDK 33+): image_picker menggunakan Android Photo Picker
  /// secara otomatis dan TIDAK memerlukan izin READ_MEDIA_IMAGES.
  /// Untuk Android ≤12, memerlukan READ_EXTERNAL_STORAGE.
  /// Mengembalikan true jika diizinkan atau tidak diperlukan.
  Future<bool> requestGalleryPermission() async {
    if (kIsWeb) return true;
    if (!Platform.isAndroid) return true;

    // Strategi: langsung coba buka picker terlebih dahulu.
    // Pada Android 13+ (SDK 33+), image_picker menggunakan Android Photo
    // Picker yang bekerja tanpa permission apapun.
    // Pada Android ≤12, jika permission belum ada, picker akan gagal
    // dan kita fallback ke request permission.
    //
    // Deteksi SDK version melalui status permission:
    // - Android 13+: Permission.storage.status → permanentlyDenied
    //   (karena READ_EXTERNAL_STORAGE dihapus dari manifest via maxSdkVersion=32)
    // - Android ≤12: Permission.storage.status → denied/granted/permanentlyDenied
    //   tergantung apakah sudah pernah diminta
    //
    // Kasus khusus: beberapa perangkat Android 13+ melaporkan storage sebagai
    // 'denied' (bukan permanentlyDenied) jika belum pernah diminta.
    // Untuk menangani ini, cek juga Permission.photos:
    // - Android 13+: Permission.photos tersedia (status bisa granted/denied)
    // - Android ≤12: Permission.photos tidak tersedia (selalu denied)
    final storageStatus = await Permission.storage.status;
    final photosStatus = await Permission.photos.status;

    // Android 13+: photos permission tersedia ATAU storage permanentlyDenied
    // → Photo Picker native, tidak perlu izin apapun
    if (storageStatus.isPermanentlyDenied ||
        photosStatus.isGranted ||
        photosStatus.isLimited) {
      return true;
    }

    // Jika photos permission bisa di-request (bukan denied default Android ≤12),
    // kemungkinan besar Android 13+ yang belum pernah diminta photos
    if (photosStatus.isDenied) {
      // Coba request photos permission untuk membedakan Android 13+ vs ≤12
      // Pada Android ≤12, request ini akan langsung permanentlyDenied
      final photosResult = await Permission.photos.request();
      if (photosResult.isPermanentlyDenied) {
        // Android ≤12: photos tidak tersedia, perlu storage permission
        if (!storageStatus.isGranted) {
          final result = await Permission.storage.request();
          return result.isGranted;
        }
        return true;
      }
      // Android 13+: photos berhasil di-request (granted/limited/denied)
      // Photo Picker tetap bekerja tanpa izin di Android 13+
      return true;
    }

    // Fallback: Android ≤12, minta READ_EXTERNAL_STORAGE
    if (!storageStatus.isGranted) {
      final result = await Permission.storage.request();
      return result.isGranted;
    }

    return true;
  }

  /// Apakah izin galeri ditolak permanen (hanya relevan Android ≤12).
  /// Pada Android 13+, Photo Picker bekerja tanpa izin, jadi selalu false.
  Future<bool> isGalleryPermissionPermanentlyDenied() async {
    if (kIsWeb || !Platform.isAndroid) return false;

    final storageStatus = await Permission.storage.status;

    // Android 13+: storage selalu permanentlyDenied TAPI Photo Picker
    // tidak memerlukan izin — jadi bukan "denied permanen" yang sebenarnya.
    if (storageStatus.isPermanentlyDenied) {
      // Cek photos untuk membedakan Android 13+ vs ≤12:
      final photosStatus = await Permission.photos.status;
      // Jika photos permission tersedia (not permanentlyDenied),
      // berarti Android 13+ → Photo Picker native, tidak perlu izin
      if (!photosStatus.isPermanentlyDenied) {
        return false;
      }
      // Keduanya permanently denied bisa terjadi di Android ≤12 yang
      // sudah deny storage secara permanen. Tapi bisa juga Android 13+
      // dimana Photo Picker tetap bekerja. Untuk amannya return false
      // karena Photo Picker masih bisa jalan di Android 13+.
      return false;
    }

    // Storage bukan permanentlyDenied → Android ≤12
    // Di Android ≤12, storage permission bisa diminta ulang jika status
    // hanya 'denied' (bukan permanent). Return false karena masih bisa
    // diminta lagi — pemanggil akan memanggil requestGalleryPermission().
    return false;
  }

  // ════════════════════════════════════════════════════════════
  // PICK & CAPTURE
  // ════════════════════════════════════════════════════════════

  /// Buka galeri. Di Android 13+ menggunakan Photo Picker native yang tidak
  /// memerlukan izin. Di Android ≤12 meminta READ_EXTERNAL_STORAGE.
  /// Mengembalikan XFile? atau null jika dibatalkan / permission ditolak.
  Future<XFile?> pickFromGallery() async {
    // Minta permission hanya untuk Android ≤12
    final granted = await requestGalleryPermission();
    if (!granted) return null; // Pemanggil harus cek dan tampilkan dialog

    try {
      return await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1080,
        maxHeight: 1080,
      );
    } catch (e) {
      debugPrint('[PhotoService] pickFromGallery error: $e');
      // Jika permission check salah deteksi SDK dan picker gagal,
      // coba lagi langsung tanpa permission (untuk Android 13+ fallback)
      try {
        return await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 85,
          maxWidth: 1080,
          maxHeight: 1080,
        );
      } catch (retryError) {
        debugPrint('[PhotoService] pickFromGallery retry error: $retryError');
        return null;
      }
    }
  }

  /// Buka kamera. Permission ditangani oleh pemanggil (AddPlantScreen).
  Future<XFile?> captureFromCamera() async {
    try {
      return await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1080,
        maxHeight: 1080,
      );
    } catch (e) {
      debugPrint('[PhotoService] captureFromCamera error: $e');
      return null;
    }
  }

  // ════════════════════════════════════════════════════════════
  // UPLOAD
  // ════════════════════════════════════════════════════════════

  /// Upload foto ke Supabase Storage.
  /// Mengembalikan public URL atau null jika gagal.
  /// Path: {userId}/{plantId}/{timestamp}.jpg
  Future<String?> uploadPhoto({
    required XFile file,
    required String userId,
    required String plantId,
  }) async {
    try {
      // Selalu simpan sebagai jpg agar konsisten di semua platform
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final storagePath = '$userId/$plantId/$timestamp.jpg';

      final bytes = await File(file.path).readAsBytes();

      await _supabase.storage.from(_bucket).uploadBinary(
        storagePath,
        bytes,
        fileOptions: const FileOptions(
          contentType: 'image/jpeg',
          upsert: true,
        ),
      );

      // Tambahkan cache-busting query agar Image.network tidak
      // menampilkan foto lama dari cache setelah foto diperbarui.
      final baseUrl = _supabase.storage.from(_bucket).getPublicUrl(storagePath);
      return '$baseUrl?t=$timestamp';
    } catch (e) {
      debugPrint('[PhotoService] uploadPhoto error: $e');
      return null;
    }
  }

  // ════════════════════════════════════════════════════════════
  // DELETE
  // ════════════════════════════════════════════════════════════

  /// Hapus foto dari Storage berdasarkan public URL.
  /// Tidak fatal jika gagal (foto mungkin sudah dihapus atau URL berubah).
  Future<void> deletePhoto({required String fotoUrl}) async {
    try {
      // Format URL: https://<proj>.supabase.co/storage/v1/object/public/<bucket>/<path>?t=...
      // Hapus query string sebelum parsing path
      final uri = Uri.parse(fotoUrl.split('?').first);
      final segments = uri.pathSegments;
      final bucketIdx = segments.indexOf(_bucket);
      if (bucketIdx == -1 || bucketIdx + 1 >= segments.length) return;

      final storagePath = segments.sublist(bucketIdx + 1).join('/');
      await _supabase.storage.from(_bucket).remove([storagePath]);
      debugPrint('[PhotoService] deleted: $storagePath');
    } catch (e) {
      debugPrint('[PhotoService] deletePhoto error (non-fatal): $e');
    }
  }

}
