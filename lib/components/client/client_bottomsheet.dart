import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../provider/client_provider.dart';
import '../../provider/sold_provider.dart';

void showClientBottomSheet(BuildContext context, WidgetRef ref) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Полоска для перетаскивания
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: Colors.grey[300],
                ),
              ),
            ),
            const Text(
              'Выберите клиента',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Поиск
            TextField(
              decoration: InputDecoration(
                hintText: 'Поиск клиента',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Список клиентов
            Expanded(
              child: Consumer(
                builder: (context, ref, child) {
                  final clientsAsync = ref.watch(clientProvider);

                  return clientsAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => Center(child: Text('Ошибка: $error')),
                    data: (clients) => ListView.builder(
                      itemCount: clients.length,
                      itemBuilder: (context, index) {
                        final client = clients[index];
                        return Card(
                          child: ListTile(
                            title: Text(client.full_name),
                            subtitle: Text(client.content),
                            trailing: Text(
                              '${client.debt} сум',
                              style: TextStyle(
                                color: client.debt > 0 ? Colors.red : Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onTap: () {
                              ref.read(currentSaleProvider.notifier).updateClient(client);
                              Navigator.pop(context);
                            },
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}