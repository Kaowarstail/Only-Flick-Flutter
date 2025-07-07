/// Message provider for OnlyFlick messaging system
/// Manages message state using Provider pattern

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/message_models.dart';
import '../models/user.dart';
import '../services/message_service.dart';
import '../services/conversation_service.dart';
import '../services/notification_service.dart';

class MessageProvider extends ChangeNotifier {
  // Services
  final MessageService _messageService = MessageService();
  final ConversationService _conversationService = ConversationService();
  final NotificationService _notificationService = NotificationService();
  
  // State
  List<Conversation> _conversations = [];
  Map<String, List<Message>> _messagesByConversation = {};
  int _unreadCount = 0;
  bool _isLoading = false;
  bool _isSendingMessage = false;
  String? _error;
  String? _currentConversationId;
  
  // Pagination
  Map<String, bool> _hasMoreMessages = {};
  Map<String, bool> _isLoadingMoreMessages = {};
  Map<String, int> _messagePages = {};

  // Getters
  List<Conversation> get conversations => _conversations;
  List<Message> getMessages(String conversationId) => 
      _messagesByConversation[conversationId] ?? [];
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  bool get isSendingMessage => _isSendingMessage;
  String? get error => _error;
  String? get currentConversationId => _currentConversationId;
  
  bool hasMoreMessages(String conversationId) => 
      _hasMoreMessages[conversationId] ?? true;
  bool isLoadingMoreMessages(String conversationId) => 
      _isLoadingMoreMessages[conversationId] ?? false;

  /// Initialize the provider
  Future<void> initialize() async {
    await _notificationService.initializePushNotifications();
    _setupCallbacks();
    _notificationService.startBackgroundPolling();
    await loadConversations();
  }

  /// Setup notification callbacks
  void _setupCallbacks() {
    _notificationService.setConversationsUpdateCallback(_onConversationsUpdated);
    _notificationService.setMessagesUpdateCallback(_onMessagesUpdated);
    _notificationService.setUnreadCountCallback(_onUnreadCountUpdated);
  }

  /// Load conversations
  Future<void> loadConversations() async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _conversationService.getConversations();
      
