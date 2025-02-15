import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  static const String _authTokenKey = 'auth_token';

  /// 🔹 **Сохранение токена**
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authTokenKey, token);
  }

  /// 🔹 **Получение токена**
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_authTokenKey);
  }

  /// 🔹 **Удаление токена**
  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authTokenKey);
  }



}
