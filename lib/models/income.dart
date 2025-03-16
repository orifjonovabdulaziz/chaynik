class Income {
  final int id;
  final int quantity;
  final double price;
  final int product;
  final String? priceSum;
  final String? createdAt;
  final String? updatedAt;

  Income({
    required this.id,
    required this.quantity,
    required this.price,
    required this.product,
    this.priceSum,
    this.createdAt,
    this.updatedAt,
  });

  factory Income.fromJson(Map<String, dynamic> json) {
    return Income(
      id: json['id'] ?? 0,
      quantity: json['quantity'] ?? 0,
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      product: json['product'] ?? 0,
      priceSum: json['price_sum']?.toString(),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quantity': quantity,
      'price': price.toString(),
      'product': product,
      if (priceSum != null) 'price_sum': priceSum,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    };
  }

  Income copyWith({
    int? id,
    int? quantity,
    double? price,
    int? product,
    String? priceSum,
    String? createdAt,
    String? updatedAt,
  }) {
    return Income(
      id: id ?? this.id,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      product: product ?? this.product,
      priceSum: priceSum ?? this.priceSum,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}