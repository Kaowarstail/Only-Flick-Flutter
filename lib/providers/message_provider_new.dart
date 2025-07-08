/// Message provider for OnlyFlick messaging system
/// Manages message state using Provider pattern with WebSocket real-time updates

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/message_models.dart';
import '../models/user.dart';
import '../models/websocket_models.dart';
import '../services/message_service.dart';
import '../services/conversation_service.dart';
import '../services/notification_service.dart';
import '../services/websocket_service.dart';
import '../services/connectivity_service.dart';
import '../services/local_notification_service.dart';

class MessageProvider extends ChangeNotifier {
  // Services
  final MessageService _messageService;
  final ConversationService _conversationService;
  final NotificationService _notificationService;
  final WebSocketService _webSocketService;
  final ConnectivityService _connectivityService;
  final LocalNotificationService _localNotificationService;
  
  // State
  List<Conversation> _conversations = [];
  Map<String, List<Message>> _messagesByConversation = {};
  int _unreadCount = 0;
  bool _isLoading = false;
  bool _isSendingMessage = false;
  String? _error;
  String? _currentConversationId;
  bool _isWebSocketEnabled = true;
  
  // Pagination
  Map<String, bool> _hasMoreMessages = {};
  Map<String, bool> _isLoadingMoreMessages = {};
  Map<String, int> _messagePages = {};
  
  // Real-time features
  Map<String, List<String>> _typingUsers = {};
  Map<String, String> _userPresence = {};
  Timer? _typingTimer;
  
  // Subscriptions
  StreamSubscription? _webSocketSubscription;
  StreamSubscription? _connectivitySubscription;
  
  // Constructor
  MessageProvider({
    required MessageService messageService,
    required ConversationService conversationService,
    required NotificationService notificationService,
    required WebSocketService webSocketService,
    required ConnectivityService connectivityService,
    required LocalNotificationService localNotificationService,
  }) : _messageService = messageService,
       _conversationService = conversationService,
       _notificationService = notificationService,
       _webSocketService = webSocketService,
       _connectivityService = connectivityService,
       _localNotificationService = localNotificationService {
    _initialize();
  }

  // Getters
  List<Conversation> get conversations => _conversations;
  List<Message> getMessages(String conversationId) => 
      _messagesByConversation[conversationId] ?? [];
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  bool get isSendingMessage => _isSendingMessage;
  String? get error => _error;
  String? get currentConversationId => _currentConversationId;
  bool get isWebSocketEnabled => _isWebSocketEnabled;
  
  // WebSocket/connectivity getters
  bool get isWebSocketConnected => _webSocketService.isConnected;
  bool get isOnline => _connectivityService.isConnected;
  String get connectionStatus => _connectivityService.getStatusDescription();
  
  bool hasMoreMessages(String conversationId) => 
      _hasMoreMessages[conversationId] ?? true;
  bool isLoadingMoreMessages(String conversationId) => 
      _isLoadingMoreMessages[conversationId] ?? false;
  
  // Real-time getters
  List<String> getTypingUsers(String conversationId) => 
      _typingUsers[conversationId] ?? [];
  String getUserPresence(String userId) => 
      _userPresence[userId] ?? 'offline';

  // Initialization
  void _initialize() {
    print('MessageProvider: Initializing...');
    _setupCallbacks();
    _loadConversations();
    _updateUnreadCount();
  }

  void _setupCallbacks() {
    // Setup notification callbacks
    _notificationService.onConversationsUpdated = _onConversationsUpdated;
    _notificationService.onMessagesUpdated = _onMessagesUpdated;
    _notificationService.onUnreadCountUpdated = _onUnreadCountUpdated;
    
    // Setup WebSocket callbacks
    _webSocketSubscription?.cancel();
    _webSocketSubscription = _webSocketService.eventStream.listen((event) {
      _handleWebSocketEvent(event);
    });
    
    // Setup connectivity callbacks
    _connectivitySubscription?.cancel();
    _connectivitySubscription = _connectivityService.connectionStream.listen((isConnected) {
      print('MessageProvider: Connectivity changed: $isConnected');
      if (isConnected && _isWebSocketEnabled) {
        _webSocketService.connect();
      }
    });
  }

