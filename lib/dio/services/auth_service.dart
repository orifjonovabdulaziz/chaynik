import 'package:chaynik/dio/services/shared_prefs_service.dart';
import 'package:dio/dio.dart';

import '../../models/category.dart';
import '../../repositories/category_repository.dart';
import '../db/category_db.dart';
import 'api_service.dart';
import 'category_service.dart';

class AuthService {
  /// 🔹 **POST-запрос на авторизацию**
  Future<String?> login(String email, String password) async {
    try {
      Response response = await ApiService.dio.post(
        '/api/accounts/login/',
        data: {"username": email, "password": password},
      );

      if (response.statusCode == 200) {
        String token = response.data['token'];
        await SharedPrefsService.saveToken(token); // Сохраняем токен локально
        // await _saveCategoriesToLocalDB();
        await CategoryRepository().getCategoriesFromServerAndSave();
        return token;
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        return null; // Неправильный логин или пароль
      }
    }
    return null;
  }

  /// 🔹 **Выход из системы (удаление токена)**
  Future<String?> logout() async {
    try {
      Response response = await ApiService.dio.get('/api/accounts/logout/');
      if (response.statusCode == 200) {
        await SharedPrefsService.removeToken();
        return "Выход выполнен";
      }
      return null;
    } on DioException {
      return "Что-то пошло не так";
    }
  }
}
