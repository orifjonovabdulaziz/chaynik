class UzumStats {
  final String market;
  final int count;
  final int totalProfit;
  final DateTime startDate;
  final DateTime endDate;

  UzumStats({
    required this.market,
    this.count = 0,
    this.totalProfit = 0,
    required this.startDate,
    required this.endDate,
  });

  factory UzumStats.fromJson(Map<String, dynamic> json) {
    return UzumStats(
      market: json['market'] ?? '',
      count: json['count'] ?? 0,
      totalProfit: json['total_profit'] ?? 0,
      startDate: DateTime.parse(json['start_date']), // Парсит полный формат ISO8601
      endDate: DateTime.parse(json['end_date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'market': market,
      'count': count,
      'total_profit': totalProfit,
      'start_date': _formatDateForRequest(startDate), // Форматирует только дату
      'end_date': _formatDateForRequest(endDate),
    };
  }

  // Вспомогательный метод для форматирования даты в нужный формат
  String _formatDateForRequest(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  UzumStats copyWith({
    String? market,
    int? count,
    int? totalProfit,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return UzumStats(
      market: market ?? this.market,
      count: count ?? this.count,
      totalProfit: totalProfit ?? this.totalProfit,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  @override
  String toString() {
    return 'UzumStats(market: $market, count: $count, totalProfit: $totalProfit, startDate: $startDate, endDate: $endDate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UzumStats &&
        other.market == market &&
        other.count == count &&
        other.totalProfit == totalProfit &&
        other.startDate == startDate &&
        other.endDate == endDate;
  }

  @override
  int get hashCode {
    return market.hashCode ^
    count.hashCode ^
    totalProfit.hashCode ^
    startDate.hashCode ^
    endDate.hashCode;
  }
}