import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/category.dart';
import '../../provider/category_provider.dart';
import '../../provider/product_provider.dart';
import '../../provider/sold_provider.dart';
import '../product/AddProductDialog.dart';
import '../product/ProductCard.dart';
import '../product/show_delete_product_dialog.dart';
import '../product/show_update_product_dialog.dart';
import 'ProductToSellCard.dart';

class AddProductSellScreen extends ConsumerStatefulWidget {
  const AddProductSellScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AddProductSellScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<AddProductSellScreen> {
  int? selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productProvider);
    final categoriesAsync = ref.watch(categoryProvider);

    final saleState = ref.watch(soldProvider);
    final products = saleState.products;
    final totalAmount = saleState.totalAmount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Продукты'),
      ),
      body: Column(
        children: [
          // Фильтр категорий
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: categoriesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Ошибка: $error')),
              data: (categories) => ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: categories.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: selectedCategoryId == null,
                        label: const Text('Все'),
                        onSelected: (_) =>
                            setState(() => selectedCategoryId = null),
                      ),
                    );
                  }
                  final category = categories[index - 1];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: selectedCategoryId == category.id,
                      label: Text(category.title),
                      onSelected: (_) =>
                          setState(() => selectedCategoryId = category.id),
                    ),
                  );
                },
              ),
            ),
          ),

          // Список продуктов
          Expanded(
            child: productsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Ошибка: $error')),
              data: (products) {
                final filteredProducts = selectedCategoryId == null
                    ? products
                    : products
                    .where((p) => p.categoryId == selectedCategoryId)
                    .toList();

                if (filteredProducts.isEmpty) {
                  return const Center(
                    child: Text('Нет продуктов'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    return ProductToSellCard(
                      product: product,
                      categoryName: categoriesAsync.when(
                        loading: () => 'Загрузка...',
                        error: (_, __) => 'Ошибка',
                        data: (categories) => categories
                            .firstWhere((c) => c.id == product.categoryId,
                            orElse: () => Category(
                                id: 0,
                                title: 'Неизвестно',
                                productCount: 0))
                            .title,
                      ),

                    );
                  },
                );
              },
            ),
          ),


        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, -1),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: ()  {
              // Ваше действие
              context.go('/sold');
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Готово',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (products.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Text(
                    '${totalAmount.toStringAsFixed(2)} UZS',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),

    );
  }
}