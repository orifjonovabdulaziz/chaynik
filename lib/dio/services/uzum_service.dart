import 'package:dio/dio.dart';
import '../../models/uzum.dart';
import 'api_service.dart';

class UzumService {
  /// Получить статистику Uzum по ID магазина за указанный период
  Future<UzumStats?> getUzumStats({
    required int marketId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await ApiService.dio.post(
        '/api/uzum/$marketId/',
        data: {
          'start_date': _formatDateForRequest(startDate),
          'end_date': _formatDateForRequest(endDate),
        },
      );

      if (response.statusCode == 200) {
        return UzumStats.fromJson(response.data);
      }

      print('❌ Ошибка при получении статистики Uzum: Код ${response.statusCode}');
      return null;
    } on DioException catch (e) {
      print('❌ Ошибка при получении статистики Uzum: ${e.message}');
      return null;
    }
  }

  // Вспомогательный метод для форматирования даты в формат YYYY-MM-DD
  String _formatDateForRequest(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}