import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../components/client/ClientCard.dart';
import '../components/client/show_delete_client_dialog.dart';
import '../components/client/show_update_client_dialog.dart';
import '../components/shared/drawer.dart';
import '../components/client/AddClientDialog.dart';
import '../models/client.dart';
import '../provider/client_provider.dart';

class ClientsScreen extends ConsumerStatefulWidget {
  const ClientsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends ConsumerState<ClientsScreen> {
  @override
  Widget build(BuildContext context) {
    final clientsAsync = ref.watch(clientProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Клиенты'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(), // Открывает Drawer
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(clientProvider.notifier).fetchClients();
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: clientsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Ошибка: $error')),
        data: (clients) {
          if (clients.isEmpty) {
            return const Center(
              child: Text('Нет клиентов'),
            );
          }

          return Column(
            children: [
              Expanded(
                child:
                  ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: clients.length,
                    itemBuilder: (context, index) {
                      final client = clients[index];
                      return ClientCard(
                        client: client,
                        onEdit: () {
                          showUpdateClientDialog(context, ref, client);
                        },
                        onDelete: () {
                          showDeleteClientDialog(context, ref, client);
                        },
                      );
                    },

                  ),

              ),
              const SizedBox(height: 100)

            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddClientDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}