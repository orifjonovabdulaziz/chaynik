import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../components/client/client_bottomsheet.dart';
import '../components/shared/drawer.dart';
import '../provider/client_provider.dart';
import '../provider/sold_provider.dart';

class SoldScreen extends ConsumerWidget {
  const SoldScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSale = ref.watch(currentSaleProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Новая продажа'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () =>
                Scaffold.of(context).openDrawer(), // Открывает Drawer
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.refresh(clientProvider);
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Карточка клиента
            Card(
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: const Text('Клиент'),
                subtitle: Text(
                  currentSale?.client?.full_name ?? 'Не выбран',
                  style: TextStyle(
                    color: currentSale?.client != null
                        ? Colors.black
                        : Colors.grey,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => showClientBottomSheet(context, ref),
              ),
            ),
            const Spacer(),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ElevatedButton(
                onPressed: () {
                  // Действие для выбора товара
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.add),
                    SizedBox(width: 8),
                    Text('Выбрать товар'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Кнопка сканирования
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ElevatedButton(
                onPressed: currentSale.client != null
                    ? () {
                        // Логика оплаты
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: currentSale.client != null
                      ? const Color(0xFF25D366)
                      : Colors.grey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    SizedBox(width: 8),
                    Text('Оплатить'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
