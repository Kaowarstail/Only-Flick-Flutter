import 'package:flutter/foundation.dart';
import '../models/models.dart';
import 'conversation_provider.dart';
import 'message_provider.dart';
import 'notification_provider.dart';
import 'chat_media_provider.dart';

/// Contrôleur principal pour orchestrer tous les providers de messagerie
class MessagingController extends ChangeNotifier {
  final ConversationProvider _conversationProvider;
  final MessageProvider _messageProvider;
  final NotificationProvider _notificationProvider;
  final ChatMediaProvider _chatMediaProvider;

  // État global
  bool _isInitialized = false;
  bool _isConnected = false;
  String? _currentError;

  MessagingController({
    required ConversationProvider conversationProvider,
    required MessageProvider messageProvider,
    required NotificationProvider notificationProvider,
    required ChatMediaProvider chatMediaProvider,
  })  : _conversationProvider = conversationProvider,
        _messageProvider = messageProvider,
        _notificationProvider = notificationProvider,
        _chatMediaProvider = chatMediaProvider {
    _initialize();
  }

  // ========== Getters ==========

  /// Provider des conversations
  ConversationProvider get conversations => _conversationProvider;

  /// Provider des messages
  MessageProvider get messages => _messageProvider;

  /// Provider des notifications
  NotificationProvider get notifications => _notificationProvider;

  /// Provider des médias
  ChatMediaProvider get media => _chatMediaProvider;

  /// Indique si le système de messagerie est initialisé
  bool get isInitialized => _isInitialized;

  /// Indique si la connexion est active
  bool get isConnected => _isConnected;

  /// Dernière erreur globale
  String? get currentError => _currentError;

  /// Conversation actuellement sélectionnée
  Conversation? get currentConversation => _conversationProvider.currentConversation;

  /// Messages de la conversation courante
  List<Message> get currentMessages {
    final conversation = currentConversation;
    if (conversation == null) return [];
    return _messageProvider.getMessages(conversation.id);
  }

  /// Nombre total de conversations non lues
  int get totalUnreadConversations => _conversationProvider.unreadCount;

  /// Nombre total de messages non lus
  int get totalUnreadMessages => _notificationProvider.totalUnreadCount;

  // ========== Méthodes publiques ==========

  /// Initialise le système de messagerie
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _clearError();
      
      // Démarrer les notifications
      await _notificationProvider.startNotifications();
      
      // Charger les conversations initiales
      await _conversationProvider.loadConversations();
      
      // Charger les statistiques
      await _conversationProvider.loadStats();
      
