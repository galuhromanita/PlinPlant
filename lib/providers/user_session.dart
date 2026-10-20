import 'package:flutter/material.dart';
import '../models/user_model.dart';

// ============================================================
// SESSION PENGGUNA (TANPA BACKEND)
// Data user disimpan di memory selama sesi berlangsung.
// Ketika app ditutup, data hilang (tidak ada persistensi).
// ============================================================

class UserSession extends ChangeNotifier {
  static final UserSession _instance = UserSession._internal();
  factory UserSession() => _instance;
  UserSession._internal();

  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;

  bool get isLoggedIn => _currentUser != null;

  /// Simulasi login Google — delay 1 detik untuk meniru network call
  Future<void> loginWithGoogle() async {
    // Simulasi delay network (async)
    await Future.delayed(const Duration(milliseconds: 800));

    _currentUser = const UserModel(
      id: 'user_001',
      name: 'Galuh Juliviana Romanita',
      email: 'galuhj@email.com',
    );
    notifyListeners();
  }

  /// Logout — reset session
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
    notifyListeners();
  }
}