      if (response.success && response.data != null) {
        _conversations = response.data!;
        await _updateUnreadCount();
        notifyListeners();
      } else {
        _setError(response.message ?? 'Failed to load conversations');
      }
    } catch (e) {
      _setError('Error loading conversations: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Load messages for a conversation
  Future<void> loadMessages(String conversationId) async {
    _setLoading(true);
    _clearError();
    _currentConversationId = conversationId;

    try {
      final response = await _messageService.getMessages(conversationId);
      
      if (response.success && response.data != null) {
        _messagesByConversation[conversationId] = response.data!;
        _messagePages[conversationId] = 1;
        _hasMoreMessages[conversationId] = response.data!.length >= 50;
        
        // Start real-time updates for this conversation
        _notificationService.startPolling(conversationId);
        
        // Mark as read
        await _conversationService.markConversationAsRead(conversationId);
        
        notifyListeners();
      } else {
        _setError(response.message ?? 'Failed to load messages');
      }
    } catch (e) {
      _setError('Error loading messages: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Load more messages for pagination
  Future<void> loadMoreMessages(String conversationId) async {
    if (isLoadingMoreMessages(conversationId) || !hasMoreMessages(conversationId)) {
      return;
    }

    _isLoadingMoreMessages[conversationId] = true;
    notifyListeners();

    try {
      final currentPage = _messagePages[conversationId] ?? 1;
      final nextPage = currentPage + 1;
      
      final response = await _messageService.getMessages(
        conversationId,
        page: nextPage,
      );
      
      if (response.success && response.data != null) {
        final currentMessages = _messagesByConversation[conversationId] ?? [];
        final newMessages = response.data!;
        
        _messagesByConversation[conversationId] = [...currentMessages, ...newMessages];
        _messagePages[conversationId] = nextPage;
        _hasMoreMessages[conversationId] = newMessages.length >= 50;
        
        notifyListeners();
      }
    } catch (e) {
      _setError('Error loading more messages: ${e.toString()}');
    } finally {
      _isLoadingMoreMessages[conversationId] = false;
    }
  }

  /// Send a regular message
  Future<void> sendMessage(
    String conversationId,
    String content,
    MessageType type, {
    String? mediaUrl,
    String? thumbnailUrl,
  }) async {
    _setSendingMessage(true);
    _clearError();

    try {
      final request = SendMessageRequest(
        conversationId: conversationId,
        content: content,
        type: type,
        mediaUrl: mediaUrl,
        thumbnailUrl: thumbnailUrl,
      );

      final response = await _messageService.sendMessage(request);
      
      if (response.success && response.data != null) {
        // Add message to local state
        _addMessageToConversation(conversationId, response.data!);
        
        // Update conversation list
        await _updateConversationAfterMessage(conversationId, response.data!);
        
        notifyListeners();
      } else {
        _setError(response.message ?? 'Failed to send message');
      }
    } catch (e) {
      _setError('Error sending message: ${e.toString()}');
    } finally {
      _setSendingMessage(false);
    }
  }

  /// Send a paid message
  Future<void> sendPaidMessage(
    String conversationId,
    String content,
    double price, {
    MessageType type = MessageType.paid_text,
    String? mediaUrl,
    String? thumbnailUrl,
    String? previewContent,
  }) async {
    _setSendingMessage(true);
    _clearError();

    try {
      final request = PaidMessageRequest(
        conversationId: conversationId,
        content: content,
        type: type,
        price: price,
        mediaUrl: mediaUrl,
        thumbnailUrl: thumbnailUrl,
        previewContent: previewContent,
      );

      final response = await _messageService.sendPaidMessage(request);
      
      if (response.success && response.data != null) {
        // Add message to local state
        _addMessageToConversation(conversationId, response.data!);
        
        // Update conversation list
        await _updateConversationAfterMessage(conversationId, response.data!);
        
        notifyListeners();
      } else {
        _setError(response.message ?? 'Failed to send paid message');
      }
    } catch (e) {
      _setError('Error sending paid message: ${e.toString()}');
    } finally {
      _setSendingMessage(false);
    }
  }

  /// Unlock a paid message
  Future<void> unlockPaidMessage(String messageId) async {
    _clearError();

    try {
      final response = await _messageService.unlockPaidMessage(messageId);
      
      if (response.success) {
        // Update message in local state
        _updateMessageInState(messageId, (message) {
          return message.copyWith(isUnlocked: true);
        });
        
        notifyListeners();
      } else {
        _setError(response.message ?? 'Failed to unlock message');
      }
    } catch (e) {
      _setError('Error unlocking message: ${e.toString()}');
    }
  }

  /// Upload media and send message
  Future<void> uploadAndSendMedia(
    String conversationId,
    File file,
    MediaType mediaType,
    String content,
  ) async {
    _setSendingMessage(true);
    _clearError();

    try {
      // Validate file
      if (!_messageService.validateMediaFile(file, mediaType)) {
        _setError('Invalid media file');
        return;
      }

      // Upload media
      final uploadResponse = await _messageService.uploadChatMedia(file, mediaType);
      
      if (!uploadResponse.success || uploadResponse.data == null) {
        _setError(uploadResponse.message ?? 'Failed to upload media');
        return;
      }

      // Send message with media
      final messageType = mediaType == MediaType.image 
          ? MessageType.image 
          : MessageType.video;
          
      await sendMessage(
        conversationId,
        content,
        messageType,
        mediaUrl: uploadResponse.data!,
      );
    } catch (e) {
      _setError('Error uploading media: ${e.toString()}');
    } finally {
      _setSendingMessage(false);
    }
  }

  /// Create a new conversation
  Future<String?> createConversation(String otherUserId) async {
    _setLoading(true);
    _clearError();

    try {
      // First check if conversation already exists
      final existingResponse = await _conversationService.findConversationWithUser(otherUserId);
      
      if (existingResponse.success && existingResponse.data != null) {
        return existingResponse.data!.id;
      }

      // Create new conversation
      final response = await _conversationService.createConversation(otherUserId);
      
      if (response.success && response.data != null) {
        // Add to local state
        _conversations.insert(0, response.data!);
        notifyListeners();
        return response.data!.id;
      } else {
        _setError(response.message ?? 'Failed to create conversation');
        return null;
      }
    } catch (e) {
      _setError('Error creating conversation: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete a conversation
  Future<void> deleteConversation(String conversationId) async {
    _clearError();

    try {
      final response = await _conversationService.deleteConversation(conversationId);
      
      if (response.success) {
        // Remove from local state
        _conversations.removeWhere((c) => c.id == conversationId);
        _messagesByConversation.remove(conversationId);
        _hasMoreMessages.remove(conversationId);
        _isLoadingMoreMessages.remove(conversationId);
        _messagePages.remove(conversationId);
        
        notifyListeners();
      } else {
        _setError(response.message ?? 'Failed to delete conversation');
      }
    } catch (e) {
      _setError('Error deleting conversation: ${e.toString()}');
    }
  }

  /// Start real-time updates for a conversation
  void startRealTimeUpdates(String conversationId) {
    _currentConversationId = conversationId;
    _notificationService.startPolling(conversationId);
  }

  /// Stop real-time updates
  void stopRealTimeUpdates() {
    _currentConversationId = null;
    _notificationService.stopPolling();
  }

  /// Search users
  Future<List<User>> searchUsers(String query) async {
    if (query.isEmpty) return [];

    try {
      final response = await _conversationService.searchUsers(query);
      return response.data ?? [];
    } catch (e) {
      return [];
    }
  }

  /// Private methods
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setSendingMessage(bool sending) {
    _isSendingMessage = sending;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void _addMessageToConversation(String conversationId, Message message) {
    final messages = _messagesByConversation[conversationId] ?? [];
    _messagesByConversation[conversationId] = [message, ...messages];
  }

  void _updateMessageInState(String messageId, Message Function(Message) updater) {
    for (final conversationId in _messagesByConversation.keys) {
      final messages = _messagesByConversation[conversationId]!;
      final index = messages.indexWhere((m) => m.id == messageId);
      
      if (index != -1) {
        messages[index] = updater(messages[index]);
        break;
      }
    }
  }

  Future<void> _updateConversationAfterMessage(String conversationId, Message message) async {
    final index = _conversations.indexWhere((c) => c.id == conversationId);
    if (index != -1) {
      // Move conversation to top and update last message
      final conversation = _conversations[index];
      _conversations.removeAt(index);
      _conversations.insert(0, conversation);
    }
  }

  Future<void> _updateUnreadCount() async {
    try {
      final response = await _conversationService.getUnreadCount();
      if (response.success && response.data != null) {
        _unreadCount = response.data!;
      }
    } catch (e) {
      // Ignore error for unread count
    }
  }

  /// Callback handlers
  
  void _onConversationsUpdated(List<Conversation> conversations) {
    _conversations = conversations;
    notifyListeners();
  }

  void _onMessagesUpdated(String conversationId, List<Message> messages) {
    _messagesByConversation[conversationId] = messages;
    notifyListeners();
  }

  void _onUnreadCountUpdated(int count) {
    _unreadCount = count;
    notifyListeners();
  }

  @override
  void dispose() {
    _notificationService.stopPolling();
    _notificationService.stopBackgroundPolling();
    super.dispose();
  }
}
