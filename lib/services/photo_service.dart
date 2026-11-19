// ============================================================
// PHOTO SERVICE — Pilih, ambil, upload & hapus foto tanaman
//
// Bucket  : plant-photos (public, buat di Supabase Dashboard → Storage)
// Path    : {userId}/{plantId}/{timestamp}.jpg
//
// Alur permission:
//   - Galeri  : permission_handler meminta Permission.storage pada Android
//               ≤12 dan Permission.photos pada Android 13+ serta iOS.
//               Status limited tetap dapat digunakan untuk memilih foto.
//   - Kamera  : permission_handler meminta CAMERA; jika ditolak permanen
//               arahkan ke Settings.
// ============================================================

import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
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
  final _deviceInfo = DeviceInfoPlugin();

  // ════════════════════════════════════════════════════════════
  // PERMISSION
  // ════════════════════════════════════════════════════════════

  /// Minta izin kamera. Mengembalikan true jika diizinkan.
  Future<bool> requestCameraPermission() async {
    if (kIsWeb) return true;
    if (!Platform.isAndroid && !Platform.isIOS) return true;
    final permission = Permission.camera;
    final currentStatus = await permission.status;
    if (currentStatus.isGranted) return true;
    if (currentStatus.isPermanentlyDenied) return false;
    final status = await permission.request();
    return status.isGranted;
  }

  /// Apakah izin kamera ditolak permanen (tidak muncul dialog lagi).
  Future<bool> isCameraPermissionPermanentlyDenied() async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) return false;
    return Permission.camera.isPermanentlyDenied;
  }

  /// Minta izin galeri sesuai platform dan versi Android.
  Future<bool> requestGalleryPermission() async {
    if (kIsWeb) return true;
    if (Platform.isIOS) {
      final permission = Permission.photos;
      final currentStatus = await permission.status;
      if (currentStatus.isGranted || currentStatus.isLimited) return true;
      if (currentStatus.isPermanentlyDenied) return false;
      final status = await permission.request();
      return status.isGranted || status.isLimited;
    }
    if (!Platform.isAndroid) return true;

    final sdkInt = (await _deviceInfo.androidInfo).version.sdkInt;
    final permission = sdkInt >= 33 ? Permission.photos : Permission.storage;
    final currentStatus = await permission.status;
    if (currentStatus.isGranted || currentStatus.isLimited) return true;
    if (currentStatus.isPermanentlyDenied) return false;
    final status = await permission.request();
    return status.isGranted || status.isLimited;
  }

  /// Apakah izin galeri tidak dapat diminta lagi tanpa membuka Settings.
  Future<bool> isGalleryPermissionPermanentlyDenied() async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) return false;
    final Permission permission;
    if (Platform.isIOS) {
      permission = Permission.photos;
    } else {
      final sdkInt = (await _deviceInfo.androidInfo).version.sdkInt;
      permission = sdkInt >= 33 ? Permission.photos : Permission.storage;
    }
    return permission.isPermanentlyDenied;
  }

  // ════════════════════════════════════════════════════════════
  // PICK & CAPTURE
  // ════════════════════════════════════════════════════════════

  /// Buka galeri setelah pemanggil memastikan izin sudah diberikan.
  Future<XFile?> pickFromGallery() async {
    try {
      return await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1080,
        maxHeight: 1080,
      );
    } catch (e) {
      debugPrint('[PhotoService] pickFromGallery error: $e');
      return null;
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

      await _supabase.storage
          .from(_bucket)
          .uploadBinary(
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
