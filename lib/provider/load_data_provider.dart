import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/load_data_repository.dart';

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