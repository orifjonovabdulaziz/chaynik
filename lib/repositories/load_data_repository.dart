import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../dio/services/shared_prefs_service.dart';
import '../provider/category_provider.dart';
import '../provider/client_provider.dart';
import '../provider/income_history_provider.dart';
import '../provider/income_provider.dart';
import '../provider/market_provider.dart';
import '../provider/product_provider.dart';
import '../provider/sold_history_provider.dart';
import '../provider/sold_provider.dart';
import '../repositories/category_repository.dart';
import '../repositories/product_repository.dart';
import '../repositories/income_repository.dart';
import '../repositories/client_repository.dart';
import '../repositories/market_repository.dart';
import '../repositories/sold_repository.dart';

class LoadDataRepository {
  final ProductRepository _productRepository;
  final IncomeRepository _incomeRepository;
  final ClientRepository _clientRepository;
  final MarketRepository _marketRepository;
  final SoldRepository _soldRepository;
  final CategoryRepository _categoryRepository;
  final ProviderContainer _container;

  LoadDataRepository(this._container)
      : _productRepository = ProductRepository(),
        _incomeRepository = IncomeRepository(),
        _clientRepository = ClientRepository(),
        _marketRepository = MarketRepository(),
        _soldRepository = SoldRepository(),
        _categoryRepository = CategoryRepository();

  Future<Map<String, String>> loadAllData() async {
    clearAllData();
    final results = <String, String>{};
    try {
      // Загружаем данные последовательно для предотвращения конфликтов
      await _loadMarkets(results);
      await _loadClients(results);
      await _loadCategories(results);
      await _loadProducts(results);
      await _loadIncomes(results);
      await _loadSales(results);

      results['status'] = 'success';
      results['message'] = 'Все данные успешно загружены';
    } catch (e) {
      results['status'] = 'error';
      results['message'] = 'Ошибка при загрузке данных: $e';
    }

    return results;
  }

  Future<Map<String, String>> clearAllData() async {
    final results = <String, String>{};
    try {
      // await SharedPrefsService.removeToken();
      // results['token'] = 'Токен успешно удален';

      // Очищаем данные параллельно
      await Future.wait([
        _clearMarkets(results),
        _clearClients(results),
        _clearCategories(results),
        _clearProducts(results),
        _clearIncomes(results),
        _clearSales(results),
      ]);


      results['status'] = 'success';
      results['message'] = 'Все данные успешно очищены';
    } catch (e) {
      results['status'] = 'error';
      results['message'] = 'Ошибка при очистке данных: $e';
    }

    return results;
  }

  // Методы загрузки данных
  Future<void> _loadMarkets(Map<String, String> results) async {
    try {
      await _marketRepository.getMarketsFromServerAndSave();
      _container.read(marketProvider.notifier).loadMarkets();
      results['markets'] = 'Магазины загружены успешно';
    } catch (e) {
      results['markets'] = 'Ошибка загрузки магазинов: $e';
      rethrow;
    }
  }

  Future<void> _loadClients(Map<String, String> results) async {
    try {
      await _clientRepository.getClientsFromServerAndSave();
      _container.read(clientProvider.notifier).fetchClients();
      results['clients'] = 'Клиенты загружены успешно';
    } catch (e) {
      results['clients'] = 'Ошибка загрузки клиентов: $e';
      rethrow;
    }
  }

  Future<void> _loadCategories(Map<String, String> results) async {
    try {
      await _categoryRepository.getCategoriesFromServerAndSave();
      _container.read(categoryProvider.notifier).fetchCategories();
      results['categories'] = 'Категории загружены успешно';
    } catch (e) {
      results['categories'] = 'Ошибка загрузки категорий: $e';
      rethrow;
    }
  }

  Future<void> _loadProducts(Map<String, String> results) async {
    try {
      await _productRepository.getProductsFromServerAndSave();
      _container.read(productProvider.notifier).fetchProducts();
      results['products'] = 'Товары загружены успешно';
    } catch (e) {
      results['products'] = 'Ошибка загрузки товаров: $e';
      rethrow;
    }
  }

