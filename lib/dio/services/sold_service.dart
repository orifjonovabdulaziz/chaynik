import 'package:dio/dio.dart';
import '../../models/sold.dart';
import 'api_service.dart';

class SoldService {
  Future<bool> createSold(Sold sold) async {
    try {
      final response = await ApiService.dio.post(
        '/api/sold/',
        data: sold.toJson(),
      );

      return response.statusCode == 201 || response.statusCode == 200;
    } on DioException catch (e) {
      print('❌ Ошибка при создании продажи: ${e.message}');
      return false;
    }
  }

  /// Получить список продаж с фильтрами
  Future<List<Sold>> getSolds({
    int? client,
    String? createdAtAfter,
    String? createdAtBefore,
  }) async {
    try {
      // Формируем query параметры
      final Map<String, dynamic> queryParameters = {
        if (client != null) 'client': client,
        if (createdAtAfter != null) 'created_at_after': createdAtAfter,
        if (createdAtBefore != null) 'created_at_before': createdAtBefore,
      };

      final response = await ApiService.dio.get(
        '/api/sold/',
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Sold.fromJson(json)).toList();
      }

      print('❌ Ошибка при получении списка продаж: Код ${response.statusCode}');
      return [];
    } on DioException catch (e) {
      print('❌ Ошибка при получении списка продаж: ${e.message}');
      return [];
    }
  }
}