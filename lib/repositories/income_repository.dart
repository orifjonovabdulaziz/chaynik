import 'package:chaynik/dio/db/income_db.dart';
import 'package:chaynik/models/income.dart';
import 'package:chaynik/repositories/product_repository.dart';
import '../dio/services/income_service.dart';

class IncomeRepository {
  final IncomeService _incomeService = IncomeService();
  final IncomeDatabase _incomeDb = IncomeDatabase.instance;
  final ProductRepository _productRepository = ProductRepository();

  /// Получить приходы из локальной базы данных
  Future<List<Income>> getIncomesFromLocal() async {
    try {
      return await _incomeDb.getIncomes();
    } catch (e) {
      print("❌ Ошибка при получении приходов из локальной БД: $e");
      return [];
    }
  }

  /// Получить приходы с сервера и сохранить локально
  Future<List<Income>> getIncomesFromServerAndSave({
    String? createdAtAfter,
    String? createdAtBefore,
  }) async {
    try {
      List<Income> incomes = await _incomeService.getIncomes(
        createdAtAfter: createdAtAfter,
        createdAtBefore: createdAtBefore,
      );

      if (incomes.isNotEmpty) {
        await _incomeDb.insertIncomes(incomes);
        print("✅ Приходы обновлены и сохранены в локальную базу данных");
      }

      return incomes;
    } catch (e) {
      print("❌ Ошибка загрузки приходов с сервера: $e");
      return [];
    }
  }

  /// Создать один приход
  Future<bool> createIncome(Income income) async {
    try {
      final success = await _incomeService.createIncome(income);

      if (success) {
        // Обновляем количество товаров в локальной БД
        for (var item in income.items) {
          await _productRepository.increaseProductQuantity(
            item.product!,
            item.quantity,
          );
        }

        // Сохраняем приход в локальную БД
        await _incomeDb.insertIncomes([income]);

        print("✅ Приход успешно создан и сохранен локально");
        return true;
      }

      print("❌ Ошибка при создании прихода на сервере");
      return false;
    } catch (e) {
      print("❌ Ошибка при создании прихода: $e");
      return false;
    }
  }

  /// Создать несколько приходов
  Future<bool> createIncomes(List<Income> incomes) async {
    try {
      final createdIncomes = await _incomeService.createIncomes(incomes);

      if (createdIncomes != null) {
        // Обновляем количество товаров в локальной БД для каждого прихода
        for (var income in createdIncomes) {
          for (var item in income.items) {
            await _productRepository.increaseProductQuantity(
              item.product!,
              item.quantity,
            );
          }
        }

        // Сохраняем приходы в локальную БД
        await _incomeDb.insertIncomes(createdIncomes);

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

  /// Получить приходы по ID продукта
  Future<List<Income>> getIncomesByProductId(int productId) async {
    try {
      return await _incomeDb.getIncomesByProductId(productId);
    } catch (e) {
      print("❌ Ошибка при получении приходов по продукту: $e");
      return [];
    }
  }

  /// Удалить все приходы из локальной БД
  Future<void> deleteAllIncomes() async {
    try {
      await _incomeDb.deleteAllIncomes();
      print("✅ Все приходы успешно удалены из локальной БД");
    } catch (e) {
      print("❌ Ошибка при удалении всех приходов: $e");
    }
  }

  /// Получить приход по ID
  Future<Income?> getIncomeById(int id) async {
    try {
      return await _incomeDb.getIncomeById(id);
    } catch (e) {
      print("❌ Ошибка при получении прихода по ID: $e");
      return null;
    }
  }
}