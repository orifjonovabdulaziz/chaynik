import 'package:chaynik/repositories/product_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product.dart';


final productProvider = StateNotifierProvider<ProductNotifier, AsyncValue<List<Product>>>(
        (ref) => ProductNotifier(ProductRepository())
);


class ProductNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  late final ProductRepository _repository;

  ProductNotifier(this._repository) : super(const AsyncValue.loading()) {
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      state = const AsyncValue.loading();
      final products = await _repository.getProductsFromLocal();
      state = AsyncValue.data(products);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addProduct(name, price, imageUrl, categoryId) async {
    bool success = await _repository.addProduct(name, price, imageUrl, categoryId);
    if (success) {
      fetchProducts();
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      await _repository.deleteProduct(id);
      fetchProducts(); // Перезагружаем список после удаления
    } catch (e) {
      print('Error deleting product: $e');
    }
  }

  Future<void> updateProduct(int productId, {
    String? title,
    int? category,
    String? image,
    double? price
  }) async {
    try {
      final success = await _repository.updateProduct(
        productId,
        title: title,
        category: category,
        image: image,
        price: price,
      );

      if (success) {
        fetchProducts(); // Перезагружаем список продуктов после обновления
      }
    } catch (e) {
      print('Error updating product: $e');
    }
  }

}