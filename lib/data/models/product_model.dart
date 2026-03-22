class Product {
  final String id;
  final String name;
  final double price;
  final String category;
  final String image;
  final String description;
  final double ratingAvg;
  final int ratingCount;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.image,
    required this.description,
    required this.ratingAvg,
    required this.ratingCount,
  });

  factory Product.fromFirestore(Map<String, dynamic> data, String id) {
    return Product(
      id: id,
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      category: data['category'] ?? '',
      image: data['image'] ?? '',
      description: data['description'] ?? '',
      ratingAvg: (data['ratingAvg'] ?? 0).toDouble(),
      ratingCount: data['ratingCount'] ?? 0,
    );
  }
}