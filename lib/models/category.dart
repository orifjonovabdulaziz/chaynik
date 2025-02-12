class Category {
  final int id;
  final String title;
  final int productCount;

  Category({required this.id, required this.title, required this.productCount});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      title: json['title'],
      productCount: json['product_count'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'product_count': productCount,
    };
  }
}
