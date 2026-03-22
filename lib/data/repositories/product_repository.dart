import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class ProductRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Product>> getAllProducts() async {
    final snapshot = await _db.collection('products').get();

    return snapshot.docs
        .map((doc) => Product.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  Future<List<Product>> searchProducts(String keyword) async {
    final snapshot = await _db.collection('products').get();

    return snapshot.docs
        .map((doc) => Product.fromFirestore(doc.data(), doc.id))
        .where((p) =>
        p.name.toLowerCase().contains(keyword.toLowerCase()))
        .toList();
  }

  Future<List<Product>> filterByCategory(String category) async {
    final snapshot = await _db
        .collection('products')
        .where('category', isEqualTo: category)
        .get();

    return snapshot.docs
        .map((doc) => Product.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  Future<Product?> getProductById(String productId) async {
    final doc = await _db.collection('products').doc(productId).get();
    if (!doc.exists || doc.data() == null) return null;

    return Product.fromFirestore(doc.data()!, doc.id);
  }

  Future<String> createProduct({
    required String name,
    required double price,
    required String category,
    required String image,
    required String description,
  }) async {
    final doc = _db.collection('products').doc();
    await doc.set({
      'name': name,
      'price': price,
      'category': category,
      'image': image,
      'description': description,
      'ratingAvg': 0,
      'ratingCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return doc.id;
  }

  Future<void> updateProduct({
    required String productId,
    required String name,
    required double price,
    required String category,
    required String image,
    required String description,
  }) async {
    await _db.collection('products').doc(productId).update({
      'name': name,
      'price': price,
      'category': category,
      'image': image,
      'description': description,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteProduct(String productId) async {
    await _db.collection('products').doc(productId).delete();
  }
}