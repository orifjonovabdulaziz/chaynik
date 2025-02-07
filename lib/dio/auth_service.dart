import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_interceptor.dart';

class AuthService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: "http://192.168.31.174:8000", // Замените на свой API
    connectTimeout: Duration(seconds: 10),
    receiveTimeout: Duration(seconds: 10),
  ));

  AuthService() {
    _dio.interceptors.add(AuthInterceptor());
  }

  /// 🔹 **POST-запрос на авторизацию**
  Future<String?> login(String email, String password) async {
    try {
      Response response = await _dio.post(
        '/api/accounts/login/',
        data: {"username": email, "password": password},
      );

      if (response.statusCode == 200) {
        String token = response.data['token'];
        await _saveToken(token); // Сохраняем токен локально
        return token;

      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        return null; // Неправильный логин или пароль

      }
    }
    return null; // Ошибка сети или сервера
  }

  /// 🔹 **Сохранение токена в SharedPreferences**
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  /// 🔹 **Получение токена**
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  /// 🔹 **Выход из системы (удаление токена)**
  Future<String?> logout() async {
    try{
      Response response = await _dio.get('/api/accounts/logout/');
      print("Response is My Response: ${response.statusCode}");
      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('auth_token');
        return "Выход выполнен";
      }
      return null;

    }on DioException catch(e){
      return "Что то пошло не так";
    }

  }


  Future<Response> fetchData() async {
    return await _dio.get('/data');
  }
}
