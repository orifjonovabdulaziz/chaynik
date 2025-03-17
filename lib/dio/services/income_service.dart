import 'package:dio/dio.dart';
import '../../models/income.dart';
import 'api_service.dart';

class IncomeService {
  /// 🔹 **Получить список всех приходов**
  Future<List<Income>> getIncomes({
    String? createdAtAfter,
    String? createdAtBefore,
  }) async {
    try {
      final Map<String, dynamic> queryParameters = {
        if (createdAtAfter != null) 'created_at_after': createdAtAfter,
        if (createdAtBefore != null) 'created_at_before': createdAtBefore,
      };

      Response response = await ApiService.dio.get(
        '/api/income/',
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        List data = response.data;
        return data.map((json) => Income.fromJson(json)).toList();
      }

      print("❌ Ошибка получения приходов: Код ${response.statusCode}");
      return [];
    } on DioException catch (e) {
      print("❌ Ошибка получения приходов: ${e.message}");
      return [];
    }
  }

  /// 🔹 **Создать новый приход**
  Future<bool> createIncome(Income income) async {
    try {
      Response response = await ApiService.dio.post(
        '/api/income/',
        data: income.toJson(),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print("✅ Приход успешно создан");
        return true;
      }

      print("❌ Ошибка создания прихода: Код ${response.statusCode}");
      return false;
    } on DioException catch (e) {
      print("❌ Ошибка создания прихода: ${e.message}");
      return false;
    }
  }

  /// 🔹 **Создать несколько приходов**
  Future<List<Income>?> createIncomes(List<Income> incomes) async {
    try {
      final List<Map<String, dynamic>> incomesJson =
      incomes.map((income) => income.toJson()).toList();

      Response response = await ApiService.dio.post(
        '/api/income/list-create/',
        data: incomesJson,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print("✅ Приходы успешно созданы");
        List data = response.data;
        return data.map((json) => Income.fromJson(json)).toList();
      }

      print("❌ Ошибка создания приходов: Код ${response.statusCode}");
      return null;
    } on DioException catch (e) {
      print("❌ Ошибка создания приходов: ${e.message}");
      return null;
    }
  }
}