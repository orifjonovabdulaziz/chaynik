import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sold.dart';
import '../models/product.dart';
import '../models/client.dart';
import '../repositories/sold_repository.dart';
import '../repositories/client_repository.dart';
import '../repositories/product_repository.dart';

// Провайдер для клиентов
final clientsProvider = StateProvider<Map<int, String>>((ref) => {});

// Провайдер для продуктов
final productsProvider = StateProvider<Map<int, Product>>((ref) => {});

class SoldHistoryState {
  final List<Sold> sales;
  final bool isLoading;
  final String? error;
  final int? selectedClientId;
  final String? dateFrom;
  final String? dateTo;

  SoldHistoryState({
    this.sales = const [],
    this.isLoading = false,
    this.error,
    this.selectedClientId,
    this.dateFrom,
    this.dateTo,
  });

  SoldHistoryState copyWith({
    List<Sold>? sales,
    bool? isLoading,
    String? error,
    int? selectedClientId,
    String? dateFrom,
    String? dateTo,
  }) {
    return SoldHistoryState(
      sales: sales ?? this.sales,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedClientId: selectedClientId,
      dateFrom: dateFrom,
      dateTo: dateTo,
    );
  }

  double get totalSales => sales.fold(
    0.0,
        (sum, sale) => sum + sale.outcome.fold(
      0.0,
          (sum, item) => sum + (double.tryParse(item.price.toString()) ?? 0) * item.quantity,
    ),
  );

  double get totalPaid => sales.fold(
    0.0,
        (sum, sale) => sum + sale.paid,
  );
}

class SoldHistoryNotifier extends StateNotifier<SoldHistoryState> {
  final SoldRepository _soldRepository;
  final ClientRepository _clientRepository;
  final ProductRepository _productRepository;
  final Ref ref;

  SoldHistoryNotifier(
      this._soldRepository,
      this._clientRepository,
      this._productRepository,
      this.ref,
      ) : super(SoldHistoryState()) {
    _loadClientsAndProducts();
  }

  Future<void> _loadClientsAndProducts() async {
    try {
      final clients = await _clientRepository.getClientsFromLocal();
      final products = await _productRepository.getProductsFromLocal();

      ref.read(clientsProvider.notifier).state =
      {for (var client in clients) client.id: client.full_name};
      ref.read(productsProvider.notifier).state =
      {for (var product in products) product.id: product};
    } catch (e) {
      print('❌ Ошибка при загрузке клиентов и продуктов: $e');
    }
  }

  Future<void> loadSales({
    int? clientId,
    String? createdAtAfter,
    String? createdAtBefore,
  }) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      selectedClientId: clientId,
      dateFrom: createdAtAfter,
      dateTo: createdAtBefore,
    );

    try {
      final sales = await _soldRepository.getSoldsFromServerAndSave(
        client: clientId,
        createdAtAfter: createdAtAfter,
        createdAtBefore: createdAtBefore,
      );

      await _loadClientsAndProducts();

      state = state.copyWith(
        sales: sales,
        isLoading: false,
      );
    } catch (e) {
      try {
        final localSales = await _soldRepository.getSoldsFromLocal();
        state = state.copyWith(
          sales: localSales,
          isLoading: false,
          error: 'Данные загружены из локальной БД',
        );
      } catch (e) {
        state = state.copyWith(
          isLoading: false,
          error: 'Ошибка при загрузке продаж: $e',
        );
      }
    }
  }

  void clearFilters() {
    state = state.copyWith(
      selectedClientId: null,
      dateFrom: null,
      dateTo: null,
    );
    loadSales();
  }

  void filterByClient(int clientId) {
    loadSales(clientId: clientId);
  }

  void filterByDateRange(String startDate, String endDate) {
    loadSales(
      clientId: state.selectedClientId,
      createdAtAfter: startDate,
      createdAtBefore: endDate,
    );
  }

  Future<void> refreshData() async {
    try {
      state = state.copyWith(isLoading: true);
      await _soldRepository.syncWithServer();
      await loadSales(
        clientId: state.selectedClientId,
        createdAtAfter: state.dateFrom,
        createdAtBefore: state.dateTo,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Ошибка при обновлении данных: $e',
      );
    }
  }
}

// Провайдеры репозиториев
final soldRepositoryProvider = Provider<SoldRepository>((ref) {
  return SoldRepository();
});

final clientRepositoryProvider = Provider<ClientRepository>((ref) {
  return ClientRepository();
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository();
});

// Провайдер истории продаж
final soldHistoryProvider = StateNotifierProvider<SoldHistoryNotifier, SoldHistoryState>((ref) {
  final soldRepository = ref.watch(soldRepositoryProvider);
  final clientRepository = ref.watch(clientRepositoryProvider);
  final productRepository = ref.watch(productRepositoryProvider);
  return SoldHistoryNotifier(soldRepository, clientRepository, productRepository, ref);
});

// Провайдеры для фильтрованных данных
final filteredSalesProvider = Provider<List<Sold>>((ref) {
  final state = ref.watch(soldHistoryProvider);
  return state.sales;
});

final totalSalesProvider = Provider<double>((ref) {
  final state = ref.watch(soldHistoryProvider);
  return state.totalSales;
});

final totalPaidProvider = Provider<double>((ref) {
  final state = ref.watch(soldHistoryProvider);
  return state.totalPaid;
});