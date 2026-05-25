import 'dart:convert';

import '../api/api_client.dart';
import '../models/dashboard_models.dart';

class DashboardService {
  final ApiClient _apiClient = ApiClient();

  Future<List<VentaModel>> getVentas() async {
    final response = await _apiClient.get('/api/Venta');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      return data.map((item) => VentaModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<List<CitaModel>> getCitas() async {
    final response = await _apiClient.get('/api/Cita');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      return data.map((item) => CitaModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }
}
