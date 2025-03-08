import 'package:chaynik/repositories/auth_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../dio/services/auth_service.dart';
import '../dio/services/shared_prefs_service.dart';
import '../router/router.dart';

/// 🔹 **Провайдер для AuthService**
final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository());

/// 🔹 **Провайдер для токена**
final authProvider = StateNotifierProvider<AuthNotifier, String?>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

/// **Класс для управления токеном**
class AuthNotifier extends StateNotifier<String?> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(null) {
    _loadToken(); // Загружаем токен при старте
  }

  /// 🔹 **Авторизация**
  Future<bool> login(String email, String password) async {
    String? token = await _authRepository.login(email, password);
    if (token != null) {
      state = token;
      return true;
    }
    return false;
  }

  /// 🔹 **Загрузка сохранённого токена**
  Future<void> _loadToken() async {
    state = await SharedPrefsService.getToken();
  }

  /// 🔹 **Выход из системы**
  Future<void> logout() async {
    try {
      await _authRepository.logout();
    } catch (e) {
      print('Logout error: $e');
    } finally {
      state = null;
      rootNavigatorKey.currentContext?.go('/auth');
    }
  }
}
