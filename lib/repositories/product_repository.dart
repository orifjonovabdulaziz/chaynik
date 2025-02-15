import 'package:chaynik/dio/db/product_db.dart';
import 'package:chaynik/models/product.dart';

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
        print("Новый продукт успешно добавлена локально");
        return true;
      }
    } catch (e) {
      print("Ошибка при добавлении продукта: $e");
    }
    return false;
  }
}