  /// Load conversations from API
  Future<void> _loadConversations() async {
    try {
      final response = await _conversationService.getConversations();
      if (response.success && response.data != null) {
        _conversations = response.data!;
        notifyListeners();
      }
    } catch (e) {
      print('MessageProvider: Error loading conversations: $e');
    }
  }

  /// Handle WebSocket events
  void _handleWebSocketEvent(WebSocketEvent event) {
    print('MessageProvider: Received WebSocket event: ${event.type}');
    
    switch (event.type) {
      case WebSocketEventType.messageReceived:
        if (event is MessageReceivedEvent) {
          _handleMessageReceived(event);
        }
        break;
      case WebSocketEventType.messageRead:
        if (event is MessageReadEvent) {
          _handleMessageRead(event);
        }
        break;
      case WebSocketEventType.typingStarted:
        if (event is TypingStartedEvent) {
          _handleTypingStarted(event);
        }
        break;
      case WebSocketEventType.typingStopped:
        if (event is TypingStoppedEvent) {
          _handleTypingStopped(event);
        }
        break;
      case WebSocketEventType.userPresenceChanged:
        if (event is UserPresenceChangedEvent) {
          _handleUserPresenceChanged(event);
        }
        break;
      case WebSocketEventType.conversationUpdated:
        if (event is ConversationUpdatedEvent) {
          _handleConversationUpdated(event);
        }
        break;
      case WebSocketEventType.error:
        if (event is ErrorEvent) {
          _handleWebSocketError(event);
        }
        break;
      default:
        print('MessageProvider: Unknown WebSocket event type: ${event.type}');
    }
  }

  /// Handle message received event
  void _handleMessageReceived(MessageReceivedEvent event) {
    print('MessageProvider: Message received for conversation ${event.conversationId}');
    
    final message = Message(
      id: event.messageId,
      conversationId: event.conversationId,
      senderId: event.senderId,
      content: event.content,
      type: _parseMessageType(event.type),
      timestamp: event.timestamp,
      isRead: false,
      sender: event.senderName != null ? User(id: event.senderId, username: event.senderName!) : null,
    );
    
    _addMessageToConversation(event.conversationId, message);
    
    // Show notification if not current conversation
    if (_currentConversationId != event.conversationId) {
      _localNotificationService.showMessageNotification(
        message,
        event.senderName ?? 'Unknown',
      );
    }
    
    notifyListeners();
  }

  /// Handle message read event
  void _handleMessageRead(MessageReadEvent event) {
    print('MessageProvider: Message read for conversation ${event.conversationId}');
    
    final messages = _messagesByConversation[event.conversationId] ?? [];
    for (var message in messages) {
      if (message.id == event.messageId) {
        // Update message read status
        _messagesByConversation[event.conversationId] = messages.map((m) => 
          m.id == event.messageId ? m.copyWith(isRead: true) : m
        ).toList();
        break;
      }
    }
    
    notifyListeners();
  }

  /// Handle typing started event
  void _handleTypingStarted(TypingStartedEvent event) {
    print('MessageProvider: Typing started in conversation ${event.conversationId}');
    
    final typingUsers = _typingUsers[event.conversationId] ?? [];
    if (!typingUsers.contains(event.userId)) {
      typingUsers.add(event.userId);
      _typingUsers[event.conversationId] = typingUsers;
      notifyListeners();
    }
    
    _clearTypingAfterTimeout(event.conversationId, event.userId);
  }

