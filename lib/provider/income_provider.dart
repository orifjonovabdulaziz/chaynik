import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/selected_product.dart';

class IncomeState {
  final List<SelectedProduct> products;
  final double totalAmount;

  IncomeState({
    this.products = const [],
    this.totalAmount = 0,
  });

  IncomeState copyWith({
    List<SelectedProduct>? products,
    double? totalAmount,
  }) {
    return IncomeState(
      products: products ?? this.products,
      totalAmount: totalAmount ?? this.totalAmount,
    );
  }
}

class IncomeNotifier extends StateNotifier<IncomeState> {
  IncomeNotifier() : super(IncomeState());


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


    state = state.copyWith(
        products: currentProducts,
        totalAmount: newTotal,
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
    state = IncomeState();
  }
}

final incomeProvider = StateNotifierProvider<IncomeNotifier, IncomeState>((ref) {
  return IncomeNotifier();
});