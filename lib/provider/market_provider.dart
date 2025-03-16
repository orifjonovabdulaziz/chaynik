import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/market.dart';
import '../repositories/market_repository.dart';

// Состояние для маркетов
class MarketState {
  final List<Market> markets;
  final bool isLoading;
  final String? error;
  final Market? selectedMarket;

  MarketState({
    this.markets = const [],
    this.isLoading = false,
    this.error,
    this.selectedMarket,
  });

  MarketState copyWith({
    List<Market>? markets,
    bool? isLoading,
    String? error,
    Market? selectedMarket,
  }) {
    return MarketState(
      markets: markets ?? this.markets,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedMarket: selectedMarket ?? this.selectedMarket,
    );
  }
}

// Notifier для управления состоянием маркетов
class MarketNotifier extends StateNotifier<MarketState> {
  final MarketRepository _repository;

  MarketNotifier(this._repository) : super(MarketState()) {
    // Загружаем маркеты при инициализации
    loadMarkets();
  }

  /// 🔹 **Загрузка маркетов**
  Future<void> loadMarkets() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Сначала пробуем загрузить с сервера
      final markets = await _repository.getMarketsFromServerAndSave();

      state = state.copyWith(
        markets: markets,
        isLoading: false,
      );
    } catch (e) {
      print('❌ Ошибка при загрузке маркетов: $e');

      // При ошибке загружаем из локальной БД
      try {
        final localMarkets = await _repository.getMarketsFromLocal();
        state = state.copyWith(
          markets: localMarkets,
          isLoading: false,
          error: 'Данные загружены из локальной БД',
        );
      } catch (e) {
        state = state.copyWith(
          isLoading: false,
          error: 'Ошибка при загрузке маркетов: $e',
        );
      }
    }
  }

  /// 🔹 **Добавление маркета**
  Future<bool> addMarket({
    required String name,
    required String token,
    required String shopId,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final success = await _repository.addMarket(
        name: name,
        token: token,
        shopId: shopId,
      );

      if (success) {
        await loadMarkets(); // Перезагружаем список после добавления
        return true;
      }

      state = state.copyWith(
        isLoading: false,
        error: 'Не удалось добавить маркет',
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Ошибка при добавлении маркета: $e',
      );
      return false;
    }
  }

  /// 🔹 **Удаление маркета**
  Future<bool> deleteMarket(int marketId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final success = await _repository.deleteMarket(marketId);
      if (success) {
        if (state.selectedMarket?.id == marketId) {
          clearSelectedMarket();
        }
        await loadMarkets(); // Перезагружаем список после удаления
        return true;
      }

      state = state.copyWith(
        isLoading: false,
        error: 'Не удалось удалить маркет',
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Ошибка при удалении маркета: $e',
      );
      return false;
    }
  }

  /// 🔹 **Обновление данных**
  Future<void> refreshData() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _repository.syncWithServer();
      await loadMarkets();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Ошибка при обновлении данных: $e',
      );
    }
  }

  /// 🔹 **Выбор маркета**
  void selectMarket(Market market) {
    state = state.copyWith(selectedMarket: market);
  }

  /// 🔹 **Очистка выбранного маркета**
  void clearSelectedMarket() {
    state = state.copyWith(selectedMarket: null);
  }

  /// 🔹 **Получение количества маркетов**
  Future<int> getMarketsCount() async {
    try {
      return await _repository.getMarketsCount();
    } catch (e) {
      print("❌ Ошибка при получении количества маркетов: $e");
      return 0;
    }
  }

  /// 🔹 **Очистка всех данных**
  Future<void> clearAllData() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _repository.clearAllData();
      state = state.copyWith(
        markets: [],
        selectedMarket: null,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Ошибка при очистке данных: $e',
      );
    }
  }

  /// 🔹 **Освобождение ресурсов**
  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }
}

// Провайдеры
final marketRepositoryProvider = Provider<MarketRepository>((ref) {
  return MarketRepository();
});

final marketProvider = StateNotifierProvider<MarketNotifier, MarketState>((ref) {
  final repository = ref.watch(marketRepositoryProvider);
  return MarketNotifier(repository);
});

// Дополнительные провайдеры для удобного доступа к данным
final marketsListProvider = Provider<List<Market>>((ref) {
  return ref.watch(marketProvider).markets;
});

final selectedMarketProvider = Provider<Market?>((ref) {
  return ref.watch(marketProvider).selectedMarket;
});

final marketLoadingProvider = Provider<bool>((ref) {
  return ref.watch(marketProvider).isLoading;
});

final marketErrorProvider = Provider<String?>((ref) {
  return ref.watch(marketProvider).error;
});

// Провайдер для количества маркетов
final marketCountProvider = FutureProvider<int>((ref) async {
  final notifier = ref.watch(marketProvider.notifier);
  return await notifier.getMarketsCount();
});