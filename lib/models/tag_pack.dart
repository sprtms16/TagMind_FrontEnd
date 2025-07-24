class TagPack {
  final int id;
  final String name;
  final String? description;
  final int price;
  final String productId; // Product ID for IAP

  TagPack({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.productId,
  });

  // Factory constructor to create a TagPack from a JSON map
  factory TagPack.fromJson(Map<String, dynamic> json) {
    return TagPack(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'],
      productId: json['product_id'],
    );
  }
}