import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (options.path == "/api/accounts/login/") {
      print("🔹 Пропускаем токен для /auth/login");
      return handler.next(options);
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token != null) {
      options.headers['Authorization'] = 'token $token';
    }

    print("📤 [REQUEST] ${options.method} ${options.uri}");
    return handler.next(options);
  }

  @override
  void onError(DioException e, ErrorInterceptorHandler handler) {
    print("❌ Ошибка: ${e.response?.statusCode}");
    return handler.next(e);
  }
}
