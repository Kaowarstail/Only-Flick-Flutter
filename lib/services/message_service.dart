/// Message service for OnlyFlick messaging system
/// Handles all message operations including paid messages

import 'dart:io';
import 'dart:async';
import '../models/message_models.dart';
import 'api_service.dart';

class MessageService {
  static final MessageService _instance = MessageService._internal();
  factory MessageService() => _instance;
  MessageService._internal();

  /// Get messages for a conversation with pagination
  Future<ApiResponse<List<Message>>> getMessages(
    String conversationId, {
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final response = await ApiService.get(
        '/conversations/$conversationId/messages?page=$page&limit=$limit',
      );

      if (response['success'] == true) {
        final List<dynamic> messagesData = response['data'] ?? [];
        final messages = messagesData.map((m) => Message.fromJson(m)).toList();
        
        return ApiResponse(
          success: true,
          data: messages,
          message: response['message'],
        );
      } else {
        return ApiResponse(
          success: false,
          message: response['message'] ?? 'Failed to load messages',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error loading messages: ${e.toString()}',
      );
    }
  }

  /// Send a regular message
  Future<ApiResponse<Message>> sendMessage(SendMessageRequest request) async {
    try {
      final response = await ApiService.post(
        '/messages',
        body: request.toJson(),
        requiresAuth: true,
      );

      if (response['success'] == true) {
        final message = Message.fromJson(response['data']);
        return ApiResponse(
          success: true,
          data: message,
          message: response['message'],
        );
      } else {
        return ApiResponse(
          success: false,
          message: response['message'] ?? 'Failed to send message',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error sending message: ${e.toString()}',
      );
    }
  }

  /// Send a paid message
  Future<ApiResponse<Message>> sendPaidMessage(PaidMessageRequest request) async {
    try {
      final response = await ApiService.post(
        '/messages/paid',
        body: request.toJson(),
        requiresAuth: true,
      );

      if (response['success'] == true) {
        final message = Message.fromJson(response['data']);
        return ApiResponse(
          success: true,
          data: message,
          message: response['message'],
        );
      } else {
        return ApiResponse(
          success: false,
          message: response['message'] ?? 'Failed to send paid message',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error sending paid message: ${e.toString()}',
      );
    }
  }

  /// Unlock a paid message
  Future<ApiResponse<void>> unlockPaidMessage(String messageId) async {
    try {
      final response = await ApiService.post(
        '/messages/$messageId/unlock',
        body: {},
        requiresAuth: true,
      );

      return ApiResponse(
        success: response['success'] ?? false,
        message: response['message'] ?? 'Failed to unlock message',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error unlocking message: ${e.toString()}',
      );
    }
  }

  /// Get preview of a paid message
  Future<ApiResponse<String>> getMessagePreview(String messageId) async {
    try {
      final response = await ApiService.get('/messages/$messageId/preview');

      if (response['success'] == true) {
        return ApiResponse(
          success: true,
          data: response['data'] ?? '',
          message: response['message'],
        );
      } else {
        return ApiResponse(
          success: false,
          message: response['message'] ?? 'Failed to get preview',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error getting preview: ${e.toString()}',
      );
    }
  }

  /// Upload media for chat (images/videos)
  Future<ApiResponse<String>> uploadChatMedia(File file, MediaType type) async {
    try {
      // Create multipart request
      final request = await ApiService.createMultipartRequest(
        'POST',
        '/upload/chat-media',
      );

      // Add file
      request.files.add(await ApiService.createMultipartFile(
        'file', 
        file.path,
      ));

      // Add media type
      request.fields['type'] = type.name;

      final response = await ApiService.sendMultipartRequest(request);

      if (response['success'] == true) {
        return ApiResponse(
          success: true,
          data: response['data']['url'],
          message: response['message'],
        );
      } else {
        return ApiResponse(
          success: false,
          message: response['message'] ?? 'Failed to upload media',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error uploading media: ${e.toString()}',
      );
    }
  }

  /// Mark messages as read
  Future<ApiResponse<void>> markAsRead(String conversationId) async {
    try {
      final response = await ApiService.put(
        '/conversations/$conversationId/read',
        body: {},
        requiresAuth: true,
      );

      return ApiResponse(
        success: response['success'] ?? false,
        message: response['message'] ?? 'Failed to mark as read',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error marking as read: ${e.toString()}',
      );
    }
  }

  /// Delete a message
  Future<ApiResponse<void>> deleteMessage(String messageId) async {
    try {
      final response = await ApiService.delete('/messages/$messageId');

      return ApiResponse(
        success: response['success'] ?? false,
        message: response['message'] ?? 'Failed to delete message',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error deleting message: ${e.toString()}',
      );
    }
  }

  /// Edit a message
  Future<ApiResponse<Message>> editMessage(String messageId, String newContent) async {
    try {
      final response = await ApiService.put(
        '/messages/$messageId',
        body: {'content': newContent},
        requiresAuth: true,
      );

      if (response['success'] == true) {
        final message = Message.fromJson(response['data']);
        return ApiResponse(
          success: true,
          data: message,
          message: response['message'],
        );
      } else {
        return ApiResponse(
          success: false,
          message: response['message'] ?? 'Failed to edit message',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error editing message: ${e.toString()}',
      );
    }
  }

  /// Get unread messages count
  Future<ApiResponse<int>> getUnreadCount() async {
    try {
      final response = await ApiService.get('/messages/unread');

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

  /// Get media URL with authentication
  Future<String> getMediaUrl(String mediaId) async {
    try {
      final response = await ApiService.get('/media/$mediaId');
      return response['data']['url'] ?? '';
    } catch (e) {
      return '';
    }
  }

  /// Validate media file before upload
  bool validateMediaFile(File file, MediaType type) {
    const List<String> supportedImageFormats = ['jpg', 'jpeg', 'png', 'webp'];
    const List<String> supportedVideoFormats = ['mp4', 'mov', 'avi'];
    const int maxImageSize = 10 * 1024 * 1024; // 10MB
    const int maxVideoSize = 50 * 1024 * 1024; // 50MB

    final extension = file.path.split('.').last.toLowerCase();
    final fileSize = file.lengthSync();

    if (type == MediaType.image) {
      if (!supportedImageFormats.contains(extension)) {
        return false;
      }
      if (fileSize > maxImageSize) {
        return false;
      }
    } else if (type == MediaType.video) {
      if (!supportedVideoFormats.contains(extension)) {
        return false;
      }
      if (fileSize > maxVideoSize) {
        return false;
      }
    }

    return true;
  }
}
