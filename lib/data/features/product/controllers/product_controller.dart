import '../../../models/product_model.dart';
import '../../../repositories/product_repository.dart';

class ProductController {
  final ProductRepository _repo = ProductRepository();

  Future<List<Product>> getProducts() async {
    return await _repo.getAllProducts();
  }

  Future<List<Product>> search(String keyword) async {
    if (keyword.isEmpty) return getProducts();
    return await _repo.searchProducts(keyword);
  }

  Future<List<Product>> filter(String category) async {
    return await _repo.filterByCategory(category);
  }
}