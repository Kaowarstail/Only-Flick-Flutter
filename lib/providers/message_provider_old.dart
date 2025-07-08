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
    print('[MessageProvider] Initializing with services');
    _setupCallbacks();
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
  bool get isOnline => _connectivityService.isOnline;
  String get connectionStatus => _connectivityService.getStatusDescription();
  
  bool hasMoreMessages(String conversationId) => 
      _hasMoreMessages[conversationId] ?? true;
  bool isLoadingMoreMessages(String conversationId) => 
      _isLoadingMoreMessages[conversationId] ?? false;
  
  // Real-time getters
  List<String> getTypingUsers(String conversationId) => 
      _typingUsers[conversationId] ?? [];
  bool isUserOnline(String conversationId, String userId) => 
      _userPresence[conversationId]?[userId] ?? false;
  Map<String, bool> getUserPresence(String conversationId) => 
      _userPresence[conversationId] ?? {};

  /// Initialize the provider
  Future<void> initialize() async {
    print('MessageProvider: Initializing...');
    
    // Initialize services
    await _connectivityService.initialize();
    await _localNotificationService.initialize();
    await _notificationService.initializePushNotifications();
    
    // Setup callbacks and listeners
    _setupCallbacks();
    _setupWebSocketListener();
    _setupConnectivityListener();
    
    // Start background polling as fallback
    _notificationService.startBackgroundPolling();
    
    // Load initial data
    await loadConversations();
    
    print('MessageProvider: Initialized successfully');
  }
  
  /// Initialize WebSocket connection
  Future<void> initializeWebSocket(String authToken) async {
    if (!_isWebSocketEnabled) return;
    
    print('MessageProvider: Initializing WebSocket...');
    
    try {
      await _webSocketService.connect(authToken);
      print('MessageProvider: WebSocket initialized successfully');
    } catch (e) {
      print('MessageProvider: WebSocket initialization failed: $e');
      _setError('Real-time connection failed. Using fallback mode.');
    }
  }
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
  
  /// Setup WebSocket event listener
  void _setupWebSocketListener() {
    _webSocketSubscription?.cancel();
    _webSocketSubscription = _webSocketService.events.listen(
      _handleWebSocketEvent,
      onError: (error) {
        print('MessageProvider: WebSocket event error: $error');
        _setError('Real-time connection error: $error');
      },
    );
  }
  
  /// Setup connectivity listener
  void _setupConnectivityListener() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = _connectivityService.statusStream.listen(
      _handleConnectivityChange,
      onError: (error) {
        print('MessageProvider: Connectivity error: $error');
      },
    );
  }
  
  /// Handle WebSocket events
  void _handleWebSocketEvent(WebSocketEvent event) {
    print('MessageProvider: Received WebSocket event: ${event.type}');
    
    try {
      switch (event.type) {
        case WebSocketEventType.messageSent:
          _handleMessageSentEvent(MessageSentEvent.fromJson(event.data));
          break;
        case WebSocketEventType.messageRead:
          _handleMessageReadEvent(MessageReadEvent.fromJson(event.data));
          break;
        case WebSocketEventType.userTyping:
          _handleTypingEvent(TypingEvent.fromJson(event.data));
          break;
        case WebSocketEventType.userStoppedTyping:
          _handleStoppedTypingEvent(TypingEvent.fromJson(event.data));
          break;
        case WebSocketEventType.userStatusChanged:
          _handleUserStatusEvent(UserStatusEvent.fromJson(event.data));
          break;
        case WebSocketEventType.conversationUpdated:
          _handleConversationUpdatedEvent(ConversationUpdatedEvent.fromJson(event.data));
          break;
        case WebSocketEventType.paidMessageUnlocked:
          _handlePaidMessageUnlockedEvent(PaidMessageUnlockedEvent.fromJson(event.data));
          break;
        case WebSocketEventType.connectionEstablished:
          _handleConnectionEstablishedEvent(ConnectionEstablishedEvent.fromJson(event.data));
          break;
        case WebSocketEventType.error:
          _handleErrorEvent(ErrorEvent.fromJson(event.data));
          break;
        default:
          print('MessageProvider: Unhandled WebSocket event type: ${event.type}');
      }
    } catch (e) {
      print('MessageProvider: Error handling WebSocket event: $e');
      _setError('Error processing real-time update: $e');
    }
  }
  
  /// Handle connectivity changes
  void _handleConnectivityChange(NetworkStatus status) {
    print('MessageProvider: Connectivity changed to $status');
    
    switch (status) {
      case NetworkStatus.online:
        // Reconnect WebSocket if needed
        if (_isWebSocketEnabled && !_webSocketService.isConnected) {
          // WebSocket will auto-reconnect
        }
        break;
      case NetworkStatus.offline:
        // Will use REST API fallback
        break;
      case NetworkStatus.weak:
        // Prefer REST API for reliability
        break;
      case NetworkStatus.connecting:
        // Show loading state
        break;
    }
    
    notifyListeners();
  }
  
  /// Handle message sent event
  void _handleMessageSentEvent(MessageSentEvent event) {
    print('MessageProvider: New message received via WebSocket');
    
    // Convert WebSocket event to Message model
    final message = Message(
      id: event.messageId,
      conversationId: event.conversationId,
      senderId: event.senderId,
      content: event.content,
      type: _parseMessageType(event.messageType),
      createdAt: event.timestamp,
      isRead: false,
      mediaUrl: event.mediaUrl,
      thumbnailUrl: event.thumbnailUrl,
      price: event.price,
      isUnlocked: event.isUnlocked ?? false,
    );
    
    // Add to local state
    _addMessageToConversation(event.conversationId, message);
    
    // Update conversation order
    _updateConversationOrder(event.conversationId);
    
    // Show notification if not in current conversation
    if (_currentConversationId != event.conversationId) {
      _localNotificationService.showMessageNotification(event);
    }
    
    // Update unread count
    _updateUnreadCount();
    
    notifyListeners();
  }
  
  /// Handle message read event
  void _handleMessageReadEvent(MessageReadEvent event) {
    print('MessageProvider: Message read event received');
    
    // Update message read status
    _updateMessageInState(event.messageId, (message) {
      return message.copyWith(isRead: true);
    });
    
    notifyListeners();
  }
  
  /// Handle typing event
  void _handleTypingEvent(TypingEvent event) {
    print('MessageProvider: User typing in conversation ${event.conversationId}');
    
    final typingUsers = _typingUsers[event.conversationId] ?? [];
    if (!typingUsers.contains(event.userId)) {
      typingUsers.add(event.userId);
      _typingUsers[event.conversationId] = typingUsers;
      notifyListeners();
    }
    
    // Clear typing after timeout
    _clearTypingAfterTimeout(event.conversationId, event.userId);
  }
  
  /// Handle stopped typing event
  void _handleStoppedTypingEvent(TypingEvent event) {
    print('MessageProvider: User stopped typing in conversation ${event.conversationId}');
    
    final typingUsers = _typingUsers[event.conversationId] ?? [];
    typingUsers.remove(event.userId);
    _typingUsers[event.conversationId] = typingUsers;
    
    notifyListeners();
  }
  
  /// Handle user status event
  void _handleUserStatusEvent(UserStatusEvent event) {
    print('MessageProvider: User status changed: ${event.userId} - ${event.isOnline}');
    
    // Update user presence for all conversations
    for (final conversationId in _messagesByConversation.keys) {
      final presence = _userPresence[conversationId] ?? {};
      presence[event.userId] = event.isOnline;
      _userPresence[conversationId] = presence;
    }
    
    // Show notification for user coming online
    if (event.isOnline) {
      _localNotificationService.showUserStatusNotification(event);
    }
    
    notifyListeners();
  }
  
  /// Handle conversation updated event
  void _handleConversationUpdatedEvent(ConversationUpdatedEvent event) {
    print('MessageProvider: Conversation updated: ${event.conversationId}');
    
    // Refresh conversations list
    loadConversations();
    
    // Show notification
    _localNotificationService.showConversationUpdatedNotification(event);
  }
  
  /// Handle paid message unlocked event
  void _handlePaidMessageUnlockedEvent(PaidMessageUnlockedEvent event) {
    print('MessageProvider: Paid message unlocked: ${event.messageId}');
    
    // Update message unlock status
    _updateMessageInState(event.messageId, (message) {
      return message.copyWith(isUnlocked: true);
    });
    
    // Show notification
    _localNotificationService.showPaidMessageUnlockedNotification(event);
    
    notifyListeners();
  }
  
  /// Handle connection established event
  void _handleConnectionEstablishedEvent(ConnectionEstablishedEvent event) {
    print('MessageProvider: WebSocket connection established');
    
    // Clear any connection errors
    if (_error?.contains('Real-time connection') == true) {
      _clearError();
    }
    
    // Send user online status
    _webSocketService.sendUserStatus(true);
    
    // Mark active in current conversation
    if (_currentConversationId != null) {
      _webSocketService.markActiveInConversation(_currentConversationId!);
    }
    
    notifyListeners();
  }
  
  /// Handle error event
  void _handleErrorEvent(ErrorEvent event) {
    print('MessageProvider: WebSocket error: ${event.error}');
    _setError('Real-time error: ${event.error}');
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
        if (_isWebSocketEnabled && _webSocketService.isConnected) {
          _webSocketService.markActiveInConversation(conversationId);
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
    
    if (_isWebSocketEnabled && _webSocketService.isConnected) {
      _webSocketService.markActiveInConversation(conversationId);
    } else {
      _notificationService.startPolling(conversationId);
    }
  }

  /// Stop real-time updates
  void stopRealTimeUpdates() {
    _currentConversationId = null;
    _notificationService.stopPolling();
    
    // Clear typing indicators
    _typingUsers.clear();
    notifyListeners();
  }
  
  /// Send typing indicator
  void sendTypingIndicator(String conversationId, bool isTyping) {
    if (_isWebSocketEnabled && _webSocketService.isConnected) {
      _webSocketService.sendTypingIndicator(conversationId, isTyping);
    }
    // No fallback for typing - it's real-time only
  }
  
  /// Mark message as read
  void markMessageAsRead(String messageId, String conversationId) {
    if (_isWebSocketEnabled && _webSocketService.isConnected) {
      _webSocketService.markMessageAsRead(messageId, conversationId);
    }
    // Update local state immediately
    _updateMessageInState(messageId, (message) {
      return message.copyWith(isRead: true);
    });
    notifyListeners();
  }
  
  /// Toggle WebSocket enabled state
  void setWebSocketEnabled(bool enabled) {
    _isWebSocketEnabled = enabled;
    
    if (enabled) {
      // Try to reconnect if we have connectivity
      if (_connectivityService.isOnline) {
        _webSocketService.forceReconnect();
      }
    } else {
      _webSocketService.disconnect();
    }
    
    notifyListeners();
  }
  
  /// Force WebSocket reconnection
  Future<void> forceReconnect() async {
    if (_isWebSocketEnabled) {
      await _webSocketService.forceReconnect();
    }
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
  
  void _updateConversationOrder(String conversationId) {
    final index = _conversations.indexWhere((c) => c.id == conversationId);
    if (index != -1) {
      // Move conversation to top
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
  
  /// Parse message type from WebSocket event
  MessageType _parseMessageType(String type) {
    switch (type.toLowerCase()) {
      case 'text':
        return MessageType.text;
      case 'image':
        return MessageType.image;
      case 'video':
        return MessageType.video;
      case 'audio':
        return MessageType.audio;
      case 'file':
        return MessageType.file;
      case 'paid':
      case 'paid_text':
        return MessageType.paid_text;
      case 'paid_image':
        return MessageType.paid_image;
      case 'paid_video':
        return MessageType.paid_video;
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





  void forceReconnect() {
    print('MessageProvider: Force reconnecting WebSocket...');
    if (_isWebSocketEnabled) {
      _webSocketService.reconnect();
    }
  }

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

  void _setCurrentConversation(String? conversationId) {
    if (_currentConversationId != conversationId) {
      // Leave current conversation WebSocket room
      if (_currentConversationId != null && _isWebSocketEnabled && _webSocketService.isConnected) {
        _webSocketService.leaveConversation(_currentConversationId!);
      }
      
      _currentConversationId = conversationId;
      
      // Join new conversation WebSocket room
      if (_currentConversationId != null && _isWebSocketEnabled && _webSocketService.isConnected) {
        _webSocketService.joinConversation(_currentConversationId!);
      }
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
