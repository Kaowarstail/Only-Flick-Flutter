import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/message_service.dart';
import '../services/messaging_service_locator.dart';

/// Provider pour la gestion des messages
class MessageProvider extends ChangeNotifier {
  final MessageService _messageService;
  
  // État des messages par conversation
  final Map<int, List<Message>> _messagesByConversation = {};
  final Map<int, bool> _loadingStates = {};
  final Map<int, bool> _hasMoreMessages = {};
  final Map<int, int> _currentPages = {};
  final Map<int, String?> _errors = {};
  
  // Messages en cours d'envoi (optimistic updates)
  final Map<String, Message> _sendingMessages = {};
  
  // Messages en échec
  final Map<String, Message> _failedMessages = {};
  
  // Configuration de pagination
  static const int _pageSize = 50;
  
  // Timers pour retry automatique
  final Map<String, Timer> _retryTimers = {};

  MessageProvider({MessageService? messageService})
      : _messageService = messageService ?? MessageService();

  // ========== Getters ==========

  /// Messages d'une conversation spécifique
  List<Message> getMessages(int conversationId) {
    final messages = _messagesByConversation[conversationId] ?? [];
    final sendingMessages = _sendingMessages.values
        .where((msg) => msg.conversationId == conversationId)
        .toList();
    final failedMessages = _failedMessages.values
        .where((msg) => msg.conversationId == conversationId)
        .toList();
    
    // Combiner et trier par date de création
    final allMessages = [...messages, ...sendingMessages, ...failedMessages];
    allMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    
    return allMessages;
  }

  /// État de chargement pour une conversation
  bool isLoading(int conversationId) {
    return _loadingStates[conversationId] ?? false;
  }

  /// Indique s'il y a plus de messages à charger
  bool hasMoreMessages(int conversationId) {
    return _hasMoreMessages[conversationId] ?? true;
  }

  /// Dernière erreur pour une conversation
  String? getError(int conversationId) {
    return _errors[conversationId];
  }

  /// Messages en cours d'envoi
  List<Message> get sendingMessages => _sendingMessages.values.toList();

  /// Messages en échec
  List<Message> get failedMessages => _failedMessages.values.toList();

  /// Nombre total de messages en mémoire
  int get totalMessagesCount {
    return _messagesByConversation.values
        .fold(0, (sum, messages) => sum + messages.length);
  }

  // ========== Méthodes publiques ==========

  /// Charge les messages d'une conversation
  Future<void> loadMessages(int conversationId, {bool refresh = false}) async {
    if (isLoading(conversationId) && !refresh) return;

    try {
      _setLoading(conversationId, true);
      _clearError(conversationId);

      if (refresh) {
        _messagesByConversation[conversationId] = [];
        _currentPages[conversationId] = 1;
        _hasMoreMessages[conversationId] = true;
      }

      final page = _currentPages[conversationId] ?? 1;
      final result = await _messageService.getMessages(
        conversationId: conversationId,
        page: page,
        limit: _pageSize,
      );

      if (result['success'] == true) {
        final List<dynamic> messagesData = result['messages'] ?? [];
        final List<Message> newMessages = messagesData
            .map((data) => Message.fromJson(data))
            .toList();

        // Mise à jour du cache
        if (refresh) {
          _messagesByConversation[conversationId] = newMessages;
        } else {
          final existingMessages = _messagesByConversation[conversationId] ?? [];
          _messagesByConversation[conversationId] = [...existingMessages, ...newMessages];
        }

        // Vérifier s'il y a plus de messages
        _hasMoreMessages[conversationId] = newMessages.length == _pageSize;
        
        if (_hasMoreMessages[conversationId] == true) {
          _currentPages[conversationId] = page + 1;
        }
      } else {
        _setError(conversationId, result['message'] ?? 'Erreur lors du chargement des messages');
      }
    } catch (e) {
      _setError(conversationId, 'Erreur technique: $e');
    } finally {
      _setLoading(conversationId, false);
    }
  }

  /// Charge plus de messages (pagination)
  Future<void> loadMoreMessages(int conversationId) async {
    if (isLoading(conversationId) || !hasMoreMessages(conversationId)) return;

    await loadMessages(conversationId);
  }

