import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/content_models.dart';
import '../models/user_models.dart';
import 'api_service.dart';

class ContentCreationService {
  static const String baseUrl = 'http://localhost:8080/api/v1';
  
  // Récupérer le token JWT depuis le stockage local
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Créer un nouveau contenu
  static Future<Map<String, dynamic>> createContent({
    required String title,
    required String description,
    required String type,
    required bool isPremium,
    bool isPublished = true,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Token d\'authentification manquant');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/contents'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'title': title,
          'description': description,
          'type': type,
          'is_premium': isPremium,
          'is_published': isPublished,
        }),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Erreur lors de la création du contenu');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Uploader un média pour un contenu
  static Future<Map<String, dynamic>> uploadMedia({
    required int contentId,
    required File mediaFile,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Token d\'authentification manquant');
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/contents/$contentId/upload'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(
        await http.MultipartFile.fromPath('media', mediaFile.path),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Erreur lors de l\'upload du média');
      }
    } catch (e) {
      throw Exception('Erreur lors de l\'upload: $e');
    }
  }

  // Récupérer les contenus de l'utilisateur connecté
  static Future<List<Content>> getUserContents() async {
    try {
      final responseData = await ApiService.get('/contents/my');
      
      return (responseData['contents'] as List)
          .map((contentData) => Content.fromJson(contentData))
          .toList();
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur lors de la récupération des contenus.');
    }
  }

  // Mettre à jour un contenu
  static Future<Content> updateContent({
    required int contentId,
    String? title,
    String? description,
    bool? isPremium,
    bool? isPublished,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (title != null) updateData['title'] = title;
      if (description != null) updateData['description'] = description;
      if (isPremium != null) updateData['is_premium'] = isPremium;
      if (isPublished != null) updateData['is_published'] = isPublished;

      final responseData = await ApiService.put('/contents/$contentId', body: updateData, requiresAuth: true);
      return Content.fromJson(responseData);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur lors de la mise à jour du contenu.');
    }
  }

  // Supprimer un contenu
  static Future<void> deleteContent(int contentId) async {
    try {
      await ApiService.delete('/contents/$contentId');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur lors de la suppression du contenu.');
    }
  }

  // Vérifier les permissions de publication selon le rôle
  static bool canPublishPremium(UserRole userRole) {
    return userRole == UserRole.creator || userRole == UserRole.admin;
  }

  // Obtenir les types de contenu autorisés
  static List<String> getAllowedContentTypes() {
    return ['image', 'video', 'text'];
  }

  // Valider les données de création de contenu
  static String? validateContentData({
    required String title,
    required String description,
    required String type,
    required UserRole userRole,
    required bool isPremium,
  }) {
    if (title.trim().isEmpty) {
      return 'Le titre est requis';
    }
    
    if (title.length > 200) {
      return 'Le titre ne peut pas dépasser 200 caractères';
    }
    
    if (description.length > 2000) {
      return 'La description ne peut pas dépasser 2000 caractères';
    }
    
    if (!getAllowedContentTypes().contains(type)) {
      return 'Type de contenu invalide';
    }
    
    if (isPremium && !canPublishPremium(userRole)) {
      return 'Vous ne pouvez pas publier de contenu premium';
    }
    
    return null; // Pas d'erreur
  }
}
