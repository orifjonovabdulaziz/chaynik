import 'package:dio/dio.dart';

import '../interceptors/interceptor.dart';

class ApiService {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: "https://back.chaynik.uz",  // Базовый URL
    connectTimeout: Duration(seconds: 60),
    receiveTimeout: Duration(seconds: 60),
  ));

  static final Dio _dioInstance = _initDio();

  static Dio _initDio() {
    _dio.interceptors.clear(); // Очищаем все интерцепторы
    _dio.interceptors.add(AuthInterceptor()); // Добавляем один раз
    return _dio;
  }

  static Dio get dio => _dioInstance;
}