      _isInitialized = true;
      _isConnected = true;
      notifyListeners();
    } catch (e) {
      _setError('Erreur d\'initialisation: $e');
    }
  }

  /// Arrête le système de messagerie
  Future<void> shutdown() async {
    try {
      await _notificationProvider.stopNotifications();
      _isConnected = false;
      notifyListeners();
    } catch (e) {
      print('Error during shutdown: $e');
    }
  }

  /// Sélectionne une conversation et charge ses messages
  Future<void> selectConversation(int conversationId) async {
    try {
      _clearError();
      
      // Sélectionner la conversation
      await _conversationProvider.selectConversation(conversationId);
      
      // Charger les messages de cette conversation
      await _messageProvider.loadMessages(conversationId);
      
      // Marquer les notifications comme lues
      await _notificationProvider.markConversationNotificationsAsRead(conversationId);
      
      notifyListeners();
    } catch (e) {
      _setError('Erreur lors de la sélection de la conversation: $e');
    }
  }

  /// Envoie un message texte
  Future<Message?> sendTextMessage({
    required int conversationId,
    required String content,
    Message? replyTo,
  }) async {
    try {
      _clearError();
      
      final message = await _messageProvider.sendMessage(
        conversationId: conversationId,
        content: content,
        replyTo: replyTo,
      );
      
      if (message != null) {
        // Mettre à jour la conversation avec le dernier message
        _conversationProvider.updateLastMessage(conversationId, message);
      }
      
      return message;
    } catch (e) {
      _setError('Erreur lors de l\'envoi du message: $e');
      return null;
    }
  }

  /// Envoie un message avec médias
  Future<Message?> sendMediaMessage({
    required int conversationId,
    required String content,
    required List<String> mediaUrls,
    Message? replyTo,
  }) async {
    try {
      _clearError();
      
      final message = await _messageProvider.sendMessage(
        conversationId: conversationId,
        content: content,
        mediaUrls: mediaUrls,
        replyTo: replyTo,
      );
      
      if (message != null) {
        // Mettre à jour la conversation avec le dernier message
        _conversationProvider.updateLastMessage(conversationId, message);
      }
      
      return message;
    } catch (e) {
      _setError('Erreur lors de l\'envoi du message avec médias: $e');
      return null;
    }
  }

  /// Crée une nouvelle conversation
  Future<Conversation?> createConversation(int participantId) async {
    try {
      _clearError();
      
      final conversation = await _conversationProvider.createOrGetConversation(participantId);
      
      if (conversation != null) {
        // Sélectionner automatiquement la nouvelle conversation
        await selectConversation(conversation.id);
      }
      
      return conversation;
    } catch (e) {
      _setError('Erreur lors de la création de la conversation: $e');
      return null;
    }
  }

  /// Supprime une conversation
  Future<bool> deleteConversation(int conversationId) async {
    try {
      _clearError();
      
      final success = await _conversationProvider.deleteConversation(conversationId);
      
      if (success) {
        // Nettoyer les messages associés
        _messageProvider.clearMessages(conversationId);
        
        // Nettoyer les notifications associées
        _notificationProvider.removeConversationNotifications(conversationId);
      }
      
      return success;
    } catch (e) {
      _setError('Erreur lors de la suppression de la conversation: $e');
      return false;
    }
  }

  /// Marque tous les messages d'une conversation comme lus
  Future<void> markConversationAsRead(int conversationId) async {
    try {
      await _conversationProvider.markConversationAsRead(conversationId);
      await _notificationProvider.markConversationNotificationsAsRead(conversationId);
    } catch (e) {
      print('Error marking conversation as read: $e');
    }
  }

  /// Charge plus de messages pour la conversation courante
  Future<void> loadMoreMessages() async {
    final conversation = currentConversation;
    if (conversation == null) return;

    try {
      await _messageProvider.loadMoreMessages(conversation.id);
    } catch (e) {
      _setError('Erreur lors du chargement des messages: $e');
    }
  }

  /// Charge plus de conversations
  Future<void> loadMoreConversations() async {
    try {
      await _conversationProvider.loadMoreConversations();
    } catch (e) {
      _setError('Erreur lors du chargement des conversations: $e');
    }
  }

  /// Recherche dans les conversations
  Future<List<Conversation>> searchConversations(String query) async {
    try {
      _clearError();
      return await _conversationProvider.searchConversations(query);
    } catch (e) {
      _setError('Erreur lors de la recherche: $e');
      return [];
    }
  }

  /// Recherche dans les messages
  Future<List<Message>> searchMessages({
    required String query,
    int? conversationId,
  }) async {
    try {
      _clearError();
      return await _messageProvider.searchMessages(
        query: query,
        conversationId: conversationId,
      );
    } catch (e) {
      _setError('Erreur lors de la recherche: $e');
      return [];
    }
  }

  /// Rafraîchit toutes les données
  Future<void> refreshAll() async {
    try {
      _clearError();
      
      await Future.wait([
        _conversationProvider.refresh(),
        _notificationProvider.refreshNotifications(),
      ]);
      
      // Recharger les messages de la conversation courante
      final conversation = currentConversation;
      if (conversation != null) {
        await _messageProvider.loadMessages(conversation.id, refresh: true);
      }
    } catch (e) {
      _setError('Erreur lors du rafraîchissement: $e');
    }
  }

  /// Gère la réception d'un nouveau message (ex: via WebSocket)
  void handleReceivedMessage(Message message) {
    try {
      // Ajouter le message
      _messageProvider.addReceivedMessage(message);
      
      // Mettre à jour la conversation
      _conversationProvider.updateLastMessage(message.conversationId, message);
      
      // Mettre à jour le compteur de non lus si ce n'est pas la conversation courante
      if (currentConversation?.id != message.conversationId) {
        _conversationProvider.updateUnreadCount(
          message.conversationId,
          _conversationProvider.conversations
              .firstWhere((conv) => conv.id == message.conversationId)
              .unreadMessagesCount + 1,
        );
      }
    } catch (e) {
      print('Error handling received message: $e');
    }
  }

  /// Gère la mise à jour du statut d'un message
  void handleMessageStatusUpdate(String messageId, MessageStatus status) {
    try {
      // Trouver et mettre à jour le message
      // Cette logique pourrait être améliorée avec une map de lookup
      for (final conversation in _conversationProvider.conversations) {
        final messages = _messageProvider.getMessages(conversation.id);
        final messageIndex = messages.indexWhere((msg) => msg.id == messageId);
        
        if (messageIndex != -1) {
          final updatedMessage = messages[messageIndex].copyWith(status: status);
          _messageProvider.updateMessage(updatedMessage);
          break;
        }
      }
    } catch (e) {
      print('Error handling message status update: $e');
    }
  }

  /// Met à jour l'état du cycle de vie de l'application
  void updateAppLifecycleState(AppLifecycleState state) {
    _notificationProvider.updateAppLifecycleState(state);
  }

  // ========== Méthodes privées ==========

  void _initialize() {
    // Écouter les changements des providers
    _conversationProvider.addListener(() => notifyListeners());
    _messageProvider.addListener(() => notifyListeners());
    _notificationProvider.addListener(() => notifyListeners());
    _chatMediaProvider.addListener(() => notifyListeners());
  }

  void _setError(String error) {
    _currentError = error;
    notifyListeners();
  }

  void _clearError() {
    _currentError = null;
  }

  @override
  void dispose() {
    _conversationProvider.removeListener(() => notifyListeners());
    _messageProvider.removeListener(() => notifyListeners());
    _notificationProvider.removeListener(() => notifyListeners());
    _chatMediaProvider.removeListener(() => notifyListeners());
    
    shutdown();
    super.dispose();
  }
}
