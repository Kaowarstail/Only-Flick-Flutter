import '../models/user_models.dart';
import 'api_service.dart';

class UserService {
  // Obtenir la liste des utilisateurs (admin seulement)
  static Future<List<User>> getUsers({
    int page = 1,
    int perPage = 20,
    String? sort,
    String? order,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'per_page': perPage.toString(),
      };
      
      if (sort != null) queryParams['sort'] = sort;
      if (order != null) queryParams['order'] = order;
      
      final query = Uri(queryParameters: queryParams).query;
      final responseData = await ApiService.get('/users?$query', requiresAuth: true);
      
      final usersData = responseData['data'] as List;
      return usersData.map((userData) => User.fromJson(userData)).toList();
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur lors de la récupération des utilisateurs.');
    }
  }

  // Obtenir les détails d'un utilisateur
  static Future<User> getUserById(String userId) async {
    try {
      final responseData = await ApiService.get('/users/$userId', requiresAuth: true);
      return User.fromJson(responseData['data']);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur lors de la récupération de l\'utilisateur.');
    }
  }

  // Mettre à jour un utilisateur
  static Future<User> updateUser(String userId, Map<String, dynamic> updates) async {
    try {
      final responseData = await ApiService.put('/users/$userId', 
          body: updates, requiresAuth: true);
      return User.fromJson(responseData['data']);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur lors de la mise à jour de l\'utilisateur.');
    }
  }

  // Supprimer un utilisateur
  static Future<void> deleteUser(String userId) async {
    try {
      await ApiService.delete('/users/$userId', requiresAuth: true);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur lors de la suppression de l\'utilisateur.');
    }
  }

  // Télécharger une photo de profil
  static Future<User> uploadProfilePicture(String userId, String imagePath) async {
    try {
      // Note: Cette méthode nécessiterait une implémentation multipart/form-data
      // Pour l'instant, on simule l'appel
      final responseData = await ApiService.put('/users/$userId/profile-pic', 
          requiresAuth: true);
      return User.fromJson(responseData['data']);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur lors du téléchargement de la photo de profil.');
    }
  }

  // Obtenir la liste des créateurs suivis
  static Future<List<dynamic>> getFollowingCreators(String userId) async {
    try {
      final responseData = await ApiService.get('/users/$userId/following', 
          requiresAuth: true);
      return responseData['data'] as List;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur lors de la récupération des créateurs suivis.');
    }
  }

  // Bloquer un utilisateur
  static Future<void> blockUser(String userId, String targetUserId) async {
    try {
      await ApiService.post('/users/$userId/block/$targetUserId', 
          requiresAuth: true);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur lors du blocage de l\'utilisateur.');
    }
  }

  // Débloquer un utilisateur
  static Future<void> unblockUser(String userId, String targetUserId) async {
    try {
      await ApiService.delete('/users/$userId/block/$targetUserId', 
          requiresAuth: true);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur lors du déblocage de l\'utilisateur.');
    }
  }

  // Obtenir la liste des utilisateurs bloqués
  static Future<List<User>> getBlockedUsers(String userId) async {
    try {
      final responseData = await ApiService.get('/users/$userId/blocked', 
          requiresAuth: true);
      
      final usersData = responseData['data'] as List;
      return usersData.map((userData) => User.fromJson(userData)).toList();
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur lors de la récupération des utilisateurs bloqués.');
    }
  }
}
