
import '../models/product_model.dart';
import '../services/product_service.dart';

class ProductRepository {
  final ProductService _productService;

  ProductRepository({
    ProductService? productService,
  }) : _productService = productService ?? ProductService();

  Future<List<Product>> getProducts() {
    return _productService.fetchProducts();
  }
}
