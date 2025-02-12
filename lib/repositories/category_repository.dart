
import '../dio/db/category_db.dart';
import '../dio/services/category_service.dart';
import '../models/category.dart';

class CategoryRepository {
  final CategoryService _categoryService = CategoryService();
  final CategoryDatabase _categoryDatabase = CategoryDatabase.instance;

  /// 🔹 **Получение категорий из локальной базы данных**
  Future<List<Category>> getCategoriesFromLocal() async {
    return await _categoryDatabase.getCategories();
  }

  /// 🔹 **Получение категорий с сервера и обновление локальной базы**
  Future<List<Category>> getCategoriesFromServerAndSave() async {
    try {
      List<Category> categories = await _categoryService.getCategories();
      await _categoryDatabase.insertCategories(categories);
      print("Категории обновлены и сохранены в локальную базу данных");
      return categories;
    } catch (e) {
      print("Ошибка загрузки категорий с сервера: $e");
      return [];
    }
  }

  /// 🔹 **Добавление новой категории**
  Future<bool> addCategory(String title) async {
    try {
      // 1️⃣ Добавляем категорию на сервер
      Category? newCategory = await _categoryService.addCategory(title);
      if (newCategory != null) {
        // 2️⃣ Сохраняем новую категорию в локальную базу данных
        await _categoryDatabase.insertCategories([newCategory]);
        print("Новая категория успешно добавлена локально");
        return true;
      }
    } catch (e) {
      print("Ошибка при добавлении категории: $e");
    }
    return false;
  }
}