  /// Envoie un message avec optimistic update
  Future<Message?> sendMessage({
    required int conversationId,
    required String content,
    List<String>? mediaUrls,
    Message? replyTo,
  }) async {
    // Créer un message temporaire pour l'optimistic update
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final tempMessage = Message(
      id: tempId,
      conversationId: conversationId,
      senderId: 0, // Sera mis à jour avec l'ID de l'utilisateur connecté
      content: content,
      mediaUrls: mediaUrls ?? [],
      replyToMessageId: replyTo?.id,
      replyToMessage: replyTo,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      status: MessageStatus.sending,
    );

    try {
      // Ajouter le message en cours d'envoi
      _sendingMessages[tempId] = tempMessage;
      notifyListeners();

      // Envoyer le message
      final result = await _messageService.sendMessage(
        conversationId: conversationId,
        content: content,
        mediaUrls: mediaUrls,
        replyToMessageId: replyTo?.id,
      );

      // Supprimer de la liste d'envoi
      _sendingMessages.remove(tempId);

      if (result['success'] == true) {
        final messageData = result['message'];
        final sentMessage = Message.fromJson(messageData);
        
        // Ajouter le message envoyé à la conversation
        final messages = _messagesByConversation[conversationId] ?? [];
        _messagesByConversation[conversationId] = [...messages, sentMessage];
        
        notifyListeners();
        return sentMessage;
      } else {
        // Marquer comme échec
        final failedMessage = tempMessage.copyWith(
          status: MessageStatus.failed,
        );
        _failedMessages[tempId] = failedMessage;
        
        // Programmer un retry automatique
        _scheduleRetry(tempId, conversationId, content, mediaUrls, replyTo);
        
        notifyListeners();
        return null;
      }
    } catch (e) {
      // Supprimer de la liste d'envoi et marquer comme échec
      _sendingMessages.remove(tempId);
      
      final failedMessage = tempMessage.copyWith(
        status: MessageStatus.failed,
      );
      _failedMessages[tempId] = failedMessage;
      
      // Programmer un retry automatique
      _scheduleRetry(tempId, conversationId, content, mediaUrls, replyTo);
      
      notifyListeners();
      return null;
    }
  }

  /// Réessaie d'envoyer un message en échec
  Future<void> retryMessage(String tempId) async {
    final failedMessage = _failedMessages[tempId];
    if (failedMessage == null) return;

    // Annuler le timer de retry automatique
    _retryTimers[tempId]?.cancel();
    _retryTimers.remove(tempId);

    // Supprimer de la liste des échecs et réessayer
    _failedMessages.remove(tempId);
    
    await sendMessage(
      conversationId: failedMessage.conversationId,
      content: failedMessage.content,
      mediaUrls: failedMessage.mediaUrls.isNotEmpty ? failedMessage.mediaUrls : null,
      replyTo: failedMessage.replyToMessage,
    );
  }

  /// Supprime un message en échec
  void removeFailedMessage(String tempId) {
    _retryTimers[tempId]?.cancel();
    _retryTimers.remove(tempId);
    _failedMessages.remove(tempId);
    notifyListeners();
  }

  /// Supprime un message
  Future<bool> deleteMessage(String messageId, int conversationId) async {
    try {
      _clearError(conversationId);

      final result = await _messageService.deleteMessage(messageId);

      if (result['success'] == true) {
        // Supprimer du cache
        final messages = _messagesByConversation[conversationId] ?? [];
        _messagesByConversation[conversationId] = messages
            .where((msg) => msg.id != messageId)
            .toList();
        
        notifyListeners();
        return true;
      } else {
        _setError(conversationId, result['message'] ?? 'Erreur lors de la suppression');
        return false;
      }
    } catch (e) {
      _setError(conversationId, 'Erreur technique: $e');
      return false;
    }
  }

