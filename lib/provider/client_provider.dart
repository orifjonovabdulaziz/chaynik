import 'package:chaynik/repositories/client_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/client.dart';

// Провайдер для поискового запроса
final searchQueryProvider = StateProvider<String>((ref) => '');

// Провайдер для отфильтрованных клиентов
final filteredClientsProvider = Provider<AsyncValue<List<Client>>>((ref) {
  final clients = ref.watch(clientProvider);
  final searchQuery = ref.watch(searchQueryProvider).toLowerCase();

  return clients.when(
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
    data: (clients) {
      if (searchQuery.isEmpty) return AsyncValue.data(clients);

      final filteredClients = clients.where((client) {
        return client.full_name.toLowerCase().contains(searchQuery);
      }).toList();

      return AsyncValue.data(filteredClients);
    },
  );
});

final clientProvider = StateNotifierProvider<ClientNotifier, AsyncValue<List<Client>>>(
      (ref) => ClientNotifier(ClientRepository()),
);

class ClientNotifier extends StateNotifier<AsyncValue<List<Client>>> {
  final ClientRepository _repository;

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
    try {
      bool success = await _repository.addClient(fullName, content, debt);
      if (success) {
        fetchClients();
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> deleteClient(int id) async {
    try {
      await _repository.deleteClient(id);
      fetchClients();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
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
        fetchClients();
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      print('Ошибка при обновлении клиента: $e');
    }
  }

  Future<void> clearAllClientsData() async {
    try {
      state = const AsyncValue.data([]);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      print('Ошибка при очистке данных клиентов: $e');
    }
  }
}