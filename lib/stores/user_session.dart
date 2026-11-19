import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_model.dart';
import '../stores/plant_store.dart';


class UserSession extends ChangeNotifier {
  static final UserSession _instance = UserSession._internal();
  factory UserSession() => _instance;
  UserSession._internal();

  final _supabase = Supabase.instance.client;

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  // ══════════════════════════════════════════════════════════════
  // SINKRONISASI AWAL (dipanggil di splash_screen atau main)
  // Cek apakah masih ada session aktif dari sebelumnya
  // ══════════════════════════════════════════════════════════════
  Future<void> syncFromSupabase() async {
    final session = _supabase.auth.currentSession;
    if (session != null) {
      await _fetchAndSetProfile(session.user);
    }

    // Dengarkan perubahan auth state (login / logout / token refresh)
    _supabase.auth.onAuthStateChange.listen((data) async {
      final event = data.event;
      final session = data.session;

      if (event == AuthChangeEvent.signedIn && session != null) {
        await _fetchAndSetProfile(session.user);
        // Muat data tanaman setelah login
        await PlantStore().fetchPlants();
        await PlantStore().fetchHistories();
      } else if (event == AuthChangeEvent.signedOut) {
        _currentUser = null;
        PlantStore().clear();
        notifyListeners();
      } else if (event == AuthChangeEvent.tokenRefreshed && session != null) {
        // Session diperpanjang — tidak perlu re-fetch profil
        if (_currentUser == null) {
          await _fetchAndSetProfile(session.user);
        }
      }
    });
  }


  // LOGIN DENGAN GOOGLE (OAuth via Supabase)
  // Membuka browser — callback ditangkap oleh deep link Android
  Future<void> loginWithGoogle() async {
    await _supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      // Deep link harus sesuai dengan AndroidManifest.xml
      redirectTo: 'io.supabase.plinplant://login-callback',
    );
    // Hasil login ditangani oleh onAuthStateChange di syncFromSupabase()
  }


  // LOGOUT
  Future<void> logout() async {
    await _supabase.auth.signOut();
    // onAuthStateChange akan set _currentUser = null dan clear store
  }

  // PRIVATE: Ambil profil dari tabel `profiles`
  // Trigger handle_user_profile sudah mengisi tabel ini otomatis
  Future<void> _fetchAndSetProfile(User supabaseUser) async {
    try {
      final profileData = await _supabase
          .from('profiles')
          .select('nama, email')
          .eq('id', supabaseUser.id)
          .single();

      final map = profileData;
      _currentUser = UserModel(
        id: supabaseUser.id,
        name: (map['nama'] as String?)?.isNotEmpty == true
            ? map['nama'] as String
            : 'Pengguna',
        email: (map['email'] as String?) ?? supabaseUser.email ?? '',
        // foto dari metadata Google OAuth (tidak disimpan di profiles)
        photoUrl: supabaseUser.userMetadata?['avatar_url'] as String?,
      );
    } catch (e) {
      // Fallback: gunakan metadata dari Google jika profiles belum ada
      debugPrint('[UserSession] _fetchAndSetProfile error: $e');
      final meta = supabaseUser.userMetadata ?? {};
      _currentUser = UserModel(
        id: supabaseUser.id,
        name: ((meta['full_name'] ?? meta['name'] ?? '') as String).isNotEmpty
            ? (meta['full_name'] ?? meta['name']) as String
            : 'Pengguna',
        email: supabaseUser.email ?? '',
        photoUrl: meta['avatar_url'] as String?,
      );
    }
    notifyListeners();
  }
}
