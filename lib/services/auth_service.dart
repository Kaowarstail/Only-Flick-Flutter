import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  static Future<AuthResponse> login(String email, String password) async {
    try {
      final responseData = await ApiService.post('/auth/login', body: {
        'email': email,
        'password': password,
      });

      return AuthResponse.fromJson(responseData['data']);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur de réseau. Vérifiez votre connexion.');
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

      return AuthResponse.fromJson(responseData['data']);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur de réseau. Vérifiez votre connexion.');
    }
  }

  static Future<User> getUserProfile(String token) async {
    try {
      final responseData = await ApiService.get('/auth/me', requiresAuth: true);
      return User.fromJson(responseData['data']);
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
      return responseData['data']['token'] ?? '';
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur de réseau. Vérifiez votre connexion.');
    }
  }
}
