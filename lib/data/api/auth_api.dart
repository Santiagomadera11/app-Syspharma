import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_client.dart';
import '../../domain/entities/user.dart';

class AuthException implements Exception {
  final String message;
  final int? statusCode;
  const AuthException(this.message, {this.statusCode});
  @override
  String toString() => message;
}

class AuthApi {
  // Eliminamos _baseUrl de aquí porque ApiClient ya la tiene
  static const String _loginPath = '/api/Auth/login';

  final ApiClient _apiClient;

  AuthApi({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<UserEntity> login(String email, String password) async {
    try {
      final response = await _apiClient.post(
        _loginPath,
        jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode != 200) {
        throw AuthException(
          _extractErrorMessage(response.body) ?? 'Credenciales inválidas',
          statusCode: response.statusCode,
        );
      }

      final Map<String, dynamic> body = jsonDecode(response.body);
      
      // Extraemos el token y los datos del usuario según la estructura de tu API
      final String token = body['token'] ?? '';
      final Map<String, dynamic> userJson = body['user'] ?? {};
      final user = _mapToUser(userJson, email);

      if (token.isNotEmpty) {
        await _saveToken(token);
        await _saveUser(userJson);
      }

      return user;
    } catch (e) {
      if (e is AuthException) rethrow;
      throw const AuthException('Error de conexión con el servidor');
    }
  }

  // CORRECCIÓN: Mapeo ajustado a los nombres de tu backend C#
  UserEntity _mapToUser(Map<String, dynamic> data, String email) {
    return UserEntity(
      id: data['id']?.toString() ?? '0',
      name: data['nombre']?.toString() ?? 'Sin nombre', // 'nombre' viene de tu API
      email: data['email']?.toString() ?? email,
      role: (data['rol']?.toString().toLowerCase() == 'administrador') 
          ? UserRole.admin 
          : UserRole.employee,
    );
  }

  String? _extractErrorMessage(String body) {
    try {
      final data = jsonDecode(body);
      return data['message']?.toString();
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> _saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_user', jsonEncode(user));
  }

  Future<UserEntity?> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    if (token.isEmpty) return null;

    final userJson = prefs.getString('auth_user');
    if (userJson == null || userJson.isEmpty) return null;

    final Map<String, dynamic> data = jsonDecode(userJson);
    return _mapToUser(data, data['email']?.toString() ?? '');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('auth_user');
  }
}