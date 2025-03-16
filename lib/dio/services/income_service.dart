import 'package:dio/dio.dart';
import '../../models/income.dart';
import 'api_service.dart';

class IncomeService {
  /// 🔹 **Получить список всех приходов**
  Future<List<Income>> getIncomes() async {
    try {
      Response response = await ApiService.dio.get('/api/income/');

      if (response.statusCode == 200) {
        List data = response.data;
        return data.map((json) => Income.fromJson(json)).toList();
      }

      print("❌ Ошибка получения приходов: Код ${response.statusCode}");
      return [];
    } catch (e) {
      print("❌ Ошибка получения приходов: $e");
      return [];
    }
  }

  /// 🔹 **Добавить новый приход**
  Future<List<Income>?> addIncome(List<Income> items) async {
    try {
      final List<Map<String, dynamic>> itemsJson =
      items.map((item) => item.toJson()).toList();

      Response response = await ApiService.dio.post(
        '/api/income/list-create/',
        data: itemsJson,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print("✅ Приходы успешно добавлены");
        List data = response.data;
        return data.map((json) => Income.fromJson(json)).toList();
      }

      print("❌ Ошибка добавления приходов: Код ${response.statusCode}");
      return null;
    } catch (e) {
      print("❌ Ошибка добавления приходов: $e");
      return null;
    }
  }


}