import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/product_repository.dart';
import '../models/product.dart';

// Провайдер для поискового запроса
final searchQueryProvider = StateProvider<String>((ref) => '');

// Провайдер для фильтрации по категории
final selectedCategoryProvider = StateProvider<int?>((ref) => null);

// Основной провайдер продуктов
final productProvider = StateNotifierProvider<ProductNotifier, AsyncValue<List<Product>>>(
      (ref) => ProductNotifier(ProductRepository()),
);

// Провайдер отфильтрованных продуктов
final filteredProductsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  final products = ref.watch(productProvider);
  final searchQuery = ref.watch(searchQueryProvider).toLowerCase();
  final selectedCategory = ref.watch(selectedCategoryProvider);

  return products.when(
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
    data: (products) {
      var filteredProducts = List<Product>.from(products);

      // Фильтрация по поиску
      if (searchQuery.isNotEmpty) {
        filteredProducts = filteredProducts.where((product) {
          return product.title.toLowerCase().contains(searchQuery);
        }).toList();
      }

      // Фильтрация по категории
      if (selectedCategory != null) {
        filteredProducts = filteredProducts.where((product) {
          return product.categoryId == selectedCategory;
        }).toList();
      }

      return AsyncValue.data(filteredProducts);
    },
  );
});

class ProductNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  final ProductRepository _repository;

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

  Future<void> addProduct(String name, double price, String imageUrl, int categoryId) async {
    try {
      final success = await _repository.addProduct(name, price, imageUrl, categoryId);
      if (success) {
        await fetchProducts();
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      final success = await _repository.deleteProduct(id);
      if (success) {
        await fetchProducts();
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> updateProduct(
      int productId, {
        String? title,
        int? category,
        String? image,
        double? price,
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
        await fetchProducts();
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> clearAllProductsData() async {
    try {
      state = const AsyncValue.data([]);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  List<Product> searchProducts(String query) {
    return state.when(
      loading: () => [],
      error: (_, __) => [],
      data: (products) {
        return products.where((product) {
          return product.title.toLowerCase().contains(query.toLowerCase());
        }).toList();
      },
    );
  }
}