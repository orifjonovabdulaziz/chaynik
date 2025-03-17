import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/income.dart';
import '../models/product.dart';
import '../repositories/income_repository.dart';
import '../repositories/product_repository.dart';
import './sold_history_provider.dart'; // Импортируем существующий productsProvider

class IncomeHistoryState {
  final List<Income> incomes;
  final bool isLoading;
  final String? error;
  final String? dateFrom;
  final String? dateTo;

  IncomeHistoryState({
    this.incomes = const [],
    this.isLoading = false,
    this.error,
    this.dateFrom,
    this.dateTo,
  });

  IncomeHistoryState copyWith({
    List<Income>? incomes,
    bool? isLoading,
    String? error,
    String? dateFrom,
    String? dateTo,
  }) {
    return IncomeHistoryState(
      incomes: incomes ?? this.incomes,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
    );
  }

  double get totalQuantity => incomes.fold(
    0.0,
        (sum, income) => sum + income.items.fold(
      0.0,
          (sum, item) => sum + item.quantity,
    ),
  );

  double get totalAmount => incomes.fold(
    0.0,
        (sum, income) => sum + income.items.fold(
      0.0,
          (sum, item) => sum + (double.tryParse(item.price) ?? 0) * item.quantity,
    ),
  );
}

class IncomeHistoryNotifier extends StateNotifier<IncomeHistoryState> {
  final IncomeRepository _incomeRepository;
  final ProductRepository _productRepository;
  final Ref ref;

  IncomeHistoryNotifier(
      this._incomeRepository,
      this._productRepository,
      this.ref,
      ) : super(IncomeHistoryState()) {
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final products = await _productRepository.getProductsFromLocal();
      ref.read(productsProvider.notifier).state =
      {for (var product in products) product.id: product};
    } catch (e) {
      print('❌ Ошибка при загрузке продуктов: $e');
    }
  }

  Future<void> loadIncomes({
    String? startDate,
    String? endDate,
  }) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      dateFrom: startDate,
      dateTo: endDate,
    );

    try {
      final incomes = await _incomeRepository.getIncomesFromServerAndSave(
        createdAtAfter: startDate,
        createdAtBefore: endDate,
      );

      await _loadProducts();

      state = state.copyWith(
        incomes: incomes,
        isLoading: false,
      );
    } catch (e) {
      try {
        final localIncomes = await _incomeRepository.getIncomesFromLocal();
        state = state.copyWith(
          incomes: localIncomes,
          isLoading: false,
          error: 'Данные загружены из локальной БД',
        );
      } catch (e) {
        state = state.copyWith(
          isLoading: false,
          error: 'Ошибка при загрузке приходов: $e',
        );
      }
    }
  }

  Future<void> loadIncomesByProductId(int productId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final incomes = await _incomeRepository.getIncomesByProductId(productId);
      await _loadProducts();

      state = state.copyWith(
        incomes: incomes,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Ошибка при загрузке приходов продукта: $e',
      );
    }
  }

  void clearFilters() {
    state = state.copyWith(
      dateFrom: null,
      dateTo: null,
    );
    loadIncomes();
  }

  void filterByDateRange(String startDate, String endDate) {
    loadIncomes(
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<void> refreshIncomes() async {
    try {
      state = state.copyWith(isLoading: true);
      await _incomeRepository.getIncomesFromLocal();
      await loadIncomes(
        startDate: state.dateFrom,
        endDate: state.dateTo,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Ошибка при обновлении данных: $e',
      );
    }
  }

  void addIncome(Income income) {
    final currentIncomes = List<Income>.from(state.incomes);
    currentIncomes.insert(0, income);
    state = state.copyWith(incomes: currentIncomes);
  }

  void updateIncome(Income updatedIncome) {
    final currentIncomes = List<Income>.from(state.incomes);
    final index = currentIncomes.indexWhere((income) => income.id == updatedIncome.id);

    if (index != -1) {
      currentIncomes[index] = updatedIncome;
      state = state.copyWith(incomes: currentIncomes);
    }
  }

  void clearIncomes() {
    state = IncomeHistoryState(
      incomes: [],
      isLoading: false,
      error: null,
      dateFrom: null,
      dateTo: null,
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Провайдеры репозиториев
final incomeRepositoryProvider = Provider<IncomeRepository>((ref) {
  return IncomeRepository();
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository();
});

// Провайдер истории приходов
final incomeHistoryProvider =
StateNotifierProvider<IncomeHistoryNotifier, IncomeHistoryState>((ref) {
  final incomeRepository = ref.watch(incomeRepositoryProvider);
  final productRepository = ref.watch(productRepositoryProvider);
  return IncomeHistoryNotifier(incomeRepository, productRepository, ref);
});

// Провайдеры для фильтрованных данных
final filteredIncomesProvider = Provider<List<Income>>((ref) {
  final state = ref.watch(incomeHistoryProvider);
  return state.incomes;
});

final totalQuantityProvider = Provider<double>((ref) {
  final state = ref.watch(incomeHistoryProvider);
  return state.totalQuantity;
});

final totalAmountProvider = Provider<double>((ref) {
  final state = ref.watch(incomeHistoryProvider);
  return state.totalAmount;
});