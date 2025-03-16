import '../models/uzum.dart';
import '../dio/services/uzum_service.dart';

class UzumRepository {
  final UzumService _uzumService = UzumService();

  /// Получение статистики Uzum за текущий день
  Future<UzumStats?> getTodayStats(int marketId) async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final stats = await _uzumService.getUzumStats(
        marketId: marketId,
        startDate: today,
        endDate: today,
      );

      if (stats != null) {
        print('✅ Статистика Uzum за сегодня успешно получена');
      }
      return stats;
    } catch (e) {
      print('❌ Ошибка при получении статистики Uzum за сегодня: $e');
      return null;
    }
  }

  /// Получение статистики Uzum за период
  Future<UzumStats?> getStatsByDateRange({
    required int marketId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final stats = await _uzumService.getUzumStats(
        marketId: marketId,
        startDate: startDate,
        endDate: endDate,
      );

      if (stats != null) {
        print('✅ Статистика Uzum за период успешно получена');
      }
      return stats;
    } catch (e) {
      print('❌ Ошибка при получении статистики Uzum за период: $e');
      return null;
    }
  }
}