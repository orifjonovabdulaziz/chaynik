import 'package:chaynik/repositories/product_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product.dart';


final productProvider = StateNotifierProvider<ProductNotifier, List<Product>>(
        (ref) => ProductNotifier(ProductRepository())
);


class ProductNotifier extends StateNotifier<List<Product>> {
  late final ProductRepository _repository;

  ProductNotifier(this._repository) : super([]) {
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final categories = await _repository.getProductsFromLocal();
    state = categories;
  }

  Future<void> addProduct(name, price, imageUrl, categoryId) async {
    bool success = await _repository.addProduct(name, price, imageUrl, categoryId);
    if (success) {
      fetchProducts();
    }
  }

}