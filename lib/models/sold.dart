class SoldItem {
  final int id;
  final int product;
  final int quantity;
  final double price;
  final String? priceSum;
  final String? createdAt;
  final String? updatedAt;

  SoldItem({
    this.id = 0,
    required this.product,
    required this.quantity,
    required this.price,
    this.priceSum,
    this.createdAt,
    this.updatedAt,
  });

  factory SoldItem.fromJson(Map<String, dynamic> json) {
    return SoldItem(
      id: json['id'] ?? 0,
      product: json['product'] ?? 0,
      quantity: json['quantity'] ?? 0,
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      priceSum: json['price_sum']?.toString(),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() => {
    'product': product,
    'quantity': quantity,
    'price': price.toString(),
    if (priceSum != null) 'price_sum': priceSum,
    if (createdAt != null) 'created_at': createdAt,
    if (updatedAt != null) 'updated_at': updatedAt,
  };
}

class Sold {
  final int id;
  final int client;
  final double paid;
  final List<SoldItem> outcome;
  final String? createdAt;
  final String? updatedAt;
  final double? total;
  final double? debt;

  Sold({
    this.id = 0,
    required this.client,
    required this.paid,
    required this.outcome,
    this.createdAt,
    this.updatedAt,
    this.total,
    this.debt,
  });

  factory Sold.fromJson(Map<String, dynamic> json) {
    return Sold(
      id: json['id'] ?? 0,
      client: json['client'] ?? 0,
      paid: double.tryParse(json['paid'].toString()) ?? 0.0,
      outcome: (json['outcome'] as List<dynamic>?)
          ?.map((item) => SoldItem.fromJson(item))
          .toList() ?? [],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      total: double.tryParse(json['total'].toString()),
      debt: double.tryParse(json['debt'].toString()),
    );
  }

  Map<String, dynamic> toJson() => {
    'client': client,
    'paid': paid.toString(),
    'outcome': outcome.map((item) => item.toJson()).toList(),
    if (createdAt != null) 'created_at': createdAt,
    if (updatedAt != null) 'updated_at': updatedAt,
    if (total != null) 'total': total.toString(),
    if (debt != null) 'debt': debt.toString(),
  };

  // Вспомогательный метод для форматирования даты
  String get formattedDate {
    if (createdAt == null) return '';
    try {
      final date = DateTime.parse(createdAt!);
      return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
    } catch (e) {
      return '';
    }
  }

  // Вспомогательный метод для форматирования времени
  String get formattedTime {
    if (createdAt == null) return '';
    try {
      final date = DateTime.parse(createdAt!);
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '';
    }
  }
}