import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/income.dart';
import '../models/selected_product.dart';
import '../repositories/income_repository.dart';

class IncomeState {
  final List<SelectedProduct> products;
  final double totalAmount;
  final bool isLoading;
  final String? error;
  final List<Income>? incomes;

  IncomeState({
    this.products = const [],
    this.totalAmount = 0,
    this.isLoading = false,
    this.error,
    this.incomes,
  });

  IncomeState copyWith({
    List<SelectedProduct>? products,
    double? totalAmount,
    bool? isLoading,
    String? error,
    List<Income>? incomes,
  }) {
    return IncomeState(
      products: products ?? this.products,
      totalAmount: totalAmount ?? this.totalAmount,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      incomes: incomes ?? this.incomes,
    );
  }
}

class IncomeNotifier extends StateNotifier<IncomeState> {
  final IncomeRepository _repository;

  IncomeNotifier(this._repository) : super(IncomeState());

  // Добавить или обновить продукт в списке
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

  // Удалить продукт из списка
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

  // Получить количество продукта
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

  // Очистить состояние
  void clear() {
    state = IncomeState();
  }

  // Создать приход на основе выбранных продуктов
  Future<void> createIncome() async {
    if (state.products.isEmpty) {
      state = state.copyWith(error: 'Список продуктов пуст');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final items = state.products.map((product) => IncomeItem(
        product: product.id,
        quantity: product.quantity,
        price: product.price.toString(),
      )).toList();

      final income = Income(items: items);
      final success = await _repository.createIncome(income);

      if (success) {
        clear();
        await loadIncomes();
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Ошибка при создании прихода',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Произошла ошибка: $e',
      );
    }
  }

  // Загрузить список приходов
  Future<void> loadIncomes({
    String? createdAtAfter,
    String? createdAtBefore,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final incomes = await _repository.getIncomesFromServerAndSave(
        createdAtAfter: createdAtAfter,
        createdAtBefore: createdAtBefore,
      );

      state = state.copyWith(
        isLoading: false,
        incomes: incomes,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Ошибка при загрузке приходов: $e',
      );
    }
  }

  // Загрузить приходы по ID продукта
  Future<void> loadIncomesByProductId(int productId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final incomes = await _repository.getIncomesByProductId(productId);
      state = state.copyWith(
        isLoading: false,
        incomes: incomes,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Ошибка при загрузке приходов продукта: $e',
      );
    }
  }
}

final incomeProvider = StateNotifierProvider<IncomeNotifier, IncomeState>((ref) {
  final repository = IncomeRepository();
  return IncomeNotifier(repository);
});