  /// Handle typing stopped event
  void _handleTypingStopped(TypingStoppedEvent event) {
    print('MessageProvider: Typing stopped in conversation ${event.conversationId}');
    
    final typingUsers = _typingUsers[event.conversationId] ?? [];
    typingUsers.remove(event.userId);
    _typingUsers[event.conversationId] = typingUsers;
    notifyListeners();
  }

  /// Handle user presence changed event
  void _handleUserPresenceChanged(UserPresenceChangedEvent event) {
    print('MessageProvider: User presence changed: ${event.userId} -> ${event.status}');
    
    final messagesList = _messagesByConversation[event.conversationId] ?? [];
    _userPresence[event.userId] = event.status;
    
    // Show notification for presence changes
    _localNotificationService.showPresenceNotification(
      event.userId,
      event.status,
      messagesList.isNotEmpty,
    );
    
    notifyListeners();
  }

  /// Handle conversation updated event
  void _handleConversationUpdated(ConversationUpdatedEvent event) {
    print('MessageProvider: Conversation updated: ${event.conversationId}');
    
    // Reload conversations to get latest data
    _loadConversations();
  }

  /// Handle WebSocket error
  void _handleWebSocketError(ErrorEvent event) {
    print('MessageProvider: WebSocket error: ${event.message}');
    _setError(event.message);
    
    // Try to reconnect if enabled
    if (_isWebSocketEnabled && _connectivityService.isConnected) {
      _webSocketService.reconnect();
    }
  }

  /// Clear error
  void _clearError() {
    _error = null;
  }

  /// Close connection and clean up
  void closeConnection() {
    print('MessageProvider: Closing connection...');
    
    if (_currentConversationId != null) {
      _webSocketService.leaveConversation(_currentConversationId!);
      _currentConversationId = null;
    }
    
    _notificationService.stopPolling();
    _typingUsers.clear();
    notifyListeners();
  }

  /// Toggle WebSocket
  void toggleWebSocket() {
    _isWebSocketEnabled = !_isWebSocketEnabled;
    
    if (_isWebSocketEnabled && _connectivityService.isConnected) {
      _webSocketService.connect();
    } else {
      _webSocketService.disconnect();
    }
    
    notifyListeners();
  }

  /// Send typing indicator
  void sendTypingIndicator(String conversationId, bool isTyping) {
    if (_isWebSocketEnabled && _webSocketService.isConnected) {
      _webSocketService.sendTyping(conversationId, isTyping);
    }
  }

  /// Mark conversation as read
  void markConversationAsRead(String conversationId) {
    if (_isWebSocketEnabled && _webSocketService.isConnected) {
      _webSocketService.markConversationAsRead(conversationId);
    } else {
      // Fallback to REST API
      _notificationService.markConversationAsRead(conversationId);
    }
  }

  /// Set user presence
  void setUserPresence(String conversationId, String status) {
    if (_isWebSocketEnabled && _webSocketService.isConnected) {
      _webSocketService.setUserPresence(conversationId, status);
    }
  }

