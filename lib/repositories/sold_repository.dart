import 'package:chaynik/repositories/product_repository.dart';

import '../models/sold.dart';
import '../dio/services/sold_service.dart';
import 'client_repository.dart';

class SoldRepository {
  final SoldService _soldService = SoldService();

  final ProductRepository _productRepository = ProductRepository();

  final ClientRepository _clientRepository = ClientRepository();

  Future<bool> createSale(
      int clientId, double paid, List<SoldItem> items) async {
    try {
      final sold = Sold(
        client: clientId,
        paid: paid,
        outcome: items,
      );

      final success = await _soldService.createSold(sold);
      if (success) {
        for (var item in items) {
          _productRepository.decreaseProductQuantity(
            int.parse(item.product.toString()),
            int.parse(item.quantity.toString()),
          );
        }

        await _clientRepository.updateClientFromServer(clientId);
        print('✅ Продажа успешно создана');
      }
      return success;
    } catch (e) {
      print('❌ Ошибка при создании продажи: $e');
      return false;
    }
  }
}
