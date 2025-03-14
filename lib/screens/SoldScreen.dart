import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../components/sell/client_bottomsheet.dart';
import '../components/sell/pay_bottomsheet.dart';
import '../components/shared/drawer.dart';
import '../provider/sold_provider.dart';

class SoldScreen extends ConsumerWidget {
  const SoldScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saleState = ref.watch(soldProvider);
    final client = saleState.client;
    final products = saleState.products;
    final totalAmount = saleState.totalAmount;

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
                  client?.full_name ?? 'Не выбран',
                  style: TextStyle(
                    color: client != null
                        ? Colors.black
                        : Colors.grey,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => showClientBottomSheet(context, ref),
              ),
            ),

            Expanded(
              child: products.isEmpty
                  ? const Center(
                      child: Text('Нет выбранных товаров'),
                    )
                  : ListView.builder(
                      itemCount: products.length,
                      padding: const EdgeInsets.all(1),
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return Container(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: CachedNetworkImage(
                                        imageUrl: product.imageUrl,
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => Container(
                                          color: Colors.grey[200],
                                          child: const Center(child: CircularProgressIndicator()),
                                        ),
                                        errorWidget: (context, url, error) => Container(
                                          color: Colors.grey[200],
                                          child: const Icon(Icons.error),
                                        ),
                                      ),

                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product.title,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${product.quantity} шт × ${product.price} UZS',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                            ),
                                          ),

                                        ],
                                      ),
                                    ),
                                    Text(
                                      '${product.total} UZS',
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),

                                  ],
                                ),

                        const Divider(
                        height: 15,  // Высота пространства, которое занимает виджет
                        thickness: 1,  // Толщина самой линии
                        color: Colors.grey,  // Цвет линии
                        ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),


            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ElevatedButton(
                onPressed: () {
                  context.go("/addproducttosell");
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
                onPressed: client != null
                    ? () {
                  showPayBottomSheet(context);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: client != null && products.isNotEmpty
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
                  children: [
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