  Future<void> _loadIncomes(Map<String, String> results) async {
    try {
      await _incomeRepository.getIncomesFromServerAndSave();
      _container.read(incomeHistoryProvider.notifier).loadIncomes();
      results['incomes'] = 'Приходы загружены успешно';
    } catch (e) {
      results['incomes'] = 'Ошибка загрузки приходов: $e';
      rethrow;
    }
  }

  Future<void> _loadSales(Map<String, String> results) async {
    try {
      await _soldRepository.getSoldsFromServerAndSave();
      _container.read(soldHistoryProvider.notifier).loadSales();
      results['sales'] = 'Продажи загружены успешно';
    } catch (e) {
      results['sales'] = 'Ошибка загрузки продаж: $e';
      rethrow;
    }
  }

  // Методы очистки данных
  Future<void> _clearMarkets(Map<String, String> results) async {
    try {
      await _marketRepository.clearAllData();
      _container.read(marketProvider.notifier).clearAllData();
      results['markets'] = 'Магазины успешно очищены';
    } catch (e) {
      results['markets'] = 'Ошибка очистки магазинов: $e';
      rethrow;
    }
  }

  Future<void> _clearClients(Map<String, String> results) async {
    try {
      await _clientRepository.deleteAllClients();
      _container.read(clientProvider.notifier).clearAllClientsData();
      results['clients'] = 'Клиенты успешно очищены';
    } catch (e) {
      results['clients'] = 'Ошибка очистки клиентов: $e';
      rethrow;
    }
  }

  Future<void> _clearCategories(Map<String, String> results) async {
    try {
      await _categoryRepository.deleteAllCategories();
      _container.read(categoryProvider.notifier).clearCategories();
      results['categories'] = 'Категории успешно очищены';
    } catch (e) {
      results['categories'] = 'Ошибка очистки категорий: $e';
      rethrow;
    }
  }

  Future<void> _clearProducts(Map<String, String> results) async {
    try {
      await _productRepository.deleteAllProducts();
      _container.read(productProvider.notifier).clearAllProductsData();
      results['products'] = 'Товары успешно очищены';
    } catch (e) {
      results['products'] = 'Ошибка очистки товаров: $e';
      rethrow;
    }
  }

  Future<void> _clearIncomes(Map<String, String> results) async {
    try {
      await _incomeRepository.deleteAllIncomes();
      _container.read(incomeHistoryProvider.notifier).clearIncomes();
      _container.read(incomeProvider.notifier).clear();
      results['incomes'] = 'Приходы успешно очищены';
    } catch (e) {
      results['incomes'] = 'Ошибка очистки приходов: $e';
      rethrow;
    }
  }

  Future<void> _clearSales(Map<String, String> results) async {
    try {
      await _soldRepository.clearLocalSolds();
      _container.read(soldHistoryProvider.notifier).clearSales();

      // Очищаем текущую продажу и обновляем состояние
       _container.read(soldProvider.notifier).clear();

      results['sales'] = 'Продажи успешно очищены';
    } catch (e) {
      results['sales'] = 'Ошибка очистки продаж: $e';
      rethrow;
    }
  }
}

// Провайдер для LoadDataRepository
final loadDataRepositoryProvider = Provider((ref) {
  return LoadDataRepository(ref.container);
});

// Провайдер для отслеживания состояния загрузки
final loadDataStateProvider = StateNotifierProvider<LoadDataStateNotifier, LoadDataState>((ref) {
  return LoadDataStateNotifier();
});

// Состояние загрузки данных
class LoadDataState {
  final bool isLoading;
  final String? error;
  final Map<String, String> results;

  LoadDataState({
    this.isLoading = false,
    this.error,
    this.results = const {},
  });

  LoadDataState copyWith({
    bool? isLoading,
    String? error,
    Map<String, String>? results,
  }) {
    return LoadDataState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      results: results ?? this.results,
    );
  }
}

// Notifier для управления состоянием загрузки
class LoadDataStateNotifier extends StateNotifier<LoadDataState> {
  LoadDataStateNotifier() : super(LoadDataState());

  Future<void> loadData(LoadDataRepository repository) async {
    state = state.copyWith(isLoading: true, error: null, results: {});

    try {
      final results = await repository.loadAllData();
      state = state.copyWith(
        isLoading: false,
        results: results,
        error: results['status'] == 'error' ? results['message'] : null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Ошибка при загрузке данных: $e',
      );
    }
  }
}