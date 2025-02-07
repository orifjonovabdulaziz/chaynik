import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../dio/auth_service.dart';

/// 🔹 **Провайдер для AuthService**
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

/// 🔹 **Провайдер для токена**
final authProvider = StateNotifierProvider<AuthNotifier, String?>((ref) {
  return AuthNotifier(ref.watch(authServiceProvider));
});

/// **Класс для управления токеном**
class AuthNotifier extends StateNotifier<String?> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(null) {
    _loadToken(); // Загружаем токен при старте
  }

  /// 🔹 **Авторизация**
  Future<bool> login(String email, String password) async {
    String? token = await _authService.login(email, password);
    if (token != null) {
      state = token;
      return true;
    }
    return false;
  }

  /// 🔹 **Загрузка сохранённого токена**
  Future<void> _loadToken() async {
    state = await _authService.getToken();
  }

  /// 🔹 **Выход из системы**
  Future<void> logout() async {
    await _authService.logout();
    state = null;
  }
}
