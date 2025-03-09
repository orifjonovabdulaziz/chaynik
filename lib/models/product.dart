class Product {
  final int id;
  final String title;
  final double price;
  final String imageUrl;
  final int categoryId;
  final int quantity;

  Product(
      {required this.id,
      required this.title,
      required this.price,
      required this.imageUrl,
      required this.categoryId,
      required this.quantity});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'],
      price: double.parse(json['price']),
      imageUrl: json['image'],
      categoryId: json['category'],
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "price": price.toString(),
      "image": imageUrl,
      "category": categoryId,
      "quantity": quantity
    };
  }
}
