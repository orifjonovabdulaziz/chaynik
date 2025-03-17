import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import '../repositories/category_repository.dart';

// Провайдер для поискового запроса
final categorySearchQueryProvider = StateProvider<String>((ref) => '');

// Основной провайдер категорий
final categoryProvider = StateNotifierProvider<CategoryNotifier, AsyncValue<List<Category>>>(
      (ref) => CategoryNotifier(CategoryRepository()),
);

// Провайдер отфильтрованных категорий
final filteredCategoriesProvider = Provider<AsyncValue<List<Category>>>((ref) {
  final categoriesAsync = ref.watch(categoryProvider);
  final searchQuery = ref.watch(categorySearchQueryProvider).toLowerCase();

  return categoriesAsync.when(
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
    data: (categories) {
      if (searchQuery.isEmpty) {
        return AsyncValue.data(categories);
      }

      final filteredCategories = categories.where((category) {
        return category.title.toLowerCase().contains(searchQuery);
      }).toList();

      return AsyncValue.data(filteredCategories);
    },
  );
});

class CategoryNotifier extends StateNotifier<AsyncValue<List<Category>>> {
  final CategoryRepository _repository;

  CategoryNotifier(this._repository) : super(const AsyncValue.loading()) {
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      state = const AsyncValue.loading();
      final categories = await _repository.getCategoriesFromLocal();
      state = AsyncValue.data(categories);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addCategory(String title) async {
    try {
      final success = await _repository.addCategory(title);
      if (success) {
        await fetchCategories();
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> deleteCategory(int categoryId) async {
    try {
      final success = await _repository.deleteCategory(categoryId);
      if (success) {
        await fetchCategories();
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> updateCategory(int categoryId, {String? title}) async {
    try {
      final success = await _repository.updateCategory(categoryId, title!);
      if (success) {
        await fetchCategories();
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  void clearCategories() {
    state = const AsyncValue.data([]);
  }

  // Метод для поиска категорий
  List<Category> searchCategories(String query) {
    return state.when(
      loading: () => [],
      error: (_, __) => [],
      data: (categories) {
        if (query.isEmpty) return categories;

        return categories.where((category) {
          return category.title.toLowerCase().contains(query.toLowerCase());
        }).toList();
      },
    );
  }
}