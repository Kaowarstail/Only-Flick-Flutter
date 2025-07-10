import '../models/models.dart';
import 'api_service.dart';

class ConversationService {
  // ========== Conversations CRUD ==========

  /// Récupère les conversations de l'utilisateur avec pagination
  static Future<ConversationsResponse?> getConversations({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await ApiService.getWithParams(
        '/conversations',
        queryParameters: {
          'page': page.toString(),
          'limit': limit.toString(),
        },
        requiresAuth: true,
      );

      return ConversationsResponse.fromJson(response);
    } catch (e) {
      print('Error getting conversations: $e');
      if (e is ApiException) {
        rethrow;
      }
      throw ConversationException('Erreur lors de la récupération des conversations');
    }
  }

  /// Crée ou récupère une conversation avec un autre utilisateur
  static Future<Conversation?> createOrGetConversation(String otherUserId) async {
    try {
      final request = CreateConversationRequest(otherUserId: otherUserId);
      
      if (!request.isValid) {
        throw ConversationException('ID utilisateur invalide');
      }

      final response = await ApiService.post(
        '/conversations',
        body: request.toJson(),
        requiresAuth: true,
      );

      return Conversation.fromJson(response);
    } catch (e) {
      print('Error creating/getting conversation: $e');
      if (e is ApiException) {
        rethrow;
      }
      throw ConversationException('Erreur lors de la création de la conversation');
    }
  }

  /// Récupère une conversation spécifique
  static Future<Conversation?> getConversation(String conversationId) async {
    try {
      final response = await ApiService.get(
        '/conversations/$conversationId',
        requiresAuth: true,
      );

      return Conversation.fromJson(response);
    } catch (e) {
      print('Error getting conversation: $e');
      if (e is ApiException) {
        rethrow;
      }
      return null;
    }
  }

  /// Marque une conversation comme lue
  static Future<bool> markConversationAsRead(String conversationId) async {
    try {
      await ApiService.put(
        '/conversations/$conversationId/read',
        requiresAuth: true,
      );
      return true;
    } catch (e) {
      print('Error marking conversation as read: $e');
      return false;
    }
  }

  /// Archive une conversation
  static Future<bool> archiveConversation(String conversationId) async {
    try {
      await ApiService.put(
        '/conversations/$conversationId/archive',
        requiresAuth: true,
      );
      return true;
    } catch (e) {
      print('Error archiving conversation: $e');
      return false;
    }
  }

  /// Supprime une conversation
  static Future<bool> deleteConversation(String conversationId) async {
    try {
      await ApiService.delete(
        '/conversations/$conversationId',
        requiresAuth: true,
      );
      return true;
    } catch (e) {
      print('Error deleting conversation: $e');
      return false;
    }
  }

  /// Recherche dans les conversations
  static Future<List<Conversation>> searchConversations({
    required String query,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      if (query.trim().isEmpty) return [];

      final response = await ApiService.getWithParams(
        '/conversations/search',
        queryParameters: {
          'query': query,
          'page': page.toString(),
          'limit': limit.toString(),
        },
        requiresAuth: true,
      );

      final conversations = response['conversations'] as List<dynamic>?;
      if (conversations != null) {
        return conversations
            .map((c) => Conversation.fromJson(c as Map<String, dynamic>))
            .toList();
      }
      
      return [];
    } catch (e) {
      print('Error searching conversations: $e');
      return [];
    }
  }

  /// Récupère les statistiques des conversations
  static Future<ConversationStatsResponse?> getConversationStats() async {
    try {
      final response = await ApiService.get(
        '/conversations/stats',
        requiresAuth: true,
      );

      return ConversationStatsResponse.fromJson(response);
    } catch (e) {
      print('Error getting conversation stats: $e');
      return null;
    }
  }

  /// Récupère le nombre total de messages non lus
  static Future<int> getTotalUnreadCount() async {
    try {
      final response = await ApiService.get(
        '/conversations/unread-count',
        requiresAuth: true,
      );

      return response['unread_count'] ?? 0;
    } catch (e) {
      print('Error getting unread count: $e');
      return 0;
    }
  }

  // ========== Helpers ==========

  /// Vérifie si l'utilisateur peut envoyer des messages à un autre utilisateur
  static Future<bool> canSendMessageTo(String otherUserId) async {
    try {
      final response = await ApiService.get(
        '/users/$otherUserId/can-message',
        requiresAuth: true,
      );

      return response['can_message'] ?? false;
    } catch (e) {
      print('Error checking message permission: $e');
      return false;
    }
  }

  /// Bloque un utilisateur (empêche les messages)
  static Future<bool> blockUser(String userId) async {
    try {
      await ApiService.post(
        '/users/$userId/block',
        requiresAuth: true,
      );
      return true;
    } catch (e) {
      print('Error blocking user: $e');
      return false;
    }
  }

  /// Débloque un utilisateur
  static Future<bool> unblockUser(String userId) async {
    try {
      await ApiService.delete(
        '/users/$userId/block',
        requiresAuth: true,
      );
      return true;
    } catch (e) {
      print('Error unblocking user: $e');
      return false;
    }
  }
}

/// Exception personnalisée pour les conversations
class ConversationException implements Exception {
  final String message;
  ConversationException(this.message);
  
  @override
  String toString() => 'ConversationException: $message';
}
