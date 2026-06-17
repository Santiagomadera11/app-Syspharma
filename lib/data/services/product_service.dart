import 'dart:convert';
import 'package:flutter/foundation.dart';

import '../api/api_client.dart';
import '../models/product_model.dart';

class ProductService {
  final ApiClient _apiClient = ApiClient();

  Future<List<ProductModel>> getAllProducts() async {
    try {
      final response = await _apiClient.get('/api/Producto');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        return data
            .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('Error productos: $e');
    }
    return [];
  }
}
