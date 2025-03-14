// providers/sold_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/selected_product.dart';
import '../models/client.dart';

class SaleState {
  final Client? client;
  final List<SelectedProduct> products;
  final double totalAmount;
  final double paidAmount;

  SaleState({
    this.client,
    this.products = const [],
    this.totalAmount = 0,
    this.paidAmount = 0,
  });

  SaleState copyWith({
    Client? client,
    List<SelectedProduct>? products,
    double? totalAmount,
    double? paidAmount,
  }) {
    return SaleState(
      client: client ?? this.client,
      products: products ?? this.products,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
    );
  }
}

class SoldNotifier extends StateNotifier<SaleState> {
  SoldNotifier() : super(SaleState());

  void setClient(Client client) {
    state = state.copyWith(client: client);
  }

  void removeClient() {
    state = state.copyWith(client: null);
  }

  void addOrUpdateProduct(SelectedProduct product) {
    final currentProducts = List<SelectedProduct>.from(state.products);
    final index = currentProducts.indexWhere((p) => p.id == product.id);

    if (index >= 0) {
      currentProducts[index] = product;
    } else {
      currentProducts.add(product);
    }

    final newTotal = currentProducts.fold(
      0.0,
          (sum, product) => sum + product.total,
    );

    state = state.copyWith(
      products: currentProducts,
      totalAmount: newTotal,
    );
  }

  void removeProduct(int productId) {
    final currentProducts = state.products.where((p) => p.id != productId).toList();
    final newTotal = currentProducts.fold(
      0.0,
          (sum, product) => sum + product.total,
    );
    const newPaidAmount = 0.0;


    state = state.copyWith(
      products: currentProducts,
      totalAmount: newTotal,
      paidAmount: newPaidAmount
    );
  }

  int getQuantity(int productId) {
    final product = state.products.firstWhere(
          (p) => p.id == productId,
      orElse: () => SelectedProduct(
        id: productId,
        title: '',
        price: 0,
        quantity: 0,
        total: 0,
        imageUrl: '',
      ),
    );
    return product.quantity;
  }

  void clear() {
    state = SaleState();
  }
}

final soldProvider = StateNotifierProvider<SoldNotifier, SaleState>((ref) {
  return SoldNotifier();
});