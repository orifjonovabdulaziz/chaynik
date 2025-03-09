import 'package:chaynik/models/client.dart';
import 'package:dio/dio.dart';

import 'api_service.dart';

class ClientService {
  /// 🔹 **Получить список всех клиентов**
  Future<List<Client>> getClients() async {
    try {
      Response response = await ApiService.dio.get('/api/client/');
      print(response.data);
      if (response.statusCode == 200) {
        List data = response.data;
        return data.map((json) => Client.fromJson(json)).toList();
      }
    } catch (e) {
      print("Ошибка получения клиентов: $e");
    }
    return [];
  }

  /// 🔹 **Добавить новый клиент**
  Future<Client?> addClient(String fullName, String content, double debt) async {
    try {

      Response response = await ApiService.dio.post(
        '/api/client/',
        data: {
          "full_name": fullName,
          "content": content,
          "debt": debt
        },
      );
      print(response.data);

      if (response.statusCode == 201 || response.statusCode == 200) {
        print("Клиент успешно добавлен");
        return Client.fromJson(response.data);
      }
    } catch (e) {
      print("Ошибка добавления клиента: $e");
    }
    return null;
  }

  /// 🔹 **Удалить клиента**
  Future<bool> deleteClient(int clientId) async {
    try {
      Response response =
      await ApiService.dio.delete('/api/client/$clientId/');

      if (response.statusCode == 204 || response.statusCode == 200) {
        print("Клиент успешно удален");
        return true;
      }

      print(
          "Ошибка удаления клиента: Неожиданный статус код ${response.statusCode}");
      return false;
    } catch (e) {
      print("Ошибка удаления клиента: $e");
      rethrow; // Пробрасываем ошибку дальше для обработки в repository
    }
  }

  /// 🔹 **Изменение клиента (PATCH)**
  Future<bool> updateClient(
      int clientId, {
        String? fullname,
        String? content,
        double? debt,
      }) async {
    try {
      Map<String, dynamic> updateData = {};

      if (fullname != null) updateData["full_name"] = fullname;
      if (content != null) updateData["content"] = content;
      if (debt != null) updateData["debt"] = debt.toString();


      if (updateData.isEmpty) {
        print("❌ Ошибка: Нет данных для обновления");
        return false;
      }

      Response response = await ApiService.dio.patch(
        '/api/client/$clientId/',
        data: updateData,
      );

      if (response.statusCode == 200) {
        print("✅ Клиент успешно обновлён");
        return true;
      }

      print("❌ Ошибка обновления клиента: Код ${response.statusCode}");
      return false;
    } catch (e) {
      print("❌ Ошибка обновления клиента: $e");
      rethrow;
    }
  }
}