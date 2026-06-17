import 'dart:convert';
import 'package:flutter/foundation.dart';

import '../api/api_client.dart';
import '../models/appointment_model.dart';

class AppointmentService {
  final ApiClient _apiClient = ApiClient();

  Future<List<AppointmentModel>> getAppointments() async {
    try {
      final response = await _apiClient.get('/api/Cita');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        return data
            .map((item) => AppointmentModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('Error cargando citas: $e');
    }
    return [];
  }
}
