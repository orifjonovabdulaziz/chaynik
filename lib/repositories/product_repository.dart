import 'package:chaynik/dio/db/product_db.dart';
import 'package:chaynik/models/product.dart';

import '../components/util/image_downloader.dart';
import '../dio/services/product_service.dart';

class ProductRepository {
  final ProductService _productService = ProductService();
  final ProductDatabase _productDb = ProductDatabase.instance;

  Future<List<Product>> getProductsFromLocal() async {
    return await _productDb.getProducts();
  }

  Future<List<Product>> getProductsFromServerAndSave() async {
    try {
      List<Product> products = await _productService.getProducts();
      await _productDb.insertProducts(products);
      await downloadAndSaveImages(products);
      print("Продукты обновлены и сохранены в локальную базу данных");
      return products;
    } catch (e) {
      print("Ошибка загрузки продуктов с сервера: $e");
      return [];
    }
  }

  Future<bool> addProduct(name, price, imageUrl, categoryId) async {
    try {
      Product? newProduct = await _productService.addProduct(
          name, price, imageUrl, categoryId);
      if (newProduct != null) {
        await _productDb.insertProducts([newProduct]);
        await downloadAndSaveImages([newProduct]);
        print("Новый продукт успешно добавлена локально");
        return true;
      }
    } catch (e) {
      print("Ошибка при добавлении продукта: $e");
    }
    return false;
  }

  Future<bool> deleteProduct(int productId) async {
    try {
      final success = await _productService.deleteProduct(productId);
      if (success) {
        // Удаляем продукт из локальной базы данных
        await _productDb.deleteProduct(productId);
      }
      return success;
    } catch (e) {
      print("Ошибка в репозитории при удалении продукта: $e");
      throw e; // Пробрасываем ошибку дальше для обработки в UI
    }
  }


  Future<bool> updateProduct(int productId, {
    String? title,
    int? category,
    String? image,
    double? price
  }) async {
    try {
      // 1️⃣ Обновляем продукт в API
      final success = await _productService.updateProduct(
        productId,
        title: title,
        category: category,
        image: image,
        price: price,
      );

      if (success) {
        // 2️⃣ Если API обновление успешно, обновляем продукт в локальной БД
        await _productDb.updateProduct(
          productId,
          title: title,
          category: category,
          image: image,
          price: price,
        );
      }

      return success;
    } catch (e) {
      print("❌ Ошибка в репозитории при обновлении продукта: $e");
      throw e; // Пробрасываем ошибку дальше для обработки в UI
    }
  }


}
