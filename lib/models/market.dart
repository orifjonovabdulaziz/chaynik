class Market {
  final int id;
  final String? createdAt;
  final String? updatedAt;
  final String name;
  final String token;    // Изменено: убран nullable
  final String shopId;   // Изменено: убран nullable

  Market({
    required this.id,
    this.createdAt,
    this.updatedAt,
    required this.name,
    this.token = '',    // Изменено: добавлено значение по умолчанию
    this.shopId = '',   // Изменено: добавлено значение по умолчанию
  });

  // Создание объекта из JSON
  factory Market.fromJson(Map<String, dynamic> json) {
    return Market(
      id: json['id'] ?? 0,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      name: json['name'] ?? '',
      token: json['token'] ?? '',      // Изменено: добавлено значение по умолчанию
      shopId: json['shop_id'] ?? '',   // Изменено: добавлено значение по умолчанию
    );
  }

  // Преобразование объекта в JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'name': name,
      'token': token,
      'shop_id': shopId,
    };
  }

  // Создание копии объекта с возможностью изменения полей
  Market copyWith({
    int? id,
    String? createdAt,
    String? updatedAt,
    String? name,
    String? token,
    String? shopId,
  }) {
    return Market(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      name: name ?? this.name,
      token: token ?? this.token,
      shopId: shopId ?? this.shopId,
    );
  }

  @override
  String toString() {
    return 'Market(id: $id, name: $name, createdAt: $createdAt, updatedAt: $updatedAt, token: $token, shopId: $shopId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Market &&
        other.id == id &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.name == name &&
        other.token == token &&
        other.shopId == shopId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
    createdAt.hashCode ^
    updatedAt.hashCode ^
    name.hashCode ^
    token.hashCode ^
    shopId.hashCode;
  }
}