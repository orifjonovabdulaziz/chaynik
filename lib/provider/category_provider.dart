import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import '../repositories/category_repository.dart';


final categoryProvider = StateNotifierProvider<CategoryNotifier, List<Category>>(
      (ref) => CategoryNotifier(CategoryRepository()),
);


class CategoryNotifier extends StateNotifier<List<Category>> {
  final CategoryRepository _repository;

  CategoryNotifier(this._repository) : super([]) {
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    final categories = await _repository.getCategoriesFromLocal();
    state = categories;
  }

  Future<void> addCategory(String title) async {
    bool success = await _repository.addCategory(title);
    if (success) {
      fetchCategories();
    }
  }
}


