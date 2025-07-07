import '../models/creator.dart';
import '../models/user.dart';
import '../models/profile_models.dart';
import '../services/api_service_new.dart';
import 'api_service.dart';
import 'dart:io';

class CreatorService {
  // Demander le statut de créateur
  static Future<Map<String, dynamic>> becomeCreator({
    required String biography,
    required List<String> categories,
    String? websiteUrl,
    Map<String, String>? socialLinks,
  }) async {
    try {
      final requestData = {
        'biography': biography,
        'categories': categories,
        if (websiteUrl != null && websiteUrl.isNotEmpty) 'website_url': websiteUrl,
        if (socialLinks != null && socialLinks.isNotEmpty) 'social_links': socialLinks,
      };

      final responseData = await ApiService.post('/creators/become', 
        body: requestData, 
        requiresAuth: true
      );
      return responseData;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur lors de la demande de statut créateur.');
    }
  }

  // Demander le statut de créateur (ancienne méthode pour compatibilité)
  static Future<Creator> requestCreatorStatus() async {
    try {
      final responseData = await ApiService.post('/creators/become', requiresAuth: true);
      return Creator.fromJson(responseData['data']);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur lors de la demande de statut créateur.');
    }
  }

  // Obtenir la liste des créateurs avec filtres
  static Future<List<Creator>> getCreators({
    int page = 1,
    int perPage = 20,
    String? sort,
    String? order,
    String? search,
    bool? featured,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'per_page': perPage.toString(),
      };
      
      if (sort != null) queryParams['sort'] = sort;
      if (order != null) queryParams['order'] = order;
      if (search != null) queryParams['search'] = search;
      if (featured != null) queryParams['featured'] = featured.toString();
      
      final query = Uri(queryParameters: queryParams).query;
      final responseData = await ApiService.get('/creators?$query');
      
      final creatorsData = responseData['data'] as List;
      return creatorsData.map((creatorData) => Creator.fromJson(creatorData)).toList();
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur lors de la récupération des créateurs.');
    }
  }

  // Obtenir le profil d'un créateur
  static Future<Creator> getCreatorById(String creatorId) async {
    try {
      final responseData = await ApiService.get('/creators/$creatorId');
      return Creator.fromJson(responseData['data']);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur lors de la récupération du créateur.');
    }
  }

  // Mettre à jour le profil d'un créateur
  static Future<Creator> updateCreator(String creatorId, Map<String, dynamic> updates) async {
    try {
      final responseData = await ApiService.put('/creators/$creatorId', 
          body: updates, requiresAuth: true);
      return Creator.fromJson(responseData['data']);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur lors de la mise à jour du créateur.');
    }
  }

  // Télécharger une bannière
  static Future<Creator> uploadBanner(String creatorId, String imagePath) async {
    try {
      // Note: Cette méthode nécessiterait une implémentation multipart/form-data
      final responseData = await ApiService.put('/creators/$creatorId/banner', 
          requiresAuth: true);
      return Creator.fromJson(responseData['data']);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur lors du téléchargement de la bannière.');
    }
  }

  // Obtenir la liste des abonnés d'un créateur
  static Future<List<User>> getCreatorSubscribers(String creatorId) async {
    try {
      final responseData = await ApiService.get('/creators/$creatorId/subscribers', 
          requiresAuth: true);
      
      final subscribersData = responseData['data'] as List;
      return subscribersData.map((userData) => User.fromJson(userData)).toList();
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur lors de la récupération des abonnés.');
    }
  }

  // Obtenir les statistiques d'un créateur
  static Future<CreatorStats> getCreatorStats(String creatorId) async {
    try {
      final responseData = await ApiService.get('/creators/$creatorId/stats', 
          requiresAuth: true);
      return CreatorStats.fromJson(responseData['data']);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur lors de la récupération des statistiques.');
    }
  }

  // Obtenir les créateurs mis en avant
  static Future<List<Creator>> getFeaturedCreators() async {
    try {
      final responseData = await ApiService.get('/creators/featured');
      
      final creatorsData = responseData['data'] as List;
      return creatorsData.map((creatorData) => Creator.fromJson(creatorData)).toList();
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur lors de la récupération des créateurs mis en avant.');
    }
  }

  // Rechercher des créateurs
  static Future<List<Creator>> searchCreators(String query, {
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final queryParams = <String, String>{
        'q': query,
        'page': page.toString(),
        'per_page': perPage.toString(),
      };
      
      final queryString = Uri(queryParameters: queryParams).query;
      final responseData = await ApiService.get('/creators/search?$queryString');
      
      final creatorsData = responseData['data'] as List;
      return creatorsData.map((creatorData) => Creator.fromJson(creatorData)).toList();
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur lors de la recherche des créateurs.');
    }
  }

  // ===== NOUVELLES MÉTHODES D'ÉDITION DE PROFIL CRÉATEUR =====

  // Obtenir le profil détaillé d'un créateur
  static Future<CreatorProfile> getCreatorProfile(String creatorId) async {
    try {
      final responseData = await ApiService.get('/creators/$creatorId/profile', 
          requiresAuth: true);
      return CreatorProfile.fromJson(responseData['data']);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur lors de la récupération du profil créateur.');
    }
  }

  // Mettre à jour le profil créateur
  static Future<ApiResponse<CreatorProfile>> updateCreatorProfile(
    String creatorId, 
    UpdateCreatorRequest request
  ) async {
    try {
      final responseData = await ApiServiceNew.put('/creators/$creatorId/profile', 
          body: request.toJson(), requiresAuth: true);
      return ApiResponse<CreatorProfile>.fromJson(
        responseData, 
        (data) => CreatorProfile.fromJson(data as Map<String, dynamic>)
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur lors de la mise à jour du profil créateur.');
    }
  }

  // Télécharger une nouvelle bannière
  static Future<ApiResponse<String>> uploadCreatorBanner(
    String creatorId, 
    File imageFile
  ) async {
    try {
      final response = await ApiServiceNew.uploadFile(
        '/creators/$creatorId/banner',
        imageFile,
        fieldName: 'banner'
      );
      return ApiResponse<String>.fromJson(
        response, 
        (data) => data['banner_url'] as String
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur lors du téléchargement de la bannière.');
    }
  }

  // Supprimer la bannière
  static Future<ApiResponse<void>> deleteCreatorBanner(String creatorId) async {
    try {
      final responseData = await ApiServiceNew.delete('/creators/$creatorId/banner', 
          requiresAuth: true);
      return ApiResponse<void>.fromJson(responseData, (_) => null);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur lors de la suppression de la bannière.');
    }
  }

  // Mettre à jour le prix d'abonnement
  static Future<ApiResponse<CreatorProfile>> updateSubscriptionPrice(
    String creatorId, 
    double newPrice
  ) async {
    try {
      final responseData = await ApiServiceNew.put('/creators/$creatorId/subscription-price', 
          body: {'subscription_price': newPrice}, requiresAuth: true);
      return ApiResponse<CreatorProfile>.fromJson(
        responseData, 
        (data) => CreatorProfile.fromJson(data as Map<String, dynamic>)
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur lors de la mise à jour du prix d\'abonnement.');
    }
  }

  // Obtenir les gains du créateur
  static Future<ApiResponse<CreatorEarnings>> getCreatorEarnings(
    String creatorId, 
    {int? year, int? month}
  ) async {
    try {
      final queryParams = <String, String>{};
      if (year != null) queryParams['year'] = year.toString();
      if (month != null) queryParams['month'] = month.toString();
      
      final query = queryParams.isNotEmpty ? '?${Uri(queryParameters: queryParams).query}' : '';
      final responseData = await ApiServiceNew.get('/creators/$creatorId/earnings$query', 
          requiresAuth: true);
      
      return ApiResponse<CreatorEarnings>.fromJson(
        responseData, 
        (data) => CreatorEarnings.fromJson(data as Map<String, dynamic>)
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur lors de la récupération des gains.');
    }
  }

  // Valider le prix d'abonnement
  static Future<ApiResponse<bool>> validateSubscriptionPrice(double price) async {
    try {
      final responseData = await ApiServiceNew.post('/creators/validate-price', 
          body: {'price': price}, requiresAuth: true);
      return ApiResponse<bool>.fromJson(
        responseData, 
        (data) => data['valid'] as bool
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur lors de la validation du prix.');
    }
  }

  // Obtenir les catégories disponibles
  static Future<ApiResponse<List<String>>> getAvailableCategories() async {
    try {
      final responseData = await ApiServiceNew.get('/creators/categories');
      return ApiResponse<List<String>>.fromJson(
        responseData, 
        (data) => (data['categories'] as List).cast<String>()
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur lors de la récupération des catégories.');
    }
  }
}
