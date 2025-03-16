import 'package:chaynik/dio/db/income_db.dart';
import 'package:chaynik/models/income.dart';
import 'package:chaynik/repositories/product_repository.dart';
import '../dio/services/income_service.dart';

class IncomeRepository {
  final IncomeService _incomeService = IncomeService();
  final IncomeDatabase _incomeDb = IncomeDatabase.instance;
  final ProductRepository _productRepository = ProductRepository();

  Future<List<Income>> getIncomesFromLocal() async {
    return await _incomeDb.getIncomes();
  }

  Future<List<Income>> getIncomesFromServerAndSave() async {
    try {
      List<Income> incomes = await _incomeService.getIncomes();
      await _incomeDb.insertIncomes(incomes);
      print("✅ Приходы обновлены и сохранены в локальную базу данных");
      return incomes;
    } catch (e) {
      print("❌ Ошибка загрузки приходов с сервера: $e");
      return [];
    }
  }

  Future<bool> createIncomes(List<Income> items) async {
    try {
      // Отправляем приходы на сервер
      final incomes = await _incomeService.addIncome(items);

      if (incomes != null) {
        // Сохраняем приходы в локальную БД
        await _incomeDb.insertIncomes(incomes);
        await _productRepository.getProductsFromServerAndSave();



        print("✅ Приходы успешно созданы и сохранены локально");
        return true;
      }

      print("❌ Ошибка при создании приходов на сервере");
      return false;
    } catch (e) {
      print("❌ Ошибка при создании приходов: $e");
      return false;
    }
  }

  Future<List<Income>> getIncomesByProductId(int productId) async {
    try {
      return await _incomeDb.getIncomesByProductId(productId);
    } catch (e) {
      print("❌ Ошибка при получении приходов по продукту: $e");
      return [];
    }
  }

  Future<void> deleteAllIncomes() async {
    try {
      await _incomeDb.deleteAllIncomes();
      print("✅ Все приходы успешно удалены из локальной БД");
    } catch (e) {
      print("❌ Ошибка при удалении всех приходов: $e");
    }
  }
}