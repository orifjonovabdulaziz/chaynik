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
      // await downloadAndSaveImages(products);
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
        // await downloadAndSaveImages([newProduct]);
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
      final updatedProduct = await _productService.updateProduct(
        productId,
        title: title,
        category: category,
        image: image,
        price: price,
      );

      if (updatedProduct != null) {
        // 2️⃣ Если API обновление успешно, обновляем продукт в локальной БД
        await _productDb.updateProduct(
          productId,
          title: updatedProduct.title,
          category: updatedProduct.categoryId,
          image: updatedProduct.imageUrl,
          price: updatedProduct.price,
        );
      }

      return true;
    } catch (e) {
      print("❌ Ошибка в репозитории при обновлении продукта: $e");
      throw e; // Пробрасываем ошибку дальше для обработки в UI
    }
  }

  Future<bool> decreaseProductQuantity(int productId, int quantity) async {
    try {
      // Получаем текущий продукт из локальной БД
      final Product? currentProduct = await _productDb.getProductById(productId);

      if (currentProduct != null) {
        // Вычисляем новое количество
        final int newQuantity = currentProduct.quantity - quantity;

        // Проверяем, не станет ли количество отрицательным
        if (newQuantity < 0) {
          print("❌ Ошибка: Недостаточно товара на складе");
          return false;
        }

        // Обновляем количество в локальной БД
        await _productDb.updateProduct(
          productId,
          quantity: newQuantity,
        );

        print("✅ Количество товара успешно уменьшено на $quantity. Новое количество: $newQuantity");
        return true;
      }

      print("❌ Товар с ID $productId не найден в локальной базе данных");
      return false;

    } catch (e) {
      print("❌ Ошибка при уменьшении количества товара: $e");
      return false;
    }
  }


}
