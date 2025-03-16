import 'package:chaynik/repositories/product_repository.dart';
import '../models/product.dart';
import '../models/sold.dart';
import '../dio/services/sold_service.dart';
import 'client_repository.dart';
import '../dio/db/sold_db.dart';

class SoldRepository {
  final SoldService _soldService = SoldService();
  final ProductRepository _productRepository = ProductRepository();
  final ClientRepository _clientRepository = ClientRepository();
  final SoldDatabase _soldDb = SoldDatabase.instance;

  // Создание продажи
  Future<bool> createSale(
      int clientId,
      double paid,
      List<SoldItem> items,
      ) async {
    try {
      final sold = Sold(
        client: clientId,
        paid: paid,
        outcome: items,
      );

      final success = await _soldService.createSold(sold);
      if (success) {
        for (var item in items) {
          await _productRepository.decreaseProductQuantity(
            int.parse(item.product.toString()),
            int.parse(item.quantity.toString()),
          );
        }

        await _clientRepository.updateClientFromServer(clientId);
        print('✅ Продажа успешно создана');
      }
      return success;
    } catch (e) {
      print('❌ Ошибка при создании продажи: $e');
      return false;
    }
  }

  // Получение продаж из локальной БД
  Future<List<Sold>> getSoldsFromLocal() async {
    try {
      return await _soldDb.getSolds();
    } catch (e) {
      print('❌ Ошибка при получении продаж из локальной БД: $e');
      return [];
    }
  }

  // Получение и сохранение продаж с сервера
  Future<List<Sold>> getSoldsFromServerAndSave({
    int? client,
    String? createdAtAfter,
    String? createdAtBefore,
  }) async {
    try {
      final sales = await _soldService.getSolds(
        client: client,
        createdAtAfter: createdAtAfter,
        createdAtBefore: createdAtBefore,
      );

      if (sales.isNotEmpty) {
        await _soldDb.insertSolds(sales);
        print('✅ Продажи успешно обновлены в локальной БД');
      }

      return sales;
    } catch (e) {
      print('❌ Ошибка при получении продаж с сервера: $e');
      return [];
    }
  }

  // Получение продаж по клиенту из локальной БД
  Future<List<Sold>> getSoldsByClientFromLocal(int clientId) async {
    try {
      return await _soldDb.getSoldsByClientId(clientId);
    } catch (e) {
      print('❌ Ошибка при получении продаж клиента из локальной БД: $e');
      return [];
    }
  }

  // Получение продаж за период из локальной БД
  Future<List<Sold>> getSoldsByDateRange(
      String startDate,
      String endDate,
      ) async {
    try {
      return await _soldService.getSolds(
        createdAtAfter: startDate,
        createdAtBefore: endDate,);
    } catch (e) {
      print('❌ Ошибка при получении продаж за период из локальной БД: $e');
      return [];
    }
  }

  // Получение статистики продаж
  Future<Map<String, double>> getSalesStatistics({
    int? clientId,
    String? startDate,
    String? endDate,
  }) async {
    try {
      List<Sold> sales;
      if (clientId != null) {
        sales = await getSoldsByClientFromLocal(clientId);
      } else if (startDate != null && endDate != null) {
        sales = await getSoldsByDateRange(startDate, endDate);
      } else {
        sales = await getSoldsFromLocal();
      }

      double totalSales = 0;
      double totalPaid = 0;
      double totalDebt = 0;

      for (var sale in sales) {
        totalSales += sale.total ?? 0;
        totalPaid += sale.paid;
        totalDebt += sale.debt ?? 0;
      }

      return {
        'totalSales': totalSales,
        'totalPaid': totalPaid,
        'totalDebt': totalDebt,
      };
    } catch (e) {
      print('❌ Ошибка при получении статистики продаж: $e');
      return {
        'totalSales': 0,
        'totalPaid': 0,
        'totalDebt': 0,
      };
    }
  }

  // Очистка локальной БД
  Future<void> clearLocalSolds() async {
    try {
      await _soldDb.deleteAllSolds();
      print('✅ Локальная база продаж очищена');
    } catch (e) {
      print('❌ Ошибка при очистке локальной базы продаж: $e');
    }
  }

  // Синхронизация с сервером
  Future<void> syncWithServer() async {
    try {
      await getSoldsFromServerAndSave();
      print('✅ Синхронизация с сервером завершена');
    } catch (e) {
      print('❌ Ошибка при синхронизации с сервером: $e');
    }
  }

  Future<Map<int, String>> getClientsMap() async {
    final clients = await _clientRepository.getClientsFromLocal();
    return {for (var client in clients) client.id: client.full_name};
  }

  Future<Map<int, Product>> getProductsMap() async {
    final products = await _productRepository.getProductsFromLocal();
    return {for (var product in products) product.id: product};
  }
}