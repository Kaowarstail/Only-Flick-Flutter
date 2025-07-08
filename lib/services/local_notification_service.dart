import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/websocket_models.dart';

class LocalNotificationService {
  static final LocalNotificationService _instance = LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal();
  
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  
  bool _isInitialized = false;
  bool _notificationsEnabled = true;
  
  // Getters
  bool get isInitialized => _isInitialized;
  bool get notificationsEnabled => _notificationsEnabled;
  
  /// Initialiser le service de notifications
  Future<bool> initialize() async {
    try {
      print('LocalNotificationService: Initializing...');
      
      // Configuration Android
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      
      // Configuration iOS
      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          );
      
      const InitializationSettings initializationSettings =
          InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
          );
      
      final bool initialized = await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );
      
      if (initialized) {
        await _requestPermissions();
        _isInitialized = true;
        print('LocalNotificationService: Initialized successfully');
      }
      
      return initialized;
      
    } catch (e) {
      print('LocalNotificationService: Initialization error: $e');
      return false;
    }
  }
  
  /// Demander les permissions de notifications
  Future<void> _requestPermissions() async {
    if (Platform.isIOS) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      
      await androidImplementation?.requestPermission();
    }
  }
  
  /// Gérer le clic sur une notification
  void _onNotificationTapped(NotificationResponse notificationResponse) {
    print('LocalNotificationService: Notification tapped: ${notificationResponse.payload}');
    
    // TODO: Naviguer vers la conversation ou l'écran approprié
    // Utiliser un NavigatorService ou un callback
  }
  
  /// Afficher une notification pour un nouveau message
  Future<void> showMessageNotification(MessageSentEvent messageEvent) async {
    if (!_isInitialized || !_notificationsEnabled) return;
    
    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
            'messages_channel',
            'Messages',
            channelDescription: 'Notifications for new messages',
            importance: Importance.high,
            priority: Priority.high,
            showWhen: true,
            icon: '@mipmap/ic_launcher',
          );
      
      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          );
      
      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );
      
      // Créer le contenu de la notification
      final title = messageEvent.senderName ?? 'New Message';
      final body = _formatMessageContent(messageEvent.content, messageEvent.messageType);
      
      await _flutterLocalNotificationsPlugin.show(
        messageEvent.messageId.hashCode,
        title,
        body,
        platformChannelSpecifics,
        payload: 'message:${messageEvent.conversationId}:${messageEvent.messageId}',
      );
      
      print('LocalNotificationService: Message notification shown');
      
    } catch (e) {
      print('LocalNotificationService: Error showing message notification: $e');
    }
  }
  
  /// Afficher une notification pour un message payant déverrouillé
  Future<void> showPaidMessageUnlockedNotification(PaidMessageUnlockedEvent event) async {
    if (!_isInitialized || !_notificationsEnabled) return;
    
    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
            'paid_messages_channel',
            'Paid Messages',
            channelDescription: 'Notifications for paid messages',
            importance: Importance.high,
            priority: Priority.high,
            showWhen: true,
            icon: '@mipmap/ic_launcher',
          );
      
      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          );
      
      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );
      
      await _flutterLocalNotificationsPlugin.show(
        event.messageId.hashCode,
        'Paid Message Unlocked! 💰',
        'You received ${event.amount} credits from your paid message',
        platformChannelSpecifics,
        payload: 'paid_message:${event.conversationId}:${event.messageId}',
      );
      
      print('LocalNotificationService: Paid message notification shown');
      
    } catch (e) {
      print('LocalNotificationService: Error showing paid message notification: $e');
    }
  }
  
  /// Afficher une notification pour un changement de statut utilisateur
  Future<void> showUserStatusNotification(UserStatusEvent event) async {
    if (!_isInitialized || !_notificationsEnabled) return;
    
    // Ne montrer que si l'utilisateur vient de se connecter
    if (!event.isOnline) return;
    
    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
            'user_status_channel',
            'User Status',
            channelDescription: 'Notifications for user status changes',
            importance: Importance.low,
            priority: Priority.low,
            showWhen: true,
            icon: '@mipmap/ic_launcher',
          );
      
      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
            presentAlert: false,
            presentBadge: false,
            presentSound: false,
          );
      
      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );
      
      await _flutterLocalNotificationsPlugin.show(
        event.userId.hashCode,
        'User Online',
        '${event.username} is now online',
        platformChannelSpecifics,
        payload: 'user_status:${event.userId}',
      );
      
      print('LocalNotificationService: User status notification shown');
      
    } catch (e) {
      print('LocalNotificationService: Error showing user status notification: $e');
    }
  }
  
  /// Afficher une notification pour une conversation mise à jour
  Future<void> showConversationUpdatedNotification(ConversationUpdatedEvent event) async {
    if (!_isInitialized || !_notificationsEnabled) return;
    
    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
            'conversation_updates_channel',
            'Conversation Updates',
            channelDescription: 'Notifications for conversation updates',
            importance: Importance.low,
            priority: Priority.low,
            showWhen: true,
            icon: '@mipmap/ic_launcher',
          );
      
      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
            presentAlert: false,
            presentBadge: true,
            presentSound: false,
          );
      
      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );
      
      await _flutterLocalNotificationsPlugin.show(
        event.conversationId.hashCode,
        'Conversation Updated',
        'New activity in your conversation',
        platformChannelSpecifics,
        payload: 'conversation:${event.conversationId}',
      );
      
      print('LocalNotificationService: Conversation update notification shown');
      
    } catch (e) {
      print('LocalNotificationService: Error showing conversation update notification: $e');
    }
  }
  
  /// Formater le contenu du message pour la notification
  String _formatMessageContent(String content, String messageType) {
    switch (messageType) {
      case 'text':
        return content.length > 100 ? '${content.substring(0, 100)}...' : content;
      case 'image':
        return '📷 Image message';
      case 'video':
        return '🎥 Video message';
      case 'audio':
        return '🎵 Audio message';
      case 'file':
        return '📎 File message';
      case 'paid':
        return '💰 Paid message';
      default:
        return 'New message';
    }
  }
  
  /// Annuler une notification spécifique
  Future<void> cancelNotification(int id) async {
    if (!_isInitialized) return;
    
    try {
      await _flutterLocalNotificationsPlugin.cancel(id);
      print('LocalNotificationService: Notification $id cancelled');
    } catch (e) {
      print('LocalNotificationService: Error cancelling notification: $e');
    }
  }
  
  /// Annuler toutes les notifications
  Future<void> cancelAllNotifications() async {
    if (!_isInitialized) return;
    
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
      print('LocalNotificationService: All notifications cancelled');
    } catch (e) {
      print('LocalNotificationService: Error cancelling all notifications: $e');
    }
  }
  
  /// Activer/désactiver les notifications
  void setNotificationsEnabled(bool enabled) {
    _notificationsEnabled = enabled;
    
    if (!enabled) {
      cancelAllNotifications();
    }
    
    print('LocalNotificationService: Notifications ${enabled ? 'enabled' : 'disabled'}');
  }
  
  /// Obtenir le nombre de notifications en attente
  Future<int> getPendingNotificationCount() async {
    if (!_isInitialized) return 0;
    
    try {
      final List<PendingNotificationRequest> pendingNotifications =
          await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
      return pendingNotifications.length;
    } catch (e) {
      print('LocalNotificationService: Error getting pending notifications: $e');
      return 0;
    }
  }
  
  /// Vérifier si les notifications sont autorisées
  Future<bool> areNotificationsEnabled() async {
    if (!_isInitialized) return false;
    
    try {
      if (Platform.isAndroid) {
        final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
            _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        
        return await androidImplementation?.areNotificationsEnabled() ?? false;
      } else if (Platform.isIOS) {
        final IOSFlutterLocalNotificationsPlugin? iosImplementation =
            _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>();
        
        final bool? result = await iosImplementation?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return result ?? false;
      }
      
      return false;
      
    } catch (e) {
      print('LocalNotificationService: Error checking notification permissions: $e');
      return false;
    }
  }
}
