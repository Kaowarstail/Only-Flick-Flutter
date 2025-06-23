import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null && _token != null;

  // Initialise l'auth provider au démarrage de l'app
  Future<void> initAuth() async {
    _setLoading(true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token != null) {
        final user = await AuthService.getUserProfile(token);
        _user = user;
        _token = token;
      }
    } catch (e) {
      // Token invalide, on le supprime
      await logout();
    }
    _setLoading(false);
  }

  Future<void> login(String email, String password) async {
    _setLoading(true);
    _clearError();
    
    try {
      final authResponse = await AuthService.login(email, password);
      await _saveAuthData(authResponse.token, authResponse.user);
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register(String email, String password, String username) async {
    _setLoading(true);
    _clearError();
    
    try {
      final authResponse = await AuthService.register(email, password, username);
      await _saveAuthData(authResponse.token, authResponse.user);
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    // Tenter de déconnecter côté serveur si on a un token
    if (_token != null) {
      try {
        await AuthService.logout(_token!);
      } catch (e) {
        // On ignore les erreurs de déconnexion côté serveur
      }
    }

    // Nettoyer les données locales
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
    
    _user = null;
    _token = null;
    _clearError();
    notifyListeners();
  }

  Future<void> requestPasswordReset(String email) async {
    _setLoading(true);
    _clearError();
    
    try {
      await AuthService.requestPasswordReset(email);
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> refreshToken() async {
    if (_token == null) return false;
    
    try {
      final newToken = await AuthService.refreshToken(_token!);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', newToken);
      _token = newToken;
      notifyListeners();
      return true;
    } catch (e) {
      // Si le rafraîchissement échoue, on déconnecte l'utilisateur
      await logout();
      return false;
    }
  }

  Future<void> _saveAuthData(String token, User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('user_data', user.toJson().toString());
    
    _token = token;
    _user = user;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
