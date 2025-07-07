import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/content_models.dart';
import '../models/user_models.dart';
import '../config/api_config.dart';

class ContentApiService {
  static const String baseUrl = ApiConfig.baseUrl;

  // Récupérer le token d'authentification
  static Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Headers avec authentification
  static Future<Map<String, String>> _getHeaders() async {
    final token = await _getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Headers pour multipart (upload de fichiers)
  static Future<Map<String, String>> _getMultipartHeaders() async {
    final token = await _getAuthToken();
    return {
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Validation des données de contenu selon le rôle utilisateur
  static String? validateContentData({
    required String title,
    required String description,
    required String type,
    required UserRole userRole,
    required bool isPremium,
  }) {
    // Validation des champs obligatoires
    if (title.trim().isEmpty) {
      return 'Le titre est obligatoire';
    }
    if (title.trim().length < 3) {
      return 'Le titre doit contenir au moins 3 caractères';
    }
    if (description.trim().isEmpty) {
      return 'La description est obligatoire';
    }
    if (description.trim().length < 10) {
      return 'La description doit contenir au moins 10 caractères';
    }

    // Validation du type de contenu
    if (!['image', 'video', 'text'].contains(type)) {
      return 'Type de contenu non valide';
    }

    // Validation selon le rôle utilisateur
    if (isPremium && userRole == UserRole.subscriber) {
      return 'Seuls les créateurs peuvent publier du contenu premium';
    }

    return null; // Pas d'erreur
  }

  // Vérifier si un utilisateur peut publier du contenu premium
  static bool canPublishPremium(UserRole userRole) {
    return userRole == UserRole.creator || userRole == UserRole.admin;
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
      final headers = await _getHeaders();
      
      final body = {
        'title': title,
        'description': description,
        'type': type,
        'is_premium': isPremium,
        'is_published': isPublished,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/contents'),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 201) {
        final contentData = json.decode(response.body);
        return {
          'success': true,
          'id': contentData['id'],
          'content': contentData,
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'error': errorData['error'] ?? 'Erreur lors de la création du contenu',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Erreur de connexion: $e',
      };
    }
  }

  // Upload de média pour un contenu
  static Future<Map<String, dynamic>> uploadContentMedia({
    required int contentId,
    required File mediaFile,
    Function(double)? onProgress,
  }) async {
    try {
      final headers = await _getMultipartHeaders();
      
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/v1/contents/$contentId/media'),
      );

      // Ajouter les headers
      request.headers.addAll(headers);

      // Ajouter le fichier
      var stream = http.ByteStream(mediaFile.openRead());
      var length = await mediaFile.length();
      
      var multipartFile = http.MultipartFile(
        'media',
        stream,
        length,
        filename: mediaFile.path.split('/').last,
      );
      
      request.files.add(multipartFile);

      // Envoyer la requête
      var streamedResponse = await request.send();
      
      // Traiter la réponse
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': json.decode(response.body),
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'error': errorData['error'] ?? 'Erreur lors de l\'upload du média',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Erreur de connexion: $e',
      };
    }
  }

  // Upload de média pour un contenu (version XFile pour Web)
  static Future<Map<String, dynamic>> uploadContentMediaFromXFile({
    required int contentId,
    required XFile mediaFile,
    Function(double)? onProgress,
  }) async {
    try {
      final headers = await _getMultipartHeaders();
      
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/v1/contents/$contentId/media'),
      );

      // Ajouter les headers
      request.headers.addAll(headers);

      // Ajouter le fichier depuis XFile
      var bytes = await mediaFile.readAsBytes();
      
      var multipartFile = http.MultipartFile.fromBytes(
        'media',
        bytes,
        filename: mediaFile.name,
      );
      
      request.files.add(multipartFile);

      // Envoyer la requête
      var streamedResponse = await request.send();
      
      // Traiter la réponse
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': json.decode(response.body),
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'error': errorData['error'] ?? 'Erreur lors de l\'upload du média',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Erreur de connexion: $e',
      };
    }
  }

  // Récupérer les contenus avec pagination
  static Future<Map<String, dynamic>> getContents({
    int page = 1,
    int size = 10,
    String? type,
    String? creatorId,
  }) async {
    try {
      final headers = await _getHeaders();
      
      var queryParams = <String, String>{
        'page': page.toString(),
        'size': size.toString(),
      };

      if (type != null) queryParams['type'] = type;
      if (creatorId != null) queryParams['creator_id'] = creatorId;

      final uri = Uri.parse('$baseUrl/api/v1/contents').replace(
        queryParameters: queryParams,
      );

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'contents': (data['contents'] as List)
              .map((json) => Content.fromJson(json))
              .toList(),
          'pagination': data['pagination'],
        };
      } else {
        return {
          'success': false,
          'error': 'Erreur lors de la récupération des contenus',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Erreur de connexion: $e',
      };
    }
  }

  // Récupérer un contenu spécifique
  static Future<Map<String, dynamic>> getContent(int contentId) async {
    try {
      final headers = await _getHeaders();
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/contents/$contentId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'content': Content.fromJson(json.decode(response.body)),
        };
      } else {
        return {
          'success': false,
          'error': 'Contenu non trouvé',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Erreur de connexion: $e',
      };
    }
  }

  // Mettre à jour un contenu
  static Future<Map<String, dynamic>> updateContent({
    required int contentId,
    String? title,
    String? description,
    bool? isPremium,
    bool? isPublished,
  }) async {
    try {
      final headers = await _getHeaders();
      
      final body = <String, dynamic>{};
      if (title != null) body['title'] = title;
      if (description != null) body['description'] = description;
      if (isPremium != null) body['is_premium'] = isPremium;
      if (isPublished != null) body['is_published'] = isPublished;

      final response = await http.put(
        Uri.parse('$baseUrl/api/v1/contents/$contentId'),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'content': Content.fromJson(json.decode(response.body)),
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'error': errorData['error'] ?? 'Erreur lors de la mise à jour',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Erreur de connexion: $e',
      };
    }
  }

  // Supprimer un contenu
  static Future<Map<String, dynamic>> deleteContent(int contentId) async {
    try {
      final headers = await _getHeaders();
      
      final response = await http.delete(
        Uri.parse('$baseUrl/api/v1/contents/$contentId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Contenu supprimé avec succès',
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'error': errorData['error'] ?? 'Erreur lors de la suppression',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Erreur de connexion: $e',
      };
    }
  }
}
