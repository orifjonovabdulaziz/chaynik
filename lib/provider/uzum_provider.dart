import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/uzum.dart';
import '../repositories/uzum_repository.dart';

class UzumState {
  final bool isLoading;
  final String? error;
  final UzumStats? stats;
  final String? market;
  final int count;
  final int totalProfit;
  final DateTime? startDate;
  final DateTime? endDate;

  UzumState({
    this.isLoading = false,
    this.error,
    this.stats,
    this.market,
    this.count = 0,
    this.totalProfit = 0,
    this.startDate,
    this.endDate,
  });

  UzumState copyWith({
    bool? isLoading,
    String? error,
    UzumStats? stats,
    String? market,
    int? count,
    int? totalProfit,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return UzumState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      stats: stats ?? this.stats,
      market: market ?? this.market,
      count: count ?? this.count,
      totalProfit: totalProfit ?? this.totalProfit,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}

final uzumProvider = StateNotifierProvider<UzumNotifier, UzumState>((ref) {
  return UzumNotifier();
});

class UzumNotifier extends StateNotifier<UzumState> {
  final UzumRepository _repository = UzumRepository();

  UzumNotifier() : super(UzumState());

  Future<void> getTodayStats(int marketId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final stats = await _repository.getTodayStats(marketId);
      if (stats != null) {
        state = state.copyWith(
          isLoading: false,
          market: stats.market,
          count: stats.count,
          totalProfit: stats.totalProfit,
          startDate: stats.startDate,
          endDate: stats.endDate,
        );
      } else {
        state = state.copyWith(
          error: 'Не удалось получить статистику',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Ошибка при получении статистики: $e',
        isLoading: false,
      );
    }
  }

  Future<void> getStatsByDateRange({
    required int marketId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final stats = await _repository.getStatsByDateRange(
        marketId: marketId,
        startDate: startDate,
        endDate: endDate,
      );

      if (stats != null) {
        state = state.copyWith(
          isLoading: false,
          market: stats.market,
          count: stats.count,
          totalProfit: stats.totalProfit,
          startDate: stats.startDate,
          endDate: stats.endDate,
        );
      } else {
        state = state.copyWith(
          error: 'Не удалось получить статистику',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Ошибка при получении статистики: $e',
        isLoading: false,
      );
    }
  }

  void clearState() {
    state = UzumState();
  }
}