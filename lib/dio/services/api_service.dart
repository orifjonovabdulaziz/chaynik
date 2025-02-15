import 'package:dio/dio.dart';

import '../interceptors/interceptor.dart';

class ApiService {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: "https://api.chaynik.uz",  // Базовый URL
    connectTimeout: Duration(seconds: 15),
    receiveTimeout: Duration(seconds: 15),
  ));

  static final Dio _dioInstance = _initDio();

  static Dio _initDio() {
    _dio.interceptors.clear(); // Очищаем все интерцепторы
    _dio.interceptors.add(AuthInterceptor()); // Добавляем один раз
    return _dio;
  }

  static Dio get dio => _dioInstance;
}
