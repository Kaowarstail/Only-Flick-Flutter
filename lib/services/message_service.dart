import 'dart:async';
import '../models/models.dart';
import 'api_service.dart';

class MessageService {
  // ========== Messages Management ==========

  /// Récupère les messages d'une conversation avec pagination
  static Future<MessagesResponse?> getMessages({
    required String conversationId,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final response = await ApiService.get(
        '/conversations/$conversationId/messages',
        params: {
          'page': page.toString(),
          'limit': limit.toString(),
        },
      );

      if (response != null) {
        return MessagesResponse.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Error getting messages: $e');
      throw MessageException('Erreur lors de la récupération des messages');
    }
  }

  /// Envoie un message
  static Future<Message?> sendMessage(SendMessageRequest request) async {
    try {
      final response = await ApiService.post(
        '/messages',
        data: request.toJson(),
      );

      if (response != null) {
        return Message.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Error sending message: $e');
      throw MessageException('Erreur lors de l\'envoi du message');
    }
  }

  /// Marque un message comme lu
  static Future<bool> markMessageAsRead(String messageId) async {
    try {
      final response = await ApiService.put('/messages/$messageId/read');
      return response != null;
    } catch (e) {
      print('Error marking message as read: $e');
      return false;
    }
  }

  /// Supprime un message
  static Future<bool> deleteMessage(String messageId) async {
    try {
      final response = await ApiService.delete('/messages/$messageId');
      return response != null;
    } catch (e) {
      print('Error deleting message: $e');
      return false;
    }
  }

  /// Valide le contenu d'un message
  static MessageValidationResult validateMessage(String content) {
    if (content.trim().isEmpty) {
      return MessageValidationResult(false, 'Le message ne peut pas être vide');
    }

    if (content.length > MessageConstants.maxMessageLength) {
      return MessageValidationResult(false, 'Message trop long (max ${MessageConstants.maxMessageLength} caractères)');
    }

    return MessageValidationResult(true, null);
  }

  /// Recherche dans les messages
  static Future<List<Message>> searchMessages({
    required String query,
    String? conversationId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final params = {
        'q': query,
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (conversationId != null) {
        params['conversation_id'] = conversationId;
      }

      final response = await ApiService.get('/messages/search', params: params);

      if (response != null && response['messages'] != null) {
        return (response['messages'] as List)
            .map((json) => Message.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error searching messages: $e');
      return [];
    }
  }
}

/// Classe pour les constantes de messages
class MessageConstants {
  static const int maxMessageLength = 4000;
  static const int minMessageLength = 1;
  
  // Types de contenu supportés
  static const List<String> supportedImageTypes = [
    'image/jpeg',
    'image/png',
    'image/webp',
    'image/gif',
  ];
  
  static const List<String> supportedVideoTypes = [
    'video/mp4',
    'video/webm',
    'video/quicktime',
  ];
  
  static const List<String> supportedAudioTypes = [
    'audio/mpeg',
    'audio/wav',
    'audio/ogg',
  ];

  /// Vérifie si le type de média est supporté
  static bool isSupportedMediaType(String mimeType) {
    return supportedImageTypes.contains(mimeType) ||
           supportedVideoTypes.contains(mimeType) ||
           supportedAudioTypes.contains(mimeType);
  }
}

/// Résultat de validation de message
class MessageValidationResult {
  final bool isValid;
  final String? error;

  MessageValidationResult(this.isValid, this.error);
}

/// Exception spécifique aux messages
class MessageException implements Exception {
  final String message;
  MessageException(this.message);
  
  @override
  String toString() => 'MessageException: $message';
}

/// Modèles pour les réponses API

class MessagesResponse {
  final List<Message> messages;
  final bool hasMore;
  final int totalCount;

  MessagesResponse({
    required this.messages,
    required this.hasMore,
    required this.totalCount,
  });

  factory MessagesResponse.fromJson(Map<String, dynamic> json) {
    return MessagesResponse(
      messages: (json['messages'] as List? ?? [])
          .map((m) => Message.fromJson(m))
          .toList(),
      hasMore: json['has_more'] ?? false,
      totalCount: json['total_count'] ?? 0,
    );
  }
}

class SendMessageRequest {
  final String conversationId;
  final String content;
  final String? mediaUrl;
  final String? mediaType;
  final MessageType messageType;

  SendMessageRequest({
    required this.conversationId,
    required this.content,
    this.mediaUrl,
    this.mediaType,
    required this.messageType,
  });

  Map<String, dynamic> toJson() {
    return {
      'conversation_id': conversationId,
      'content': content,
      'media_url': mediaUrl,
      'media_type': mediaType,
      'message_type': messageType.toString().split('.').last,
    };
  }
}
