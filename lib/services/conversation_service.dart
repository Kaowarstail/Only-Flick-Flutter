/// Conversation service for OnlyFlick messaging system
/// Handles conversation management and real-time updates

import 'dart:async';
import '../models/message_models.dart';
import '../models/user.dart';
import 'api_service.dart';

class ConversationService {
  static final ConversationService _instance = ConversationService._internal();
  factory ConversationService() => _instance;
  ConversationService._internal();

  /// Get all conversations for current user
  Future<ApiResponse<List<Conversation>>> getConversations({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await ApiService.get(
        '/conversations?page=$page&limit=$limit',
      );

      if (response['success'] == true) {
        final List<dynamic> conversationsData = response['data'] ?? [];
        final conversations = conversationsData
            .map((c) => Conversation.fromJson(c))
            .toList();
        
        return ApiResponse(
          success: true,
          data: conversations,
          message: response['message'],
        );
      } else {
        return ApiResponse(
          success: false,
          message: response['message'] ?? 'Failed to load conversations',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error loading conversations: ${e.toString()}',
      );
    }
  }

  /// Get a specific conversation by ID
  Future<ApiResponse<Conversation>> getConversation(String conversationId) async {
    try {
      final response = await ApiService.get('/conversations/$conversationId');

      if (response['success'] == true) {
        final conversation = Conversation.fromJson(response['data']);
        return ApiResponse(
          success: true,
          data: conversation,
          message: response['message'],
        );
      } else {
        return ApiResponse(
          success: false,
          message: response['message'] ?? 'Failed to load conversation',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error loading conversation: ${e.toString()}',
      );
    }
  }

  /// Create a new conversation with another user
  Future<ApiResponse<Conversation>> createConversation(String otherUserId) async {
    try {
      final response = await ApiService.post(
        '/conversations',
        body: {'participant_id': otherUserId},
        requiresAuth: true,
      );

      if (response['success'] == true) {
        final conversation = Conversation.fromJson(response['data']);
        return ApiResponse(
          success: true,
          data: conversation,
          message: response['message'],
        );
      } else {
        return ApiResponse(
          success: false,
          message: response['message'] ?? 'Failed to create conversation',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error creating conversation: ${e.toString()}',
      );
    }
  }

  /// Get total unread messages count across all conversations
  Future<ApiResponse<int>> getUnreadCount() async {
    try {
      final response = await ApiService.get('/conversations/unread-count');

      if (response['success'] == true) {
        return ApiResponse(
          success: true,
          data: response['data']['count'] ?? 0,
          message: response['message'],
        );
      } else {
        return ApiResponse(
          success: false,
          data: 0,
          message: response['message'] ?? 'Failed to get unread count',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        data: 0,
        message: 'Error getting unread count: ${e.toString()}',
      );
    }
  }

  /// Mark a conversation as read
  Future<ApiResponse<void>> markConversationAsRead(String conversationId) async {
    try {
      final response = await ApiService.put(
        '/conversations/$conversationId/read',
        body: {},
        requiresAuth: true,
      );

      return ApiResponse(
        success: response['success'] ?? false,
        message: response['message'] ?? 'Failed to mark conversation as read',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error marking conversation as read: ${e.toString()}',
      );
    }
  }

  /// Delete a conversation
  Future<ApiResponse<void>> deleteConversation(String conversationId) async {
    try {
      final response = await ApiService.delete('/conversations/$conversationId');

      return ApiResponse(
        success: response['success'] ?? false,
        message: response['message'] ?? 'Failed to delete conversation',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error deleting conversation: ${e.toString()}',
      );
    }
  }

  /// Archive a conversation
  Future<ApiResponse<void>> archiveConversation(String conversationId) async {
    try {
      final response = await ApiService.put(
        '/conversations/$conversationId/archive',
        body: {},
        requiresAuth: true,
      );

      return ApiResponse(
        success: response['success'] ?? false,
        message: response['message'] ?? 'Failed to archive conversation',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error archiving conversation: ${e.toString()}',
      );
    }
  }

  /// Unarchive a conversation
  Future<ApiResponse<void>> unarchiveConversation(String conversationId) async {
    try {
      final response = await ApiService.put(
        '/conversations/$conversationId/unarchive',
        body: {},
        requiresAuth: true,
      );

      return ApiResponse(
        success: response['success'] ?? false,
        message: response['message'] ?? 'Failed to unarchive conversation',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error unarchiving conversation: ${e.toString()}',
      );
    }
  }

  /// Search for users to start a conversation
  Future<ApiResponse<List<User>>> searchUsers(String query) async {
    try {
      final response = await ApiService.get(
        '/users/search?q=${Uri.encodeComponent(query)}',
      );

      if (response['success'] == true) {
        final List<dynamic> usersData = response['data'] ?? [];
        final users = usersData.map((u) => User.fromJson(u)).toList();
        
        return ApiResponse(
          success: true,
          data: users,
          message: response['message'],
        );
      } else {
        return ApiResponse(
          success: false,
          message: response['message'] ?? 'Failed to search users',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error searching users: ${e.toString()}',
      );
    }
  }

  /// Check if a conversation exists between two users
  Future<ApiResponse<Conversation?>> findConversationWithUser(String userId) async {
    try {
      final response = await ApiService.get('/conversations/find/$userId');

      if (response['success'] == true) {
        final conversationData = response['data'];
        if (conversationData != null) {
          final conversation = Conversation.fromJson(conversationData);
          return ApiResponse(
            success: true,
            data: conversation,
            message: response['message'],
          );
        } else {
          return ApiResponse(
            success: true,
            data: null,
            message: 'No conversation found',
          );
        }
      } else {
        return ApiResponse(
          success: false,
          message: response['message'] ?? 'Failed to find conversation',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error finding conversation: ${e.toString()}',
      );
    }
  }
}
