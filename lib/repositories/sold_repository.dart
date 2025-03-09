import '../models/sold.dart';
import '../dio/services/sold_service.dart';

class SoldRepository {
  final SoldService _soldService = SoldService();

  Future<bool> createSale(int clientId, double paid, List<SoldItem> items) async {
    try {
      final sold = Sold(
        client: clientId,
        paid: paid,
        outcome: items,
      );

      final success = await _soldService.createSold(sold);
      if (success) {
        print('✅ Продажа успешно создана');
      }
      return success;
    } catch (e) {
      print('❌ Ошибка при создании продажи: $e');
      return false;
    }
  }
}