import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../components/product/show_delete_product_dialog.dart';
import '../components/product/show_update_product_dialog.dart';
import '../components/shared/drawer.dart';
import '../components/product/AddProductDialog.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../provider/category_provider.dart';
import '../provider/product_provider.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  int? selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productProvider);
    final categoriesAsync = ref.watch(categoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Продукты'),
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
              ref.read(productProvider.notifier).fetchProducts();
              ref.read(categoryProvider.notifier).fetchCategories();
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
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
                        onSelected: (_) => setState(() => selectedCategoryId = null),
                      ),
                    );
                  }
                  final category = categories[index - 1];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: selectedCategoryId == category.id,
                      label: Text(category.title),
                      onSelected: (_) => setState(() => selectedCategoryId = category.id),
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
                    : products.where((p) => p.categoryId == selectedCategoryId).toList();

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
                    return ProductCard(
                      product: product,
                      categoryName: categoriesAsync.when(
                        loading: () => 'Загрузка...',
                        error: (_, __) => 'Ошибка',
                        data: (categories) => categories
                            .firstWhere((c) => c.id == product.categoryId,
                            orElse: () => Category(id: 0, title: 'Неизвестно', productCount: 0))
                            .title,
                      ),
                      onEdit: () {
                        showUpdateProductDialog(context, ref, product);
                      },
                      onDelete: () {
                        showDeleteProductDialog(context, ref, product);
                      },
                    );

                  },
                );
              },
            ),
          ),
      const SizedBox(height: 100)

        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddProductDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Обновленный ProductCard
class ProductCard extends StatelessWidget {
  final Product product;
  final String categoryName;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProductCard({
    Key? key,
    required this.product,
    required this.categoryName,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: product.imageUrl,
                width: 80,
                height: 80,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    categoryName,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${product.price} сум',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}