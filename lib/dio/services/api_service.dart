import 'package:dio/dio.dart';

import '../interceptors/interceptor.dart';

class ApiService {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: "https://api.chaynik.uz",  // Базовый URL
    connectTimeout: Duration(seconds: 10),
    receiveTimeout: Duration(seconds: 10),
  ));

  static Dio get dio {
    _dio.interceptors.add(AuthInterceptor()); // Добавляем интерцептор
    return _dio;
  }
}