  /// Modifie un message
  Future<bool> editMessage(String messageId, int conversationId, String newContent) async {
    try {
      _clearError(conversationId);

      final result = await _messageService.editMessage(messageId, newContent);

      if (result['success'] == true) {
        // Mettre à jour dans le cache
        final messages = _messagesByConversation[conversationId] ?? [];
        final messageIndex = messages.indexWhere((msg) => msg.id == messageId);
        
        if (messageIndex != -1) {
          final updatedMessage = messages[messageIndex].copyWith(
            content: newContent,
            updatedAt: DateTime.now(),
            isEdited: true,
          );
          messages[messageIndex] = updatedMessage;
          notifyListeners();
        }
        
        return true;
      } else {
        _setError(conversationId, result['message'] ?? 'Erreur lors de la modification');
        return false;
      }
    } catch (e) {
      _setError(conversationId, 'Erreur technique: $e');
      return false;
    }
  }

  /// Marque les messages comme lus
  Future<void> markMessagesAsRead(int conversationId, List<String> messageIds) async {
    try {
      final result = await _messageService.markAsRead(conversationId, messageIds);

      if (result['success'] == true) {
        // Mettre à jour localement
        final messages = _messagesByConversation[conversationId] ?? [];
        for (int i = 0; i < messages.length; i++) {
          if (messageIds.contains(messages[i].id)) {
            messages[i] = messages[i].copyWith(isRead: true);
          }
        }
        notifyListeners();
      }
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  /// Recherche dans les messages
  Future<List<Message>> searchMessages({
    required String query,
    int? conversationId,
  }) async {
    try {
      final result = await _messageService.searchMessages(
        query: query,
        conversationId: conversationId,
      );

      if (result['success'] == true) {
        final List<dynamic> messagesData = result['messages'] ?? [];
        return messagesData.map((data) => Message.fromJson(data)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error searching messages: $e');
      return [];
    }
  }

  /// Ajoute un nouveau message reçu (websocket/polling)
  void addReceivedMessage(Message message) {
    final conversationId = message.conversationId;
    final messages = _messagesByConversation[conversationId] ?? [];
    
    // Vérifier que le message n'existe pas déjà
    if (!messages.any((msg) => msg.id == message.id)) {
      _messagesByConversation[conversationId] = [...messages, message];
      notifyListeners();
    }
  }

  /// Met à jour un message existant
  void updateMessage(Message updatedMessage) {
    final conversationId = updatedMessage.conversationId;
    final messages = _messagesByConversation[conversationId] ?? [];
    final messageIndex = messages.indexWhere((msg) => msg.id == updatedMessage.id);
    
    if (messageIndex != -1) {
      messages[messageIndex] = updatedMessage;
      notifyListeners();
    }
  }

  /// Efface les messages d'une conversation
  void clearMessages(int conversationId) {
    _messagesByConversation[conversationId] = [];
    _loadingStates.remove(conversationId);
    _hasMoreMessages.remove(conversationId);
    _currentPages.remove(conversationId);
    _errors.remove(conversationId);
    notifyListeners();
  }

  /// Efface tout le cache
  void clearAllMessages() {
    _messagesByConversation.clear();
    _loadingStates.clear();
    _hasMoreMessages.clear();
    _currentPages.clear();
    _errors.clear();
    _sendingMessages.clear();
    _failedMessages.clear();
    
    // Annuler tous les timers
    for (final timer in _retryTimers.values) {
      timer.cancel();
    }
    _retryTimers.clear();
    
    notifyListeners();
  }

  // ========== Méthodes privées ==========

  void _setLoading(int conversationId, bool loading) {
    _loadingStates[conversationId] = loading;
    notifyListeners();
  }

  void _setError(int conversationId, String error) {
    _errors[conversationId] = error;
    notifyListeners();
  }

  void _clearError(int conversationId) {
    _errors.remove(conversationId);
  }

  /// Programme un retry automatique pour un message en échec
  void _scheduleRetry(
    String tempId,
    int conversationId,
    String content,
    List<String>? mediaUrls,
    Message? replyTo,
  ) {
    // Retry après 5 secondes
    _retryTimers[tempId] = Timer(const Duration(seconds: 5), () async {
      final failedMessage = _failedMessages[tempId];
      if (failedMessage != null) {
        await retryMessage(tempId);
      }
    });
  }

  @override
  void dispose() {
    // Annuler tous les timers
    for (final timer in _retryTimers.values) {
      timer.cancel();
    }
    _retryTimers.clear();
    super.dispose();
  }
}
