import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';
import '../services/notification_service.dart';
import '../services/messaging_service_locator.dart';

/// Provider pour la gestion des notifications de messagerie
class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService;
  
  // État des notifications
  List<MessageNotification> _notifications = [];
  bool _isPolling = false;
  int _totalUnreadCount = 0;
  
  // Configuration du badge
  bool _badgeEnabled = true;
  
  // Gestion du cycle de vie de l'app
  bool _isAppActive = true;
  AppLifecycleState _appLifecycleState = AppLifecycleState.resumed;
  
  // Streams
  StreamSubscription<List<MessageNotification>>? _notificationSubscription;
  StreamSubscription<int>? _unreadCountSubscription;

  NotificationProvider({NotificationService? notificationService})
      : _notificationService = notificationService ?? NotificationService() {
    _initializeNotifications();
  }

  // ========== Getters ==========

  /// Liste des notifications
  List<MessageNotification> get notifications => List.unmodifiable(_notifications);

  /// Nombre total de messages non lus
  int get totalUnreadCount => _totalUnreadCount;

  /// Indique si le polling est actif
  bool get isPolling => _isPolling;

  /// Indique si les badges sont activés
  bool get badgeEnabled => _badgeEnabled;

  /// État du cycle de vie de l'app
  AppLifecycleState get appLifecycleState => _appLifecycleState;

  /// Notifications non lues seulement
  List<MessageNotification> get unreadNotifications {
    return _notifications.where((notif) => !notif.isRead).toList();
  }

  /// Notifications par conversation
  Map<int, List<MessageNotification>> get notificationsByConversation {
    final Map<int, List<MessageNotification>> grouped = {};
    
    for (final notification in _notifications) {
      final conversationId = notification.conversationId;
      grouped[conversationId] ??= [];
      grouped[conversationId]!.add(notification);
    }
    
    return grouped;
  }

  /// Nombre de conversations avec notifications non lues
  int get unreadConversationsCount {
    return notificationsByConversation.entries
        .where((entry) => entry.value.any((notif) => !notif.isRead))
        .length;
  }

  // ========== Méthodes publiques ==========

  /// Démarre le système de notifications
  Future<void> startNotifications() async {
    if (_isPolling) return;

    try {
      await _notificationService.startPolling();
      _isPolling = true;
      
      // S'abonner aux streams
      _subscribeToStreams();
      
      notifyListeners();
    } catch (e) {
      print('Error starting notifications: $e');
    }
  }

  /// Arrête le système de notifications
  Future<void> stopNotifications() async {
    if (!_isPolling) return;

    try {
      await _notificationService.stopPolling();
      _isPolling = false;
      
      // Se désabonner des streams
      _unsubscribeFromStreams();
      
      notifyListeners();
    } catch (e) {
      print('Error stopping notifications: $e');
    }
  }

  /// Met à jour l'état du cycle de vie de l'app
  void updateAppLifecycleState(AppLifecycleState state) {
    _appLifecycleState = state;
    _isAppActive = state == AppLifecycleState.resumed;
    
    // Adapter la fréquence de polling
    _notificationService.setAppActive(_isAppActive);
    
    notifyListeners();
  }

  /// Marque une notification comme lue
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      // Mettre à jour localement
      final index = _notifications.indexWhere((notif) => notif.id == notificationId);
      if (index != -1 && !_notifications[index].isRead) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        _updateUnreadCount();
        notifyListeners();
      }
      
      // Synchroniser avec le serveur (optionnel)
      // await _notificationService.markAsRead(notificationId);
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  /// Marque toutes les notifications d'une conversation comme lues
  Future<void> markConversationNotificationsAsRead(int conversationId) async {
    try {
      bool hasChanges = false;
      
      for (int i = 0; i < _notifications.length; i++) {
        if (_notifications[i].conversationId == conversationId && !_notifications[i].isRead) {
          _notifications[i] = _notifications[i].copyWith(isRead: true);
          hasChanges = true;
        }
      }
      
      if (hasChanges) {
        _updateUnreadCount();
        notifyListeners();
      }
    } catch (e) {
      print('Error marking conversation notifications as read: $e');
    }
  }

  /// Marque toutes les notifications comme lues
  Future<void> markAllNotificationsAsRead() async {
    try {
      bool hasChanges = false;
      
      for (int i = 0; i < _notifications.length; i++) {
        if (!_notifications[i].isRead) {
          _notifications[i] = _notifications[i].copyWith(isRead: true);
          hasChanges = true;
        }
      }
      
      if (hasChanges) {
        _updateUnreadCount();
        notifyListeners();
      }
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }

  /// Supprime une notification
  void removeNotification(String notificationId) {
    final index = _notifications.indexWhere((notif) => notif.id == notificationId);
    if (index != -1) {
      _notifications.removeAt(index);
      _updateUnreadCount();
      notifyListeners();
    }
  }

  /// Supprime toutes les notifications d'une conversation
  void removeConversationNotifications(int conversationId) {
    _notifications.removeWhere((notif) => notif.conversationId == conversationId);
    _updateUnreadCount();
    notifyListeners();
  }

  /// Efface toutes les notifications
  void clearAllNotifications() {
    _notifications.clear();
    _totalUnreadCount = 0;
    _updateBadge();
    notifyListeners();
  }

  /// Active/désactive les badges
  void setBadgeEnabled(bool enabled) {
    _badgeEnabled = enabled;
    
    if (!enabled) {
      _clearBadge();
    } else {
      _updateBadge();
    }
    
    notifyListeners();
  }

  /// Force la mise à jour des notifications
  Future<void> refreshNotifications() async {
    try {
      await _notificationService.checkForNewNotifications();
    } catch (e) {
      print('Error refreshing notifications: $e');
    }
  }

  /// Récupère la dernière notification d'une conversation
  MessageNotification? getLastNotificationForConversation(int conversationId) {
    final conversationNotifications = _notifications
        .where((notif) => notif.conversationId == conversationId)
        .toList();
    
    if (conversationNotifications.isEmpty) return null;
    
    conversationNotifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return conversationNotifications.first;
  }

  /// Vérifie si une conversation a des notifications non lues
  bool hasUnreadNotifications(int conversationId) {
    return _notifications.any((notif) => 
        notif.conversationId == conversationId && !notif.isRead);
  }

  /// Obtient le nombre de notifications non lues pour une conversation
  int getUnreadCountForConversation(int conversationId) {
    return _notifications
        .where((notif) => notif.conversationId == conversationId && !notif.isRead)
        .length;
  }

  // ========== Méthodes privées ==========

  /// Initialise le système de notifications
  Future<void> _initializeNotifications() async {
    try {
      // Charger les notifications existantes si nécessaire
      await startNotifications();
    } catch (e) {
      print('Error initializing notifications: $e');
    }
  }

  /// S'abonne aux streams de notifications
  void _subscribeToStreams() {
    // Stream des nouvelles notifications
    _notificationSubscription = _notificationService.notificationStream.listen(
      (notifications) {
        _handleNewNotifications(notifications);
      },
      onError: (error) {
        print('Error in notification stream: $error');
      },
    );

    // Stream du nombre de messages non lus
    _unreadCountSubscription = _notificationService.unreadCountStream.listen(
      (count) {
        _totalUnreadCount = count;
        _updateBadge();
        notifyListeners();
      },
      onError: (error) {
        print('Error in unread count stream: $error');
      },
    );
  }

  /// Se désabonne des streams
  void _unsubscribeFromStreams() {
    _notificationSubscription?.cancel();
    _notificationSubscription = null;
    
    _unreadCountSubscription?.cancel();
    _unreadCountSubscription = null;
  }

  /// Gère les nouvelles notifications
  void _handleNewNotifications(List<MessageNotification> newNotifications) {
    bool hasNewNotifications = false;
    
    for (final notification in newNotifications) {
      // Vérifier si la notification existe déjà
      if (!_notifications.any((notif) => notif.id == notification.id)) {
        _notifications.add(notification);
        hasNewNotifications = true;
      }
    }
    
    if (hasNewNotifications) {
      // Trier par timestamp (plus récent en premier)
      _notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      // Limiter le nombre de notifications en mémoire (optionnel)
      if (_notifications.length > 100) {
        _notifications = _notifications.take(100).toList();
      }
      
      _updateUnreadCount();
      notifyListeners();
    }
  }

  /// Met à jour le compteur de non lus
  void _updateUnreadCount() {
    _totalUnreadCount = _notifications.where((notif) => !notif.isRead).length;
    _updateBadge();
  }

  /// Met à jour le badge de l'application
  void _updateBadge() {
    if (!_badgeEnabled) return;
    
    try {
      // Utiliser le plugin flutter_app_badge ou similaire
      // FlutterAppBadge.updateBadgeCount(_totalUnreadCount);
      
      // Pour l'instant, on peut utiliser un channel method pour iOS/Android
      _setBadgeCount(_totalUnreadCount);
    } catch (e) {
      print('Error updating badge: $e');
    }
  }

  /// Efface le badge
  void _clearBadge() {
    try {
      _setBadgeCount(0);
    } catch (e) {
      print('Error clearing badge: $e');
    }
  }

  /// Met à jour le badge natif (placeholder)
  void _setBadgeCount(int count) {
    // TODO: Implémenter avec un plugin de badge ou platform channel
    // Pour l'instant, juste un print pour debug
    if (kDebugMode) {
      print('Badge count: $count');
    }
  }

  @override
  void dispose() {
    _unsubscribeFromStreams();
    stopNotifications();
    super.dispose();
  }
}
