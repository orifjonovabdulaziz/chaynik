import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../components/shared/drawer.dart';
import '../provider/income_provider.dart';
import '../provider/product_provider.dart';

class IncomeScreen extends ConsumerWidget {
  const IncomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(incomeProvider);
    final products = state.products;
    final totalAmount = state.totalAmount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Новый Приход'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: const AppDrawer(),
      body: Stack(
        children: [
          if (state.isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
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
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: CachedNetworkImage(
                                            imageUrl: product.imageUrl,
                                            width: 60,
                                            height: 60,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                Container(
                                              color: Colors.grey[200],
                                              child: const Center(
                                                  child:
                                                      CircularProgressIndicator()),
                                            ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Container(
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
                                                '${product.quantity} шт × ${product.price} \$',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          '${product.total} \$',
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Divider(
                                      height: 15,
                                      thickness: 1,
                                      color: Colors.grey,
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
                      context.go("/addproducttoincome");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add),
                        SizedBox(width: 8),
                        Text('Выбрать товар'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ElevatedButton(
                    onPressed: products.isNotEmpty
                        ? () async {
                            try {
                              await ref
                                  .read(incomeProvider.notifier)
                                  .createIncome();
                              await ref
                                  .read(productProvider.notifier)
                                  .fetchProducts();

                              if (!context.mounted) return;

                              if (ref.read(incomeProvider).error == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Приход успешно создан'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                context
                                    .go('/income'); // или другой нужный маршрут
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text(ref.read(incomeProvider).error!),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Ошибка: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: products.isNotEmpty
                          ? const Color(0xFF25D366)
                          : Colors.grey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(width: 8),
                        Text('Подтвердить Приход'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
