import 'dart:async';
import '../models/models.dart';
import 'api_service.dart';

class ConversationService {
  // ========== Conversation Management ==========

  /// Récupère les conversations de l'utilisateur avec pagination
  static Future<ConversationsResponse?> getConversations({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await ApiService.get(
        '/conversations',
        params: {
          'page': page.toString(),
          'limit': limit.toString(),
        },
      );

      if (response != null) {
        return ConversationsResponse.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Error getting conversations: $e');
      throw ConversationException('Erreur lors de la récupération des conversations');
    }
  }

  /// Récupère une conversation spécifique
  static Future<Conversation?> getConversation(String conversationId) async {
    try {
      final response = await ApiService.get('/conversations/$conversationId');

      if (response != null) {
        return Conversation.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Error getting conversation: $e');
      return null;
    }
  }

  /// Crée ou récupère une conversation avec un utilisateur
  static Future<Conversation?> createOrGetConversation(String otherUserId) async {
    try {
      final response = await ApiService.post(
        '/conversations',
        data: {'other_user_id': otherUserId},
      );

      if (response != null) {
        return Conversation.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Error creating conversation: $e');
      throw ConversationException('Erreur lors de la création de la conversation');
    }
  }

  /// Marque une conversation comme lue
  static Future<bool> markConversationAsRead(String conversationId) async {
    try {
      final response = await ApiService.put('/conversations/$conversationId/read');
      return response != null;
    } catch (e) {
      print('Error marking conversation as read: $e');
      return false;
    }
  }

  /// Archive une conversation
  static Future<bool> archiveConversation(String conversationId) async {
    try {
      final response = await ApiService.put('/conversations/$conversationId/archive');
      return response != null;
    } catch (e) {
      print('Error archiving conversation: $e');
      return false;
    }
  }

  /// Supprime une conversation
  static Future<bool> deleteConversation(String conversationId) async {
    try {
      final response = await ApiService.delete('/conversations/$conversationId');
      return response != null;
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
      final response = await ApiService.get(
        '/conversations/search',
        params: {
          'q': query,
          'page': page.toString(),
          'limit': limit.toString(),
        },
      );

      if (response != null && response['conversations'] != null) {
        return (response['conversations'] as List)
            .map((json) => Conversation.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error searching conversations: $e');
      return [];
    }
  }

  /// Récupère les statistiques des conversations
  static Future<ConversationStats?> getConversationStats() async {
    try {
      final response = await ApiService.get('/conversations/stats');

      if (response != null) {
        return ConversationStats.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Error getting conversation stats: $e');
      return null;
    }
  }

  /// Récupère le nombre total de messages non lus
  static Future<int> getTotalUnreadCount() async {
    try {
      final response = await ApiService.get('/conversations/unread-count');

      if (response != null && response['count'] != null) {
        return response['count'] as int;
      }
      return 0;
    } catch (e) {
      print('Error getting unread count: $e');
      return 0;
    }
  }

  /// Récupère les conversations récentes (pour notifications)
  static Future<List<Conversation>> getRecentConversations({int limit = 10}) async {
    try {
      final response = await ApiService.get(
        '/conversations/recent',
        params: {'limit': limit.toString()},
      );

      if (response != null && response['conversations'] != null) {
        return (response['conversations'] as List)
            .map((json) => Conversation.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error getting recent conversations: $e');
      return [];
    }
  }

  /// Bloque un utilisateur
  static Future<bool> blockUser(String userId) async {
    try {
      final response = await ApiService.post(
        '/users/$userId/block',
        data: {},
      );
      return response != null;
    } catch (e) {
      print('Error blocking user: $e');
      return false;
    }
  }

  /// Débloque un utilisateur
  static Future<bool> unblockUser(String userId) async {
    try {
      final response = await ApiService.delete('/users/$userId/block');
      return response != null;
    } catch (e) {
      print('Error unblocking user: $e');
      return false;
    }
  }
}

/// Exception spécifique aux conversations
class ConversationException implements Exception {
  final String message;
  ConversationException(this.message);
  
  @override
  String toString() => 'ConversationException: $message';
}

/// Modèles pour les réponses API

class ConversationsResponse {
  final List<Conversation> conversations;
  final bool hasMore;
  final int totalCount;
  final int unreadTotal;

  ConversationsResponse({
    required this.conversations,
    required this.hasMore,
    required this.totalCount,
    required this.unreadTotal,
  });

  factory ConversationsResponse.fromJson(Map<String, dynamic> json) {
    return ConversationsResponse(
      conversations: (json['conversations'] as List? ?? [])
          .map((c) => Conversation.fromJson(c))
          .toList(),
      hasMore: json['has_more'] ?? false,
      totalCount: json['total_count'] ?? 0,
      unreadTotal: json['unread_total'] ?? 0,
    );
  }
}

class ConversationStats {
  final int totalConversations;
  final int unreadConversations;
  final int archivedConversations;
  final int blockedUsers;

  ConversationStats({
    required this.totalConversations,
    required this.unreadConversations,
    required this.archivedConversations,
    required this.blockedUsers,
  });

  factory ConversationStats.fromJson(Map<String, dynamic> json) {
    return ConversationStats(
      totalConversations: json['total_conversations'] ?? 0,
      unreadConversations: json['unread_conversations'] ?? 0,
      archivedConversations: json['archived_conversations'] ?? 0,
      blockedUsers: json['blocked_users'] ?? 0,
    );
  }
}
