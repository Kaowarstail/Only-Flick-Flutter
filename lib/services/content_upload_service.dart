import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;

class ContentUploadService {
  final Dio _dio;
  final String baseUrl;
  
  ContentUploadService({required this.baseUrl}) : _dio = Dio() {
    _dio.options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    );
  }

  /// Upload d'un nouveau contenu avec média
  Future<Map<String, dynamic>> createContentWithMedia({
    required String authToken,
    required String title,
    required String description,
    required File mediaFile,
    required String contentType, // 'image' ou 'video'
    bool isPremium = false,
    bool isPublished = true,
  }) async {
    try {
      print('📤 [ContentUploadService] Début de l\'upload de contenu');
      print('📝 Titre: $title');
      print('📁 Fichier: ${mediaFile.path}');
      print('🎯 Type: $contentType');

      // Préparer FormData
      FormData formData = FormData.fromMap({
        'title': title,
        'description': description,
        'type': contentType,
        'is_premium': isPremium.toString(),
        'is_published': isPublished.toString(),
        'media': await MultipartFile.fromFile(
          mediaFile.path,
          filename: path.basename(mediaFile.path),
          contentType: DioMediaType.parse(_getContentType(mediaFile.path)),
        ),
      });

      print('📦 FormData préparé');

      // Effectuer la requête
      Response response = await _dio.post(
        '/api/v1/contents/upload',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $authToken',
          },
        ),
      );

      print('✅ [ContentUploadService] Upload réussi!');
      print('📄 Réponse: ${response.data}');

      return {
        'success': true,
        'data': response.data,
        'message': 'Contenu uploadé avec succès',
      };
    } on DioException catch (e) {
      print('❌ [ContentUploadService] Erreur Dio: ${e.message}');
      print('📊 Status: ${e.response?.statusCode}');
      print('📄 Data: ${e.response?.data}');
      
      String errorMessage = 'Erreur lors de l\'upload';
      if (e.response?.data != null && e.response?.data['error'] != null) {
        errorMessage = e.response!.data['error'];
      } else if (e.message != null) {
        errorMessage = e.message!;
      }
      
      return {
        'success': false,
        'error': errorMessage,
        'statusCode': e.response?.statusCode,
      };
    } catch (e) {
      print('❌ [ContentUploadService] Erreur inconnue: $e');
      return {
        'success': false,
        'error': 'Erreur inconnue: $e',
      };
    }
  }

  /// Upload d'un média pour un contenu existant
  Future<Map<String, dynamic>> uploadMediaToContent({
    required String authToken,
    required String contentId,
    required File mediaFile,
  }) async {
    try {
      print('📤 [ContentUploadService] Upload de média pour contenu $contentId');

      FormData formData = FormData.fromMap({
        'media': await MultipartFile.fromFile(
          mediaFile.path,
          filename: path.basename(mediaFile.path),
          contentType: DioMediaType.parse(_getContentType(mediaFile.path)),
        ),
      });

      Response response = await _dio.post(
        '/api/v1/contents/$contentId/media',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $authToken',
          },
        ),
      );

      print('✅ [ContentUploadService] Upload de média réussi!');
      return {
        'success': true,
        'data': response.data,
        'message': 'Média uploadé avec succès',
      };
    } on DioException catch (e) {
      print('❌ [ContentUploadService] Erreur lors de l\'upload de média: ${e.message}');
      
      String errorMessage = 'Erreur lors de l\'upload du média';
      if (e.response?.data != null && e.response?.data['error'] != null) {
        errorMessage = e.response!.data['error'];
      }
      
      return {
        'success': false,
        'error': errorMessage,
        'statusCode': e.response?.statusCode,
      };
    } catch (e) {
      print('❌ [ContentUploadService] Erreur inconnue: $e');
      return {
        'success': false,
        'error': 'Erreur inconnue: $e',
      };
    }
  }

  /// Récupérer la liste des contenus
  Future<Map<String, dynamic>> getContents({
    int page = 1,
    int limit = 10,
    String? search,
    String? type,
    String? creatorId,
  }) async {
    try {
      Map<String, dynamic> queryParams = {
        'page': page,
        'limit': limit,
      };

      if (search != null) queryParams['search'] = search;
      if (type != null) queryParams['type'] = type;
      if (creatorId != null) queryParams['creator_id'] = creatorId;

      Response response = await _dio.get(
        '/api/v1/contents',
        queryParameters: queryParams,
      );

      return {
        'success': true,
        'data': response.data,
      };
    } on DioException catch (e) {
      print('❌ [ContentUploadService] Erreur lors de la récupération des contenus: ${e.message}');
      
      return {
        'success': false,
        'error': 'Erreur lors de la récupération des contenus',
        'statusCode': e.response?.statusCode,
      };
    } catch (e) {
      print('❌ [ContentUploadService] Erreur inconnue: $e');
      return {
        'success': false,
        'error': 'Erreur inconnue: $e',
      };
    }
  }

  /// Récupérer un contenu spécifique
  Future<Map<String, dynamic>> getContent(String contentId) async {
    try {
      Response response = await _dio.get('/api/v1/contents/$contentId');

      return {
        'success': true,
        'data': response.data,
      };
    } on DioException catch (e) {
      print('❌ [ContentUploadService] Erreur lors de la récupération du contenu: ${e.message}');
      
      return {
        'success': false,
        'error': 'Erreur lors de la récupération du contenu',
        'statusCode': e.response?.statusCode,
      };
    } catch (e) {
      print('❌ [ContentUploadService] Erreur inconnue: $e');
      return {
        'success': false,
        'error': 'Erreur inconnue: $e',
      };
    }
  }

  /// Détermine le type MIME d'un fichier en fonction de son extension
  String _getContentType(String filePath) {
    String extension = path.extension(filePath).toLowerCase();
    
    switch (extension) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.webp':
        return 'image/webp';
      case '.mp4':
        return 'video/mp4';
      case '.mov':
        return 'video/quicktime';
      case '.avi':
        return 'video/x-msvideo';
      case '.webm':
        return 'video/webm';
      default:
        return 'application/octet-stream';
    }
  }
}
