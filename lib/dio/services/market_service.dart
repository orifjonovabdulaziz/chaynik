import 'package:dio/dio.dart';
import '../../models/market.dart';
import 'api_service.dart';

class MarketService {
  /// 🔹 **GET-запрос для получения списка маркетов**
  Future<List<Market>> getMarkets() async {
    try {
      Response response = await ApiService.dio.get('/api/market/');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Market.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      print('❌ Ошибка при получении маркетов: ${e.message}');
      return [];
    }
  }

  /// 🔹 **POST-запрос для создания нового маркета**
  Future<Market?> createMarket({
    required String name,
    required String token,
    required String shopId,
  }) async {
    try {
      Response response = await ApiService.dio.post(
        '/api/market/',
        data: {
          "token": token,
          "shop_id": shopId,
          "name": name,
        },
      );

      if (response.statusCode == 201) {
        return Market.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      print('❌ Ошибка при создании маркета: ${e.message}');
      return null;
    }
  }

  /// 🔹 **DELETE-запрос для удаления маркета**
  Future<bool> deleteMarket(int id) async {
    try {
      Response response = await ApiService.dio.delete('/api/market/$id/');

      return response.statusCode == 204;
    } on DioException catch (e) {
      print('❌ Ошибка при удалении маркета: ${e.message}');
      return false;
    }
  }
}