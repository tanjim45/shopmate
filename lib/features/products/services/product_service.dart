
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class ProductService {
  static const String _baseUrl = 'https://dummyjson.com';

  Future<List<Product>> fetchProducts({
    int limit = 10,
    int skip = 0,
  }) async {
    final uri = Uri.parse('$_baseUrl/products').replace(
      queryParameters: {
        'limit': limit.toString(),
        'skip': skip.toString(),
      },
    );

    final response = await http.get(uri).timeout(
      const Duration(seconds: 20),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load products: ${response.statusCode}',
      );
    }

    final Map<String, dynamic> responseData =
        jsonDecode(response.body) as Map<String, dynamic>;

    final List<dynamic> jsonList =
        responseData['products'] as List<dynamic>;

    return jsonList.map((json) {
      return Product.fromJson(
        json as Map<String, dynamic>,
      );
    }).toList();
  }
}
