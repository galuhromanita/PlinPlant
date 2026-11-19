import 'dart:async';

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

  static const redirectUri = 'io.supabase.plinplant://login-callback';

  Future<void>? _syncFuture;

  // SINKRONISASI SESSION DAN AUTH STATE
  Future<void> syncFromSupabase() {
    return _syncFuture ??= _syncFromSupabase();
  }

  Future<void> _syncFromSupabase() async {
    debugPrint('[AUTH DEBUG] Supabase auth state sync dimulai');

    _supabase.auth.onAuthStateChange.listen(
      (data) {
        unawaited(_handleAuthStateChange(data));
      },
      onError: (Object error, StackTrace stackTrace) {
        debugPrint(
          '[AUTH DEBUG] Auth state listener gagal: ${error.runtimeType}',
        );
      },
    );

    final session = _supabase.auth.currentSession;
    debugPrint(
      '[AUTH DEBUG] Session awal tersedia: ${session != null}; '
      'User ID tersedia: ${session?.user.id != null}',
    );

    if (session != null) {
      await restoreCurrentSession();
    }
  }

  Future<bool> restoreCurrentSession() async {
    final session = _supabase.auth.currentSession;
    debugPrint(
      '[AUTH DEBUG] Pemulihan session: ${session != null}; '
      'User ID tersedia: ${session?.user.id != null}',
    );
    if (session == null) return false;

    await _setAuthenticatedUser(session.user);
    await _loadPlantData();
    return true;
  }

  Future<void> _handleAuthStateChange(AuthState data) async {
    final session = data.session;
    debugPrint(
      '[AUTH DEBUG] Auth event diterima: ${data.event}; '
      'Session tersedia: ${session != null}; '
      'User ID tersedia: ${session?.user.id != null}',
    );

    try {
      if (data.event == AuthChangeEvent.signedIn && session != null) {
        await _setAuthenticatedUser(session.user);
        await _loadPlantData();
      } else if (data.event == AuthChangeEvent.signedOut) {
        _currentUser = null;
        PlantStore().clear();
        notifyListeners();
        debugPrint('[AUTH DEBUG] Session dihapus setelah logout');
      } else if (data.event == AuthChangeEvent.tokenRefreshed &&
          session != null &&
          _currentUser == null) {
        await _setAuthenticatedUser(session.user);
      }
    } catch (error) {
      debugPrint(
        '[AUTH DEBUG] Pemrosesan auth event gagal: ${error.runtimeType}',
      );
    }
  }

  // LOGIN DENGAN GOOGLE
  Future<void> loginWithGoogle() async {
    debugPrint('[AUTH DEBUG] Memulai login Google');

    final launched = await _supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: redirectUri,
    );
    debugPrint('[AUTH DEBUG] Browser OAuth dibuka: $launched');
    if (!launched) {
      throw StateError('Browser OAuth tidak dapat dibuka');
    }
  }

  // LOGOUT
  Future<void> logout() async {
    debugPrint('[AUTH DEBUG] Logout dimulai');
    await _supabase.auth.signOut();
  }

  // MENGAMBIL PROFIL PENGGUNA
  Future<void> _setAuthenticatedUser(User supabaseUser) async {
    try {
      final profileData = await _supabase
          .from('profiles')
          .select('nama, email')
          .eq('id', supabaseUser.id)
          .single();

      _currentUser = UserModel(
        id: supabaseUser.id,
        name: (profileData['nama'] as String?)?.isNotEmpty == true
            ? profileData['nama'] as String
            : 'Pengguna',
        email: (profileData['email'] as String?) ?? supabaseUser.email ?? '',
        photoUrl: supabaseUser.userMetadata?['avatar_url'] as String?,
      );
      debugPrint('[AUTH DEBUG] Profil berhasil dimuat');
    } catch (e) {
      debugPrint(
        '[AUTH DEBUG] Profil gagal dimuat (${e.runtimeType}); '
        'menggunakan profil fallback',
      );

      final meta = supabaseUser.userMetadata ?? {};
      final metadataName = meta['full_name'] ?? meta['name'];
      final name = metadataName is String && metadataName.isNotEmpty
          ? metadataName
          : 'Pengguna';
      final metadataPhoto = meta['avatar_url'];

      _currentUser = UserModel(
        id: supabaseUser.id,
        name: name,
        email: supabaseUser.email ?? '',
        photoUrl: metadataPhoto is String ? metadataPhoto : null,
      );
    }

    notifyListeners();
    debugPrint(
      '[AUTH DEBUG] User tersedia: ${_currentUser != null}; '
      'User ID tersedia: ${_currentUser?.id != null}',
    );
  }

  Future<void> _loadPlantData() async {
    await PlantStore().fetchPlants();
    await PlantStore().fetchHistories();
    debugPrint('[AUTH DEBUG] Data aplikasi selesai dimuat');
  }
}
