/// Notification service for OnlyFlick messaging system
/// Handles push notifications and real-time polling

import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/message_models.dart';
import 'api_service.dart';
import 'conversation_service.dart';
import 'message_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // Polling timers
  Timer? _activePollingTimer;
  Timer? _backgroundPollingTimer;
  
  // Current conversation being viewed
  String? _currentConversationId;
  
  // Polling intervals
  static const Duration _activePollingInterval = Duration(seconds: 3);
  static const Duration _backgroundPollingInterval = Duration(seconds: 30);
  
  // Callbacks
  Function(List<Conversation>)? _onConversationsUpdated;
  Function(String, List<Message>)? _onMessagesUpdated;
  Function(int)? _onUnreadCountUpdated;

  /// Initialize push notifications
  Future<void> initializePushNotifications() async {
    try {
      // For now, we'll simulate push notification setup
      // In a real app, you would integrate with Firebase/OneSignal
      await _requestPermissions();
      await _setupNotificationHandlers();
    } catch (e) {
      print('Error initializing push notifications: $e');
    }
  }

  /// Request notification permissions
  Future<void> requestPermissions() async {
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    try {
      // Simulate permission request
      // In a real app, you would use a plugin like firebase_messaging
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications_enabled', true);
    } catch (e) {
      print('Error requesting permissions: $e');
    }
  }

  /// Setup notification handlers
  Future<void> _setupNotificationHandlers() async {
    // Simulate notification handlers setup
    // In a real app, you would configure Firebase/OneSignal handlers
  }

  /// Start polling for real-time updates when viewing a conversation
  void startPolling(String conversationId) {
    _currentConversationId = conversationId;
    _stopActivePolling();
    _startActivePolling();
  }

  /// Stop polling when leaving a conversation
  void stopPolling() {
    _currentConversationId = null;
    _stopActivePolling();
  }

  /// Start background polling for general updates
  void startBackgroundPolling() {
    _stopBackgroundPolling();
    _startBackgroundPolling();
  }

  /// Stop background polling
  void stopBackgroundPolling() {
    _stopBackgroundPolling();
  }

  /// Start active polling for current conversation
  void _startActivePolling() {
    _activePollingTimer = Timer.periodic(_activePollingInterval, (timer) {
      _pollCurrentConversation();
    });
  }

  /// Stop active polling
  void _stopActivePolling() {
    _activePollingTimer?.cancel();
    _activePollingTimer = null;
  }

  /// Start background polling for all conversations
  void _startBackgroundPolling() {
    _backgroundPollingTimer = Timer.periodic(_backgroundPollingInterval, (timer) {
      _pollAllConversations();
    });
  }

  /// Stop background polling
  void _stopBackgroundPolling() {
    _backgroundPollingTimer?.cancel();
    _backgroundPollingTimer = null;
  }

  /// Poll current conversation for new messages
  Future<void> _pollCurrentConversation() async {
    if (_currentConversationId == null) return;

    try {
      // Get latest messages
      final messageResponse = await MessageService().getMessages(
        _currentConversationId!,
        limit: 20,
      );

      if (messageResponse.success && messageResponse.data != null) {
        _onMessagesUpdated?.call(_currentConversationId!, messageResponse.data!);
      }

      // Update unread count
      await _updateUnreadCount();
    } catch (e) {
      print('Error polling current conversation: $e');
    }
  }

  /// Poll all conversations for updates
  Future<void> _pollAllConversations() async {
    try {
      // Get latest conversations
      final conversationResponse = await ConversationService().getConversations(
        limit: 50,
      );

      if (conversationResponse.success && conversationResponse.data != null) {
        _onConversationsUpdated?.call(conversationResponse.data!);
      }

      // Update unread count
      await _updateUnreadCount();
    } catch (e) {
      print('Error polling all conversations: $e');
    }
  }

  /// Update unread count
  Future<void> _updateUnreadCount() async {
    try {
      final unreadResponse = await ConversationService().getUnreadCount();
      if (unreadResponse.success && unreadResponse.data != null) {
        _onUnreadCountUpdated?.call(unreadResponse.data!);
      }
    } catch (e) {
      print('Error updating unread count: $e');
    }
  }

  /// Set callback for conversation updates
  void setConversationsUpdateCallback(Function(List<Conversation>) callback) {
    _onConversationsUpdated = callback;
  }

  /// Set callback for message updates
  void setMessagesUpdateCallback(Function(String, List<Message>) callback) {
    _onMessagesUpdated = callback;
  }

  /// Set callback for unread count updates
  void setUnreadCountCallback(Function(int) callback) {
    _onUnreadCountUpdated = callback;
  }

  /// Set callback for user typing indicator
  void setUserTypingCallback(Function(String, String) callback) {
    // For future implementation
  }

  /// Handle foreground message
  void handleForegroundMessage(Map<String, dynamic> message) {
    // Handle message received while app is in foreground
    try {
      final messageType = message['type'] ?? '';
      
      if (messageType == 'new_message') {
        _handleNewMessageNotification(message);
      } else if (messageType == 'paid_message') {
        _handlePaidMessageNotification(message);
      }
    } catch (e) {
      print('Error handling foreground message: $e');
    }
  }

  /// Handle background message
  void handleBackgroundMessage(Map<String, dynamic> message) {
    // Handle message received while app is in background
    try {
      // Show system notification
      _showSystemNotification(message);
    } catch (e) {
      print('Error handling background message: $e');
    }
  }

  /// Handle notification tap
  void handleNotificationTap(Map<String, dynamic> message) {
    // Handle user tapping on notification
    try {
      final conversationId = message['conversation_id'];
      if (conversationId != null) {
        // Navigate to conversation
        // This would be handled by the UI layer
        print('Navigate to conversation: $conversationId');
      }
    } catch (e) {
      print('Error handling notification tap: $e');
    }
  }

  /// Handle new message notification
  void _handleNewMessageNotification(Map<String, dynamic> data) {
    try {
      final conversationId = data['conversation_id'];
      if (conversationId != null) {
        // Trigger real-time update
        _pollCurrentConversation();
      }
    } catch (e) {
      print('Error handling new message notification: $e');
    }
  }

  /// Handle paid message notification
  void _handlePaidMessageNotification(Map<String, dynamic> data) {
    try {
      final conversationId = data['conversation_id'];
      if (conversationId != null) {
        // Trigger real-time update
        _pollCurrentConversation();
      }
    } catch (e) {
      print('Error handling paid message notification: $e');
    }
  }

  /// Show system notification
  void _showSystemNotification(Map<String, dynamic> message) {
    // In a real app, this would show a platform-specific notification
    print('System notification: ${message['title']} - ${message['body']}');
  }

  /// Get device token for push notifications
  Future<String?> getDeviceToken() async {
    try {
      // In a real app, you would get the actual device token
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('device_token');
    } catch (e) {
      print('Error getting device token: $e');
      return null;
    }
  }

  /// Subscribe to user notifications
  Future<void> subscribeToUserNotifications(String userId) async {
    try {
      final deviceToken = await getDeviceToken();
      if (deviceToken != null) {
        await ApiService.post(
          '/notifications/subscribe',
          body: {
            'user_id': userId,
            'device_token': deviceToken,
            'platform': 'flutter',
          },
          requiresAuth: true,
        );
      }
    } catch (e) {
      print('Error subscribing to notifications: $e');
    }
  }

  /// Unsubscribe from user notifications
  Future<void> unsubscribeFromUserNotifications(String userId) async {
    try {
      final deviceToken = await getDeviceToken();
      if (deviceToken != null) {
        await ApiService.post(
          '/notifications/unsubscribe',
          body: {
            'user_id': userId,
            'device_token': deviceToken,
          },
          requiresAuth: true,
        );
      }
    } catch (e) {
      print('Error unsubscribing from notifications: $e');
    }
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('notifications_enabled') ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Enable notifications
  Future<void> enableNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications_enabled', true);
    } catch (e) {
      print('Error enabling notifications: $e');
    }
  }

  /// Disable notifications
  Future<void> disableNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications_enabled', false);
    } catch (e) {
      print('Error disabling notifications: $e');
    }
  }

  /// Cleanup resources
  void dispose() {
    _stopActivePolling();
    _stopBackgroundPolling();
    _onConversationsUpdated = null;
    _onMessagesUpdated = null;
    _onUnreadCountUpdated = null;
  }
}
