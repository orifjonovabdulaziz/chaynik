import 'package:chaynik/repositories/client_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/client.dart';

final clientProvider = StateNotifierProvider<ClientNotifier, AsyncValue<List<Client>>>(
      (ref) => ClientNotifier(ClientRepository()),
);

class ClientNotifier extends StateNotifier<AsyncValue<List<Client>>> {
  late final ClientRepository _repository;

  ClientNotifier(this._repository) : super(const AsyncValue.loading()) {
    fetchClients();
  }

  Future<void> fetchClients() async {
    try {
      state = const AsyncValue.loading();
      final clients = await _repository.getClientsFromLocal();
      state = AsyncValue.data(clients);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addClient(String fullName, String content, double debt) async {
    bool success = await _repository.addClient(fullName, content, debt);
    if (success) {
      fetchClients(); // Перезагружаем список после добавления
    }
  }

  Future<void> deleteClient(int id) async {
    try {
      await _repository.deleteClient(id);
      fetchClients(); // Перезагружаем список после удаления
    } catch (e) {
      print('Ошибка при удалении клиента: $e');
    }
  }

  Future<void> updateClient(int clientId, {
    String? fullName,
    String? content,
    double? debt,
    String? createdAt,
    String? updatedAt,
  }) async {
    try {
      final success = await _repository.updateClient(
        clientId,
        fullName: fullName,
        content: content,
        debt: debt,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      if (success) {
        fetchClients(); // Перезагружаем список клиентов после обновления
      }
    } catch (e) {
      print('Ошибка при обновлении клиента: $e');
    }
  }
}