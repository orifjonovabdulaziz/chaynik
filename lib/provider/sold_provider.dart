import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/client.dart';
import '../models/sold.dart';
import '../repositories/sold_repository.dart';

final soldProvider = Provider((ref) => SoldRepository());

// Если нужно хранить состояние текущей продажи
// В sold_provider.dart добавим:

final currentSaleProvider = StateNotifierProvider<CurrentSaleNotifier, CurrentSale>(
      (ref) => CurrentSaleNotifier(),
);

class CurrentSale {
  final Client? client;
  final List<SoldItem> items;
  final double total;

  CurrentSale({
    this.client,
    this.items = const [],
    this.total = 0.0,
  });

  CurrentSale copyWith({
    Client? client,
    List<SoldItem>? items,
    double? total,
  }) {
    return CurrentSale(
      client: client ?? this.client,
      items: items ?? this.items,
      total: total ?? this.total,
    );
  }
}

class CurrentSaleNotifier extends StateNotifier<CurrentSale> {
  CurrentSaleNotifier() : super(CurrentSale());

  void updateClient(Client client) {
    state = state.copyWith(client: client);
  }

  void addItem(SoldItem item) {
    final items = [...state.items, item];
    final total = items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
    state = state.copyWith(items: items, total: total);
  }

  void clearSale() {
    state = CurrentSale();
  }
}