import 'package:dio/dio.dart';
import '../../models/product.dart';
import '../services/api_service.dart'; // Используем общий `ApiService`

class ProductService {
  /// 🔹 **Получить список всех продуктов**
  Future<List<Product>> getProducts() async {
    try {
      Response response = await ApiService.dio.get('/api/product/');
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
  Future<Product?> addProduct(String title, double price, String imagePath, int categoryId) async {
    try {
      // Подготовка данных для отправки
      FormData formData = FormData.fromMap({
        "title": title,
        "price": price.toString(),
        "image": await MultipartFile.fromFile(imagePath, filename: imagePath.split('/').last),
        "category": categoryId,
      });

      Response response = await ApiService.dio.post(
        '/api/product/',
        data: formData,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print("Продукт успешно добавлен");
        return Product.fromJson(response.data);
      }
    } catch (e) {
      print("Ошибка добавления продукта: $e");
    }
    return null;
  }
}
