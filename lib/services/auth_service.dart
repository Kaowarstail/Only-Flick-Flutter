import '../models/user_models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService {
  static Future<AuthResponse> login(String email, String password) async {
    try {
      final responseData = await ApiService.post('/auth/login', body: {
        'username': email, // Le backend attend 'username' mais accepte email ou username
        'password': password,
      });

      return AuthResponse.fromJson(responseData);
    } catch (e) {
      if (e is ApiException) {
        // Personnaliser les messages d'erreur selon le contexte
        if (e.message.contains('Timeout')) {
          throw ApiException('Connexion lente. Veuillez réessayer.');
        } else if (e.message.contains('serveur')) {
          throw ApiException('Serveur indisponible. Réessayez plus tard.');
        }
        rethrow;
      }
      throw ApiException('Erreur de connexion. Vérifiez votre réseau.');
    }
  }

  static Future<AuthResponse> register(
    String email,
    String password,
    String username,
  ) async {
    try {
      final responseData = await ApiService.post('/auth/register', body: {
        'email': email,
        'password': password,
        'username': username,
      });

      return AuthResponse.fromJson(responseData);
    } catch (e) {
      if (e is ApiException) {
        // Personnaliser les messages d'erreur selon le contexte
        if (e.message.contains('Timeout')) {
          throw ApiException('Connexion lente. Veuillez réessayer.');
        } else if (e.message.contains('serveur')) {
          throw ApiException('Serveur indisponible. Réessayez plus tard.');
        }
        rethrow;
      }
      throw ApiException('Erreur de connexion. Vérifiez votre réseau.');
    }
  }

  static Future<User> getUserProfile(String token) async {
    try {
      final responseData = await ApiService.get('/auth/me', requiresAuth: true);
      return User.fromJson(responseData);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur de réseau. Vérifiez votre connexion.');
    }
  }

  static Future<void> logout(String token) async {
    try {
      await ApiService.post('/auth/logout', requiresAuth: true);
    } catch (e) {
      // On ignore les erreurs de déconnexion côté serveur
      // car on va de toute façon supprimer le token localement
    }
  }

  static Future<void> requestPasswordReset(String email) async {
    try {
      await ApiService.post('/auth/reset-password', body: {
        'email': email,
      });
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur de réseau. Vérifiez votre connexion.');
    }
  }

  static Future<String> refreshToken(String currentToken) async {
    try {
      final responseData = await ApiService.post('/auth/refresh-token', requiresAuth: true);
      return responseData['token'] ?? '';
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur de réseau. Vérifiez votre connexion.');
    }
  }

  // Récupère le token d'authentification stocké
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
}
