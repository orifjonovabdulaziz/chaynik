import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import '../repositories/category_repository.dart';


final categoryProvider = StateNotifierProvider<CategoryNotifier, AsyncValue<List<Category>>>(
      (ref) => CategoryNotifier(CategoryRepository()),
);


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
    bool success = await _repository.addCategory(title);
    if (success) {
      fetchCategories();
    }
  }
}


