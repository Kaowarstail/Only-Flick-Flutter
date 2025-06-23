import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class ApiService {
  static final String _baseUrl = dotenv.env['API_URL'] ?? 'http://localhost:8080';
  static const String _apiVersion = '/api/v1';

  // Instance HTTP client
  static final http.Client _client = http.Client();

  // Headers par défaut
  static Map<String, String> get _defaultHeaders => {
    'Content-Type': 'application/json',
  };

  // Obtenir les headers avec authentification
  static Future<Map<String, String>> _getAuthHeaders() async {
    final headers = Map<String, String>.from(_defaultHeaders);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }

  // Méthode GET avec gestion automatique du token
  static Future<Map<String, dynamic>> get(String endpoint, {bool requiresAuth = true}) async {
    final url = Uri.parse('$_baseUrl$_apiVersion$endpoint');
    final headers = requiresAuth ? await _getAuthHeaders() : _defaultHeaders;

    try {
      final response = await _client.get(url, headers: headers);
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Méthode POST avec gestion automatique du token
  static Future<Map<String, dynamic>> post(
    String endpoint,
    {Map<String, dynamic>? body, bool requiresAuth = false}
  ) async {
    final url = Uri.parse('$_baseUrl$_apiVersion$endpoint');
    final headers = requiresAuth ? await _getAuthHeaders() : _defaultHeaders;

    try {
      final response = await _client.post(
        url,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Méthode PUT avec gestion automatique du token
  static Future<Map<String, dynamic>> put(
    String endpoint,
    {Map<String, dynamic>? body, bool requiresAuth = false}
  ) async {
    final url = Uri.parse('$_baseUrl$_apiVersion$endpoint');
    final headers = requiresAuth ? await _getAuthHeaders() : _defaultHeaders;

    try {
      final response = await _client.put(
        url,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Méthode DELETE avec gestion automatique du token
  static Future<Map<String, dynamic>> delete(
    String endpoint,
    {bool requiresAuth = true}
  ) async {
    final url = Uri.parse('$_baseUrl$_apiVersion$endpoint');
    final headers = requiresAuth ? await _getAuthHeaders() : _defaultHeaders;

    try {
      final response = await _client.delete(url, headers: headers);
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Gestion des réponses
  static Map<String, dynamic> _handleResponse(http.Response response) {
    final responseData = jsonDecode(response.body);

    // Vérifier le format de réponse standard de l'API Golang
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (responseData['success'] == true) {
        return responseData;
      } else {
        throw ApiException(
          responseData['error']?['message'] ?? 'Erreur inconnue',
          response.statusCode,
        );
      }
    } else {
      throw ApiException(
        responseData['error']?['message'] ?? 'Erreur ${response.statusCode}',
        response.statusCode,
      );
    }
  }

  // Gestion des erreurs
  static ApiException _handleError(dynamic error) {
    if (error is ApiException) {
      return error;
    }
    return ApiException('Erreur de réseau. Vérifiez votre connexion.');
  }

  // Méthode pour rafraîchir le token si nécessaire
  static Future<bool> _tryRefreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentToken = prefs.getString('auth_token');
      
      if (currentToken == null) return false;

      final response = await _client.post(
        Uri.parse('$_baseUrl$_apiVersion/auth/refresh-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $currentToken',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          final newToken = responseData['data']['token'];
          await prefs.setString('auth_token', newToken);
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Nettoyer les ressources
  static void dispose() {
    _client.close();
  }
}