  // Public API methods for UI

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
        if (_isWebSocketEnabled && _webSocketService.isConnected) {
          _webSocketService.joinConversation(conversationId);
        } else {
          _notificationService.startPolling(conversationId);
        }
        
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
    String content, {
    MessageType type = MessageType.text,
    String? mediaUrl,
    String? thumbnailUrl,
  }) async {
    if (content.trim().isEmpty && mediaUrl == null) return;
    
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
    if (content.trim().isEmpty && mediaUrl == null) return;
    
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

  /// Search users
  Future<List<User>> searchUsers(String query) async {
    try {
      final response = await _conversationService.searchUsers(query);
      return response.data ?? [];
    } catch (e) {
      _setError('Failed to search users: $e');
      return [];
    }
  }

  /// Create conversation
  Future<String?> createConversation(String otherUserId) async {
    try {
      final response = await _conversationService.createConversation(otherUserId);
      if (response.success && response.data != null) {
        _conversations.add(response.data!);
        notifyListeners();
        return response.data!.id;
      } else {
        _setError(response.message ?? 'Failed to create conversation');
        return null;
      }
    } catch (e) {
      _setError('Error creating conversation: ${e.toString()}');
      return null;
    }
  }

  /// Delete conversation
  Future<void> deleteConversation(String conversationId) async {
    try {
      final response = await _conversationService.deleteConversation(conversationId);
      if (response.success) {
        _conversations.removeWhere((c) => c.id == conversationId);
        _messagesByConversation.remove(conversationId);
        _hasMoreMessages.remove(conversationId);
        _isLoadingMoreMessages.remove(conversationId);
        _messagePages.remove(conversationId);
        
        // Leave WebSocket room
        if (_isWebSocketEnabled && _webSocketService.isConnected) {
          _webSocketService.leaveConversation(conversationId);
        }
        
        notifyListeners();
      } else {
        _setError(response.message ?? 'Failed to delete conversation');
      }
    } catch (e) {
      _setError('Error deleting conversation: ${e.toString()}');
    }
  }

  /// Force reconnect WebSocket
  void forceReconnect() {
    print('MessageProvider: Force reconnecting WebSocket...');
    if (_isWebSocketEnabled) {
      _webSocketService.reconnect();
    }
  }

  /// Enable/disable WebSocket
  void setWebSocketEnabled(bool enabled) {
    print('MessageProvider: Setting WebSocket enabled: $enabled');
    _isWebSocketEnabled = enabled;
    
    if (enabled && _connectivityService.isConnected) {
      _webSocketService.connect();
    } else if (!enabled) {
      _webSocketService.disconnect();
    }
    
    notifyListeners();
  }

  // Helper methods

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setSendingMessage(bool sending) {
    _isSendingMessage = sending;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void _addMessageToConversation(String conversationId, Message message) {
    final messages = _messagesByConversation[conversationId] ?? [];
    messages.insert(0, message);
    _messagesByConversation[conversationId] = messages;
  }

  void _updateMessageInState(String messageId, Message Function(Message) updater) {
    for (final conversationId in _messagesByConversation.keys) {
      final messages = _messagesByConversation[conversationId] ?? [];
      for (int i = 0; i < messages.length; i++) {
        if (messages[i].id == messageId) {
          messages[i] = updater(messages[i]);
          return;
        }
      }
    }
  }

  Future<void> _updateConversationAfterMessage(String conversationId, Message message) async {
    // Update the conversation's last message
    final conversationIndex = _conversations.indexWhere((c) => c.id == conversationId);
    if (conversationIndex != -1) {
      final conversation = _conversations[conversationIndex];
      _conversations[conversationIndex] = conversation.copyWith(
        lastMessage: message,
        lastMessageAt: message.timestamp,
      );
      
      // Move to top
      _conversations.removeAt(conversationIndex);
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
  
  /// Parse message type from WebSocket event
  MessageType _parseMessageType(String type) {
    switch (type.toLowerCase()) {
      case 'text':
        return MessageType.text;
      case 'image':
        return MessageType.image;
      case 'video':
        return MessageType.video;
      case 'paid':
      case 'paid_text':
        return MessageType.paid_text;
      default:
        return MessageType.text;
    }
  }
  
  /// Clear typing indicator after timeout
  void _clearTypingAfterTimeout(String conversationId, String userId) {
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 10), () {
      final typingUsers = _typingUsers[conversationId] ?? [];
      typingUsers.remove(userId);
      _typingUsers[conversationId] = typingUsers;
      notifyListeners();
    });
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
    print('MessageProvider: Disposing...');
    
    // Cancel subscriptions
    _webSocketSubscription?.cancel();
    _connectivitySubscription?.cancel();
    _typingTimer?.cancel();
    
    // Dispose services
    _webSocketService.dispose();
    _connectivityService.dispose();
    _notificationService.stopPolling();
    _notificationService.stopBackgroundPolling();
    
    super.dispose();
  }
}
