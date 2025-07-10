import 'package:flutter/material.dart';
import 'message_service.dart';
import 'conversation_service.dart';
import 'notification_service.dart';
import 'media_service.dart';

/// Service Locator pour centraliser l'accès aux services de messagerie
class MessagingServiceLocator {
  static final MessagingServiceLocator _instance = MessagingServiceLocator._internal();
  factory MessagingServiceLocator() => _instance;
  MessagingServiceLocator._internal();

  // Instance unique du NotificationService (singleton)
  NotificationService? _notificationService;

  // ========== Getters pour Services ==========

  /// Service de gestion des messages
  /// Utilise des méthodes statiques donc pas besoin d'instance
  Type get messageService => MessageService;

  /// Service de gestion des conversations
  /// Utilise des méthodes statiques donc pas besoin d'instance
  Type get conversationService => ConversationService;

  /// Service de notifications avec polling
  /// Instance singleton pour maintenir l'état du polling
  NotificationService get notificationService {
    _notificationService ??= NotificationService();
    return _notificationService!;
  }

  /// Service de gestion des médias
  /// Utilise des méthodes statiques donc pas besoin d'instance
  Type get mediaService => MediaService;

  // ========== Helper Methods ==========

  /// Démarre tous les services nécessaires
  void startServices() {
    notificationService.startPolling();
    print('🚀 Messaging services started');
  }

  /// Arrête tous les services
  void stopServices() {
    notificationService.stopPolling();
    print('🛑 Messaging services stopped');
  }

  /// Met à jour l'état actif de l'application
  void setAppState(bool isActive) {
    notificationService.setAppActive(isActive);
  }

  /// Reset pour tests ou changement d'utilisateur
  void reset() {
    _notificationService?.dispose();
    _notificationService = null;
    print('🔄 Messaging services reset');
  }

  // ========== Quick Access Methods ==========

  /// Accès rapide au stream des messages non lus
  Stream<int> get unreadCountStream => notificationService.unreadCountStream;

  /// Accès rapide au stream des conversations
  Stream<List<dynamic>> get conversationsStream => notificationService.conversationsStream;

  /// Force une vérification des notifications
  Future<void> checkNotifications() async {
    await notificationService.checkNow();
  }
}

// Instance globale pour accès facile
final messagingServices = MessagingServiceLocator();
