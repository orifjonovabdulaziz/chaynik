import '../dio/db/market_db.dart';
import '../models/market.dart';
import '../dio/services/market_service.dart';

class MarketRepository {
  final MarketService _marketService = MarketService();
  final MarketDatabase _marketDb = MarketDatabase.instance;

  /// 🔹 **Получение маркетов из локальной БД**
  Future<List<Market>> getMarketsFromLocal() async {
    return await _marketDb.getMarkets();
  }

  /// 🔹 **Получение маркетов с сервера и сохранение в локальную БД**
  Future<List<Market>> getMarketsFromServerAndSave() async {
    try {
      List<Market> markets = await _marketService.getMarkets();
      await _marketDb.insertMarkets(markets);
      print("✅ Маркеты обновлены и сохранены в локальную базу данных");
      return markets;
    } catch (e) {
      print("❌ Ошибка загрузки маркетов с сервера: $e");
      return [];
    }
  }

  /// 🔹 **Добавление нового маркета**
  Future<bool> addMarket({
    required String name,
    required String token,
    required String shopId,
  }) async {
    try {
      Market? newMarket = await _marketService.createMarket(
        name: name,
        token: token,
        shopId: shopId,
      );

      if (newMarket != null) {
        await _marketDb.insertMarkets([newMarket]);
        print("✅ Новый маркет успешно добавлен локально");
        return true;
      }
    } catch (e) {
      print("❌ Ошибка при добавлении маркета: $e");
    }
    return false;
  }

  /// 🔹 **Удаление маркета**
  Future<bool> deleteMarket(int marketId) async {
    try {
      final success = await _marketService.deleteMarket(marketId);
      if (success) {
        await _marketDb.deleteMarket(marketId);
        print("✅ Маркет успешно удален");
        return true;
      }
      print("❌ Не удалось удалить маркет на сервере");
      return false;
    } catch (e) {
      print("❌ Ошибка в репозитории при удалении маркета: $e");
      throw e;
    }
  }

  /// 🔹 **Синхронизация с сервером**
  Future<void> syncWithServer() async {
    try {
      await _marketDb.deleteAllMarkets();
      await getMarketsFromServerAndSave();
      print("✅ Синхронизация с сервером успешно завершена");
    } catch (e) {
      print("❌ Ошибка при синхронизации с сервером: $e");
      throw e;
    }
  }

  /// 🔹 **Получение маркета по ID**
  Future<Market?> getMarketById(int marketId) async {
    try {
      return await _marketDb.getMarketById(marketId);
    } catch (e) {
      print("❌ Ошибка при получении маркета по ID: $e");
      return null;
    }
  }

  /// 🔹 **Проверка существования маркета**
  Future<bool> marketExists(int marketId) async {
    try {
      return await _marketDb.marketExists(marketId);
    } catch (e) {
      print("❌ Ошибка при проверке существования маркета: $e");
      return false;
    }
  }

  /// 🔹 **Получение количества маркетов**
  Future<int> getMarketsCount() async {
    try {
      return await _marketDb.getMarketsCount();
    } catch (e) {
      print("❌ Ошибка при получении количества маркетов: $e");
      return 0;
    }
  }

  /// 🔹 **Очистка данных**
  Future<void> clearAllData() async {
    try {
      await _marketDb.deleteAllMarkets();
      print("✅ Все данные успешно очищены");
    } catch (e) {
      print("❌ Ошибка при очистке данных: $e");
      throw e;
    }
  }

  /// 🔹 **Закрытие репозитория**
  Future<void> dispose() async {
    try {
      await _marketDb.close();
      print("✅ Репозиторий успешно закрыт");
    } catch (e) {
      print("❌ Ошибка при закрытии репозитория: $e");
      throw e;
    }
  }
}