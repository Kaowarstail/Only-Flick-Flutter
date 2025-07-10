import 'dart:async';
import '../models/models.dart';
import 'conversation_service.dart';

class NotificationService {
  Timer? _pollingTimer;
  StreamController<int>? _unreadCountController;
  StreamController<List<Conversation>>? _conversationsController;
  
  // Configuration polling
  static const Duration _pollingInterval = Duration(seconds: 30);
  static const Duration _activePollingInterval = Duration(seconds: 5);
  
  bool _isPolling = false;
  bool _isAppActive = true;

  // ========== Streams ==========

  /// Stream du nombre de messages non lus
  Stream<int> get unreadCountStream {
    _unreadCountController ??= StreamController<int>.broadcast();
    return _unreadCountController!.stream;
  }

  /// Stream des conversations (pour mises à jour temps réel)
  Stream<List<Conversation>> get conversationsStream {
    _conversationsController ??= StreamController<List<Conversation>>.broadcast();
    return _conversationsController!.stream;
  }

  // ========== Polling Management ==========

  /// Démarre le polling des notifications
  void startPolling() {
    if (_isPolling) return;
    
    _isPolling = true;
    _scheduleNextPoll();
    print('📱 Notification polling started');
  }

  /// Arrête le polling
  void stopPolling() {
    _isPolling = false;
    _pollingTimer?.cancel();
    _pollingTimer = null;
    print('📱 Notification polling stopped');
  }

  /// Met à jour l'état actif de l'app (pour ajuster fréquence polling)
  void setAppActive(bool isActive) {
    _isAppActive = isActive;
    
    if (_isPolling) {
      // Redémarrer avec nouvelle fréquence
      _pollingTimer?.cancel();
      _scheduleNextPoll();
    }
    
    print('📱 App active state: $isActive');
  }

  /// Force une vérification immédiate
  Future<void> checkNow() async {
    await _checkForUpdates();
  }

  // ========== Polling Logic ==========

  void _scheduleNextPoll() {
    if (!_isPolling) return;
    
    final interval = _isAppActive 
        ? _activePollingInterval 
        : _pollingInterval;
    
    _pollingTimer = Timer(interval, () async {
      await _checkForUpdates();
      _scheduleNextPoll();
    });
  }

  Future<void> _checkForUpdates() async {
    try {
      // Vérifier messages non lus
      final unreadCount = await ConversationService.getTotalUnreadCount();
      _unreadCountController?.add(unreadCount);

      // Vérifier conversations mises à jour (seulement si app active)
      if (_isAppActive) {
        final conversationsResponse = await ConversationService.getConversations(
          page: 1,
          limit: 10, // Juste les plus récentes
        );
        
        if (conversationsResponse != null) {
          _conversationsController?.add(conversationsResponse.conversations);
        }
      }
      
    } catch (e) {
      print('Error checking for updates: $e');
    }
  }

  // ========== Local Notifications ==========

  /// Affiche une notification locale pour nouveau message
  Future<void> showLocalNotification({
    required String title,
    required String body,
    required String conversationId,
  }) async {
    // TODO: Intégrer avec flutter_local_notifications
    // Pour l'instant, juste log
    print('🔔 Notification: $title - $body');
  }

  /// Gère les notifications de nouveaux messages
  void handleNewMessage(Message message) {
    if (!_isAppActive) {
      showLocalNotification(
        title: message.sender.displayName,
        body: message.shortDisplayContent,
        conversationId: message.conversationId,
      );
    }
  }

  // ========== Badge Management ==========

  /// Met à jour le badge de l'app avec le nombre de messages non lus
  void updateAppBadge(int unreadCount) {
    // TODO: Intégrer avec flutter_app_badger
    print('📱 Badge count: $unreadCount');
  }

  // ========== Singleton Pattern ==========

  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // ========== Cleanup ==========

  void dispose() {
    stopPolling();
    _unreadCountController?.close();
    _conversationsController?.close();
    _unreadCountController = null;
    _conversationsController = null;
  }
}
