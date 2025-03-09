import 'package:dio/dio.dart';

import '../../models/sold.dart';
import 'api_service.dart';


class SoldService {

  Future<bool> createSold(Sold sold) async {
    try {
      final response = await ApiService.dio.post(
        '/api/sold/',
        data: sold.toJson(),
      );

      return response.statusCode == 201 || response.statusCode == 200;
    } on DioException catch (e) {
      print('❌ Ошибка при создании продажи: ${e.message}');
      return false;
    }
  }
}