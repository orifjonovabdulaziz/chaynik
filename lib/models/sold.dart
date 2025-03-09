class SoldItem {
  final int product;
  final int quantity;
  final double price;

  SoldItem({
    required this.product,
    required this.quantity,
    required this.price,
  });

  Map<String, dynamic> toJson() => {
    'product': product,
    'quantity': quantity,
    'price': price.toString(),
  };
}

class Sold {
  final int client;
  final double paid;
  final List<SoldItem> outcome;

  Sold({
    required this.client,
    required this.paid,
    required this.outcome,
  });

  Map<String, dynamic> toJson() => {
    'client': client,
    'paid': paid.toString(),
    'outcome': outcome.map((item) => item.toJson()).toList(),
  };
}