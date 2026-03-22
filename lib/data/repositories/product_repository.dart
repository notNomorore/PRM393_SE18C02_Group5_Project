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
}