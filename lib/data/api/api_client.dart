import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  final String baseUrl = 'http://localhost:5055';

  Future<Map<String, String>> getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> get(String path) async {
    final headers = await getHeaders();
    return http.get(Uri.parse('$baseUrl$path'), headers: headers);
  }

  Future<http.Response> post(String path, dynamic body) async {
    final headers = await getHeaders();
    return http.post(Uri.parse('$baseUrl$path'), headers: headers, body: body);
  }
}
