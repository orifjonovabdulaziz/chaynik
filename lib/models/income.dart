import 'package:intl/intl.dart';

class Income {
  final int? id;
  final List<IncomeItem> items;
  final String? createdAt;
  final String? updatedAt;

  Income({
    this.id,
    required this.items,
    this.createdAt,
    this.updatedAt,
  });

  // Геттер для форматированной даты создания
  String get formattedCreatedAt {
    if (createdAt == null) return '';
    String dateTimeWithoutTimezone = createdAt!.substring(0, 19);
    DateTime dateTime = DateTime.parse(dateTimeWithoutTimezone);
    return DateFormat('dd.MM.yyyy HH:mm').format(dateTime);
  }

  // Геттер для форматированной даты обновления
  String get formattedUpdatedAt {
    if (updatedAt == null) return '';
    String dateTimeWithoutTimezone = updatedAt!.substring(0, 19);
    DateTime dateTime = DateTime.parse(dateTimeWithoutTimezone);
    return DateFormat('dd.MM.yyyy HH:mm').format(dateTime);
  }

  // Геттер для общего количества товаров
  int get totalQuantity {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  // Геттер для общей суммы
  double get totalAmount {
    return items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  factory Income.fromJson(Map<String, dynamic> json) {
    return Income(
      id: json['id'],
      items: (json['items'] as List<dynamic>)
          .map((item) => IncomeItem.fromJson(item))
          .toList(),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'items': items.map((item) => item.toJson()).toList(),
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  String toString() {
    return 'Income(id: $id, items: $items, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

class IncomeItem {
  final int? id;
  final int? product;
  final int quantity;
  final String price;
  final String? priceSum;

  IncomeItem({
    this.id,
    this.product,
    required this.quantity,
    required this.price,
    this.priceSum,
  });

  // Геттер для получения цены как double
  double get priceAsDouble {
    return double.tryParse(price) ?? 0.0;
  }

  // Геттер для получения общей суммы товара
  double get totalPrice {
    return priceAsDouble * quantity;
  }

  // Геттер для форматированной цены
  String get formattedPrice {
    final formatter = NumberFormat('#,##0', 'ru_RU');
    return formatter.format(priceAsDouble);
  }

  // Геттер для форматированной общей суммы
  String get formattedTotalPrice {
    final formatter = NumberFormat('#,##0', 'ru_RU');
    return formatter.format(totalPrice);
  }

  factory IncomeItem.fromJson(Map<String, dynamic> json) {
    return IncomeItem(
      id: json['id'],
      product: json['product'],
      quantity: json['quantity'],
      price: json['price'].toString(), // Преобразуем в строку для безопасности
      priceSum: json['price_sum']?.toString(), // Преобразуем в строку для безопасности
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product,
      'quantity': quantity,
      'price': price,
      'price_sum': priceSum,
    };
  }

  @override
  String toString() {
    return 'IncomeItem(id: $id, product: $product, quantity: $quantity, price: $price, priceSum: $priceSum)';
  }

  // Копирование с возможностью изменения полей
  IncomeItem copyWith({
    int? id,
    int? product,
    int? quantity,
    String? price,
    String? priceSum,
  }) {
    return IncomeItem(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      priceSum: priceSum ?? this.priceSum,
    );
  }
}