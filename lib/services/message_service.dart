import 'dart:io';
import '../models/models.dart';
import '../constants/constants.dart';
import '../utils/message_validators.dart';
import 'api_service.dart';

class MessageService {
  // ========== Messages CRUD ==========
  
  /// Récupère les messages d'une conversation avec pagination
  static Future<MessagesResponse?> getMessages({
    required String conversationId,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final response = await ApiService.getWithParams(
        '/conversations/$conversationId/messages',
        queryParameters: {
          'page': page.toString(),
          'limit': limit.toString(),
        },
      );

      return MessagesResponse.fromJson(response);
    } catch (e) {
      print('Error getting messages: $e');
      if (e is ApiException) {
        rethrow;
      }
      throw MessageException('Erreur lors de la récupération des messages');
    }
  }

  /// Envoie un message (texte ou média)
  static Future<Message?> sendMessage(SendMessageRequest request) async {
    try {
      // Validation côté client
      final validationError = MessageValidators.validateSendMessageRequest(request);
      if (validationError != null) {
        throw MessageException(validationError);
      }

      final response = await ApiService.post(
        '/messages',
        body: request.toJson(),
        requiresAuth: true,
      );

      return Message.fromJson(response);
    } catch (e) {
      print('Error sending message: $e');
      if (e is ApiException) {
        rethrow;
      }
      throw MessageException('Erreur lors de l\'envoi du message');
    }
  }

  /// Marque un message comme lu
  static Future<bool> markMessageAsRead(String messageId) async {
    try {
      await ApiService.put('/messages/$messageId/read', requiresAuth: true);
      return true;
    } catch (e) {
      print('Error marking message as read: $e');
      return false;
    }
  }

  /// Supprime un message (soft delete)
  static Future<bool> deleteMessage(String messageId) async {
    try {
      await ApiService.delete('/messages/$messageId', requiresAuth: true);
      return true;
    } catch (e) {
      print('Error deleting message: $e');
      return false;
    }
  }

  /// Récupère les statistiques des messages
  static Future<MessageStatsResponse?> getMessageStats() async {
    try {
      final response = await ApiService.get('/messages/stats', requiresAuth: true);
      return MessageStatsResponse.fromJson(response);
    } catch (e) {
      print('Error getting message stats: $e');
      return null;
    }
  }

  // ========== Upload Médias ==========

  /// Upload un fichier média pour message
  static Future<String?> uploadMedia({
    required File file,
    required String mimeType,
    Function(double)? onProgress,
  }) async {
    try {
      // Validation fichier
      final validation = await _validateMediaFile(file, mimeType);
      if (!validation.isValid) {
        throw MessageException(validation.error!);
      }

      final response = await ApiService.uploadFile(
        '/upload/chat-media',
        file: file,
        fieldName: 'media',
        mimeType: mimeType,
        onProgress: onProgress,
        requiresAuth: true,
      );

      return response['media_url'] as String?;
    } catch (e) {
      print('Error uploading media: $e');
      if (e is ApiException) {
        rethrow;
      }
      throw MessageException('Erreur lors de l\'upload du média');
    }
  }

  /// Génère une miniature pour vidéo (si nécessaire)
  static Future<String?> generateVideoThumbnail(String videoUrl) async {
    try {
      final response = await ApiService.post(
        '/media/generate-thumbnail',
        body: {'video_url': videoUrl},
        requiresAuth: true,
      );

      return response['thumbnail_url'] as String?;
    } catch (e) {
      print('Error generating thumbnail: $e');
      return null;
    }
  }

  // ========== Helpers Privés ==========

  static Future<MediaValidationResult> _validateMediaFile(File file, String mimeType) async {
    // Vérifier existence fichier
    if (!await file.exists()) {
      return MediaValidationResult(false, 'Le fichier n\'existe pas');
    }

    // Vérifier taille
    final fileSize = await file.length();
    final maxSize = MessageConstants.maxMediaFileSizeMB * 1024 * 1024;
    if (fileSize > maxSize) {
      return MediaValidationResult(
        false, 
        'Fichier trop volumineux (max ${MessageConstants.maxMediaFileSizeMB}MB)'
      );
    }

    // Vérifier type MIME
    if (!MessageConstants.isAllowedMimeType(mimeType)) {
      return MediaValidationResult(false, 'Type de fichier non supporté');
    }

    return MediaValidationResult(true, null);
  }
}

/// Résultat de validation média
class MediaValidationResult {
  final bool isValid;
  final String? error;

  MediaValidationResult(this.isValid, this.error);
}

/// Exception personnalisée pour les messages
class MessageException implements Exception {
  final String message;
  MessageException(this.message);
  
  @override
  String toString() => 'MessageException: $message';
}
