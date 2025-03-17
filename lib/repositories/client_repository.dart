import 'package:chaynik/dio/db/client_db.dart';
import 'package:chaynik/models/client.dart';
import '../dio/services/client_service.dart';

class ClientRepository {
  final ClientService _clientService = ClientService();
  final ClientDatabase _clientDb = ClientDatabase.instance;

  Future<List<Client>> getClientsFromLocal() async {
    return await _clientDb.getClients();
  }

  Future<List<Client>> getClientsFromServerAndSave() async {
    try {
      List<Client> clients = await _clientService.getClients();
      await _clientDb.insertClients(clients);
      print("Клиенты обновлены и сохранены в локальную базу данных");
      return clients;
    } catch (e) {
      print("Ошибка загрузки клиентов с сервера: $e");
      return [];
    }
  }

  /// Обновляет данные клиента в локальной БД, получая свежие данные с сервера
  Future<bool> updateClientFromServer(int clientId) async {
    try {
      // 1️⃣ Получаем свежие данные с сервера
      final Client? serverClient = await _clientService.getClientById(clientId);

      if (serverClient != null) {
        // 2️⃣ Обновляем данные только этого клиента в локальной БД
        await _clientDb.insertClients([serverClient]);
        print("✅ Данные клиента успешно обновлены из сервера");
        return true;
      }

      print("❌ Не удалось получить данные клиента с сервера");
      return false;

    } catch (e) {
      print("❌ Ошибка при обновлении данных клиента из сервера: $e");
      return false;
    }
  }

  Future<bool> addClient(String fullName, String content, double debt) async {
    try {
      Client? newClient = await _clientService.addClient(fullName, content, debt);
      if (newClient != null) {
        await _clientDb.insertClients([newClient]);
        print("Новый клиент успешно добавлен локально");
        return true;
      }
    } catch (e) {
      print("Ошибка при добавлении клиента: $e");
    }
    return false;
  }



  Future<bool> deleteClient(int clientId) async {
    try {
      final success = await _clientService.deleteClient(clientId);
      if (success) {
        // Удаляем клиента из локальной базы данных
        await _clientDb.deleteClient(clientId);
      }
      return success;
    } catch (e) {
      print("Ошибка в репозитории при удалении клиента: $e");
      throw e; // Пробрасываем ошибку дальше для обработки в UI
    }
  }


  Future<bool> deleteAllClients() async {
    try {
        // Удаляем клиента из локальной базы данных
        await _clientDb.deleteAllClients();
        return true;

    } catch (e) {
      print("Ошибка в репозитории при удалении клиента: $e");
      throw e; // Пробрасываем ошибку дальше для обработки в UI
    }
  }

  Future<bool> updateClient(int clientId, {
    String? fullName,
    String? content,
    double? debt,
    String? createdAt,
    String? updatedAt,
  }) async {
    try {
      // 1️⃣ Обновляем клиента в API
      final success = await _clientService.updateClient(
        clientId,
        fullname: fullName,
        content: content,
        debt: debt,
      );

      if (success) {
        // 2️⃣ Если API обновление успешно, обновляем клиента в локальной БД
        await _clientDb.updateClient(
          clientId,
          fullName: fullName,
          content: content,
          debt: debt,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );
      }

      return success;
    } catch (e) {
      print("❌ Ошибка в репозитории при обновлении клиента: $e");
      throw e; // Пробрасываем ошибку дальше для обработки в UI
    }
  }
}