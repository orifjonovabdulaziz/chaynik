import 'package:intl/intl.dart';

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

  // Геттер для общей суммы товара
  double get totalPrice => price * quantity;

  // Геттер для форматированной цены
  String get formattedPrice {
    final formatter = NumberFormat('#,##0', 'ru_RU');
    return formatter.format(price);
  }

  // Геттер для форматированной общей суммы
  String get formattedTotalPrice {
    final formatter = NumberFormat('#,##0', 'ru_RU');
    return formatter.format(totalPrice);
  }

  // Геттеры для форматированных дат
  String get formattedCreatedAt {
    if (createdAt == null) return '';
    String dateTimeWithoutTimezone = createdAt!.substring(0, 19);
    DateTime dateTime = DateTime.parse(dateTimeWithoutTimezone);
    return DateFormat('dd.MM.yyyy HH:mm').format(dateTime);
  }

  String get formattedUpdatedAt {
    if (updatedAt == null) return '';
    String dateTimeWithoutTimezone = updatedAt!.substring(0, 19);
    DateTime dateTime = DateTime.parse(dateTimeWithoutTimezone);
    return DateFormat('dd.MM.yyyy HH:mm').format(dateTime);
  }

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
    'id': id,
    'product': product,
    'quantity': quantity,
    'price': price.toString(),
    if (priceSum != null) 'price_sum': priceSum,
    if (createdAt != null) 'created_at': createdAt,
    if (updatedAt != null) 'updated_at': updatedAt,
  };

  // Метод для создания копии с изменениями
  SoldItem copyWith({
    int? id,
    int? product,
    int? quantity,
    double? price,
    String? priceSum,
    String? createdAt,
    String? updatedAt,
  }) {
    return SoldItem(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      priceSum: priceSum ?? this.priceSum,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
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

  // Геттер для общего количества товаров
  int get totalQuantity {
    return outcome.fold(0, (sum, item) => sum + item.quantity);
  }

  // Геттер для общей суммы продажи
  double get totalAmount {
    return outcome.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  // Геттеры для форматированных сумм
  String get formattedPaid {
    final formatter = NumberFormat('#,##0', 'ru_RU');
    return formatter.format(paid);
  }

  String get formattedTotal {
    final formatter = NumberFormat('#,##0', 'ru_RU');
    return formatter.format(total ?? 0.0);
  }

  String get formattedDebt {
    final formatter = NumberFormat('#,##0', 'ru_RU');
    return formatter.format(debt ?? 0.0);
  }

  // Геттеры для форматированных дат
  String get formattedCreatedAt {
    if (createdAt == null) return '';
    String dateTimeWithoutTimezone = createdAt!.substring(0, 19);
    DateTime dateTime = DateTime.parse(dateTimeWithoutTimezone);
    return DateFormat('dd.MM.yyyy HH:mm').format(dateTime);
  }

  String get formattedUpdatedAt {
    if (updatedAt == null) return '';
    String dateTimeWithoutTimezone = updatedAt!.substring(0, 19);
    DateTime dateTime = DateTime.parse(dateTimeWithoutTimezone);
    return DateFormat('dd.MM.yyyy HH:mm').format(dateTime);
  }

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
    'id': id,
    'client': client,
    'paid': paid.toString(),
    'outcome': outcome.map((item) => item.toJson()).toList(),
    if (createdAt != null) 'created_at': createdAt,
    if (updatedAt != null) 'updated_at': updatedAt,
    if (total != null) 'total': total.toString(),
    if (debt != null) 'debt': debt.toString(),
  };

  // Метод для создания копии с изменениями
  Sold copyWith({
    int? id,
    int? client,
    double? paid,
    List<SoldItem>? outcome,
    String? createdAt,
    String? updatedAt,
    double? total,
    double? debt,
  }) {
    return Sold(
      id: id ?? this.id,
      client: client ?? this.client,
      paid: paid ?? this.paid,
      outcome: outcome ?? this.outcome,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      total: total ?? this.total,
      debt: debt ?? this.debt,
    );
  }
}