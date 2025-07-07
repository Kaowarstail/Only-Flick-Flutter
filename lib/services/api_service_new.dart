import 'dart:convert';
import 'dart:async';
import 'dart:io';
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

/// Generic API response wrapper for consistent response handling
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final int? statusCode;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.statusCode,
  });

  factory ApiResponse.success(T data, {String? message}) {
    return ApiResponse<T>(
      success: true,
      data: data,
      message: message,
    );
  }

  factory ApiResponse.error(String message, {int? statusCode}) {
    return ApiResponse<T>(
      success: false,
      message: message,
      statusCode: statusCode,
    );
  }
}

class ApiService {
  static final String _baseUrl = dotenv.env['API_URL'] ?? 'http://localhost:8080';
  static const String _apiVersion = '/api/v1';
  static const Duration _timeout = Duration(seconds: 30);

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
      final response = await _client.get(url, headers: headers).timeout(_timeout);
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Méthode POST
  static Future<Map<String, dynamic>> post(
    String endpoint, 
    Map<String, dynamic> data, {
    bool requiresAuth = true,
    Map<String, String>? additionalHeaders,
  }) async {
    final url = Uri.parse('$_baseUrl$_apiVersion$endpoint');
    final headers = requiresAuth ? await _getAuthHeaders() : Map<String, String>.from(_defaultHeaders);
    
    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }

    try {
      final response = await _client.post(
        url,
        headers: headers,
        body: jsonEncode(data),
      ).timeout(_timeout);
      
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Méthode PUT
  static Future<Map<String, dynamic>> put(
    String endpoint, 
    Map<String, dynamic> data, {
    bool requiresAuth = true,
  }) async {
    final url = Uri.parse('$_baseUrl$_apiVersion$endpoint');
    final headers = requiresAuth ? await _getAuthHeaders() : _defaultHeaders;

    try {
      final response = await _client.put(
        url,
        headers: headers,
        body: jsonEncode(data),
      ).timeout(_timeout);
      
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Méthode DELETE
  static Future<Map<String, dynamic>> delete(String endpoint, {bool requiresAuth = true}) async {
    final url = Uri.parse('$_baseUrl$_apiVersion$endpoint');
    final headers = requiresAuth ? await _getAuthHeaders() : _defaultHeaders;

    try {
      final response = await _client.delete(url, headers: headers).timeout(_timeout);
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Méthode pour upload de fichiers avec multipart
  static Future<ApiResponse<Map<String, dynamic>>> uploadFile(
    String endpoint,
    File file, {
    String fieldName = 'file',
    Map<String, String>? additionalFields,
    bool requiresAuth = true,
  }) async {
    final url = Uri.parse('$_baseUrl$_apiVersion$endpoint');
    
    try {
      // Créer une requête multipart
      final request = http.MultipartRequest('POST', url);
      
      // Ajouter les headers d'authentification
      if (requiresAuth) {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');
        if (token != null) {
          request.headers['Authorization'] = 'Bearer $token';
        }
      }
      
      // Ajouter le fichier
      final fileMultipart = await http.MultipartFile.fromPath(fieldName, file.path);
      request.files.add(fileMultipart);
      
      // Ajouter des champs additionnels si fournis
      if (additionalFields != null) {
        request.fields.addAll(additionalFields);
      }
      
      // Envoyer la requête
      final streamedResponse = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamedResponse);
      
      final responseData = _handleResponse(response);
      return ApiResponse.success(responseData, message: 'Upload réussi');
    } catch (e) {
      return ApiResponse.error(_handleError(e).message);
    }
  }

  // Gestion des réponses
  static Map<String, dynamic> _handleResponse(http.Response response) {
    final responseData = jsonDecode(response.body);

    // Vérifier le statut de la réponse HTTP
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Réponse de succès
      return responseData;
    } else {
      // Réponse d'erreur - le backend Go utilise le format {"error": "message"}
      String errorMessage = 'Erreur ${response.statusCode}';
      
      if (responseData is Map<String, dynamic>) {
        if (responseData.containsKey('error')) {
          errorMessage = responseData['error'].toString();
        } else if (responseData.containsKey('message')) {
          errorMessage = responseData['message'].toString();
        }
      }
      
      throw ApiException(errorMessage, response.statusCode);
    }
  }

  // Gestion des erreurs
  static ApiException _handleError(dynamic error) {
    if (error is ApiException) {
      return error;
    }
    
    // Gestion des timeouts
    if (error.toString().contains('TimeoutException')) {
      return ApiException('Timeout: Le serveur met trop de temps à répondre. Veuillez réessayer.');
    }
    
    // Gestion des erreurs de connexion
    if (error.toString().contains('SocketException') || 
        error.toString().contains('HandshakeException') ||
        error.toString().contains('Connection refused')) {
      return ApiException('Impossible de se connecter au serveur. Vérifiez votre connexion internet.');
    }
    
    return ApiException('Erreur de réseau. Vérifiez votre connexion.');
  }

  // Nettoyer les ressources
  static void dispose() {
    _client.close();
  }
}
