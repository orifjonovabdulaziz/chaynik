import 'package:dio/dio.dart';
import '../../models/product.dart';
import '../services/api_service.dart'; // Используем общий `ApiService`

class ProductService {
  /// 🔹 **Получить список всех продуктов**
  Future<List<Product>> getProducts() async {
    try {
      Response response = await ApiService.dio.get('/api/product/');
      print(response.data);
      if (response.statusCode == 200) {
        List data = response.data;
        return data.map((json) => Product.fromJson(json)).toList();
      }
    } catch (e) {
      print("Ошибка получения продуктов: $e");
    }
    return [];
  }

  /// 🔹 **Добавить новый продукт**
  Future<Product?> addProduct(
      String title, double price, String imagePath, int categoryId) async {
    try {
      FormData formData = FormData.fromMap({
        "title": title,
        "price": price.toString(),
        "image": await MultipartFile.fromFile(imagePath,
            filename: imagePath.split('/').last),
        "category": categoryId,
      });

      Response response = await ApiService.dio.post(
        '/api/product/',
        data: formData,
      );
      print(response.data);

      if (response.statusCode == 201 || response.statusCode == 200) {
        print("Продукт успешно добавлен");
        return Product.fromJson(response.data);
      }
    } catch (e) {
      print("Ошибка добавления продукта: $e");
    }
    return null;
  }

  /// 🔹 **Удалить продукт**
  Future<bool> deleteProduct(int productId) async {
    try {
      Response response =
          await ApiService.dio.delete('/api/product/$productId/');

      if (response.statusCode == 204 || response.statusCode == 200) {
        print("Продукт успешно удален");
        return true;
      }

      print(
          "Ошибка удаления продукта: Неожиданный статус код ${response.statusCode}");
      return false;
    } catch (e) {
      print("Ошибка удаления продукта: $e");
      rethrow; // Пробрасываем ошибку дальше для обработки в repository
    }
  }

  /// 🔹 **Изменение продукта (PATCH)**
  Future<Product?> updateProduct(
    int productId, {
    String? title,
    int? category,
    String? image,
    double? price,

  }) async {
    try {
      // Создаём `FormData`
      FormData formData = FormData();

      if (title != null) formData.fields.add(MapEntry("title", title));
      if (category != null)
        formData.fields.add(MapEntry("category", category.toString()));
      if (price != null)
        formData.fields.add(MapEntry("price", price.toString()));

      if (image != null) {
        formData.files.add(MapEntry(
          "image",
          await MultipartFile.fromFile(image, filename: image.split('/').last),
        ));
      }

      if (formData.fields.isEmpty && formData.files.isEmpty) {
        print("❌ Ошибка: Нет данных для обновления");
        return null;
      }

      Response response = await ApiService.dio.patch(
        '/api/product/$productId/',
        data: formData,
        options: Options(headers: {
          "Content-Type": "multipart/form-data",
        }),
      );

      if (response.statusCode == 200) {
        print("✅ Продукт успешно обновлён");
        return Product.fromJson(response.data);
      }

      print("❌ Ошибка обновления продукта: Код ${response.statusCode}");
      return null;
    } catch (e) {
      print("❌ Ошибка обновления продукта: $e");
      rethrow;
    }
  }
}
