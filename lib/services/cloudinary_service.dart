import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CloudinaryService {
  final String baseUrl;
  final Dio _dio = Dio();
  final String authToken;

  CloudinaryService({required this.baseUrl, required this.authToken});

  // Upload d'une image de contenu directement vers l'API Go
  Future<Map<String, dynamic>> uploadContentImage(
      {required File imageFile, required String contentId}) async {
    try {
      // Préparer les données multipart pour l'upload
      String fileName = imageFile.path.split('/').last;
      FormData formData = FormData.fromMap({
        'media': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      // Headers avec authentification
      Map<String, dynamic> headers = {
        'Authorization': 'Bearer $authToken',
      };

      // Upload vers l'API Go qui gérera l'upload vers Cloudinary
      Response response = await _dio.post(
        '$baseUrl/api/v1/contents/$contentId/media',
        data: formData,
        options: Options(headers: headers),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception(
            'Échec de l\'upload: ${response.statusCode} - ${response.statusMessage}');
      }
    } catch (e) {
      print('Erreur lors de l\'upload: $e');
      throw Exception('Erreur lors de l\'upload: $e');
    }
  }

  // Créer un nouveau contenu, puis uploader l'image
  Future<Map<String, dynamic>> createContentWithImage(
      {required String title,
      required String description,
      required String type,
      required bool isPremium,
      required File imageFile}) async {
    try {
      // 1. Créer le contenu d'abord
      var contentResponse = await http.post(
        Uri.parse('$baseUrl/api/v1/contents'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'title': title,
          'description': description,
          'type': type,
          'is_premium': isPremium,
          'is_published': true,
        }),
      );

      if (contentResponse.statusCode != 201 && contentResponse.statusCode != 200) {
        throw Exception(
            'Échec de création du contenu: ${contentResponse.statusCode}');
      }

      // 2. Récupérer l'ID du contenu créé
      Map<String, dynamic> content = jsonDecode(contentResponse.body);
      String contentId = content['id'].toString();

      // 3. Upload de l'image pour ce contenu
      Map<String, dynamic> uploadResult =
          await uploadContentImage(imageFile: imageFile, contentId: contentId);

      // 4. Retourner toutes les informations combinées
      return {
        'content': content,
        'upload_result': uploadResult,
      };
    } catch (e) {
      print('Erreur lors de la création et upload: $e');
      throw Exception('Erreur lors de la création et upload: $e');
    }
  }

  // Upload de photo de profil
  Future<Map<String, dynamic>> uploadProfilePicture(
      {required File imageFile, required String userId}) async {
    try {
      String fileName = imageFile.path.split('/').last;
      FormData formData = FormData.fromMap({
        'profile_picture': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      Response response = await _dio.put(
        '$baseUrl/api/v1/users/$userId/profile-pic',
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $authToken'}),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception(
            'Échec de l\'upload de photo de profil: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de l\'upload de photo de profil: $e');
      throw Exception('Erreur lors de l\'upload de photo de profil: $e');
    }
  }

  // Upload de bannière de créateur
  Future<Map<String, dynamic>> uploadBannerImage(
      {required File imageFile, required String creatorId}) async {
    try {
      String fileName = imageFile.path.split('/').last;
      FormData formData = FormData.fromMap({
        'banner_image': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      Response response = await _dio.put(
        '$baseUrl/api/v1/creators/$creatorId/banner',
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $authToken'}),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception(
            'Échec de l\'upload de bannière: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de l\'upload de bannière: $e');
      throw Exception('Erreur lors de l\'upload de bannière: $e');
    }
  }
}
