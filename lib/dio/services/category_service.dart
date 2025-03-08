import 'package:dio/dio.dart';
import '../../models/category.dart';
import '../services/api_service.dart'; // Общий сервис для Dio

class CategoryService {
  /// 🔹 **Получение всех категорий (GET /api/category/)**
   Future<List<Category>> getCategories() async {
    try {
      Response response = await ApiService.dio.get('/api/category/');
      if (response.statusCode == 200) {
        List data = response.data;
        return data.map((json) => Category.fromJson(json)).toList();
      }
    } on DioException catch (e) {
      print("Ошибка получения категорий: ${e.message}");
    }
    return [];
  }

  /// 🔹 **Добавление новой категории (POST /api/category/)**
  Future<Category?> addCategory(String title) async {
    try {
      Response response = await ApiService.dio.post(
        '/api/category/',
        data: {"title": title},
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        print("Категория успешно добавлена");
        return Category.fromJson(response.data);
      }
    } on DioException catch (e) {
      print("Ошибка добавления категории: ${e.message}");
    }
    return null;
  }

  Future<bool> deleteCategory(int categoryId) async {
     try{
       Response response = await ApiService.dio.delete('/api/category/$categoryId/');
       if(response.statusCode == 204 || response.statusCode == 200){
         print("Категория успешно удалена");
         return true;
       }
       print(
           "Ошибка удаления категории: Неожиданный статус код ${response.statusCode}");
       return false;

     } catch (e) {
       print("Ошибка удаления категории: $e");
       rethrow; // Пробрасываем ошибку дальше для обработки в repository
     }
  }

  Future<bool> updateCategory(int categoryId, String title) async {
    try {
      Response response = await ApiService.dio.patch(
        '/api/category/$categoryId/',
        data: {"title": title},
      );
      if (response.statusCode == 200) {
        print("Категория успешно обновлена");
        return true;
      }
      print("❌ Ошибка обновления категории: Код ${response.statusCode}");
      return false;
    } catch (e) {
      print("Ошибка обновления категории: ${e}");
    }
    return false;
  }
}
