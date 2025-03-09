import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:chaynik/models/product.dart';
import 'package:chaynik/repositories/product_repository.dart';

Future<void> downloadAndSaveImages(List<Product> products) async {
  final Dio dio = Dio();
  final ProductRepository productRepository = ProductRepository();

  for (var product in products) {
    try {
      print("process downloading....");
      // Получаем путь к директории для хранения изображений
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = '${directory.path}/${product.id}.jpg'; // Сохраняем с id продукта

      // Загружаем изображение
      await dio.download(product.imageUrl, imagePath);

      // Обновляем путь в базе данных
      await productRepository.updateProduct(product.id, image: imagePath);
    } catch (e) {
      print("Ошибка загрузки изображения для продукта ${product.id}: $e");
    }
  }
}