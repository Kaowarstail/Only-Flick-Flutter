import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/messaging_service.dart';

class MessagingProvider with ChangeNotifier {
  final MessagingService _messagingService;
  
  MessagingProvider(this._messagingService);
  
  // État des conversations
  List<Conversation> _conversations = [];
  bool _isLoadingConversations = false;
  String? _conversationsError;
  
  // État des messages
  Map<String, List<Message>> _conversationMessages = {};
  bool _isLoadingMessages = false;
  String? _messagesError;
  
  // Conversation actuelle
  Conversation? _currentConversation;
  
  // Getters
  List<Conversation> get conversations => _conversations;
  bool get isLoadingConversations => _isLoadingConversations;
  String? get conversationsError => _conversationsError;
  
  List<Message> get currentMessages => 
      _currentConversation != null 
          ? _conversationMessages[_currentConversation!.id] ?? []
          : [];
  bool get isLoadingMessages => _isLoadingMessages;
  String? get messagesError => _messagesError;
  
  Conversation? get currentConversation => _currentConversation;
  
  // Nombre total de messages non lus
  int get totalUnreadCount => 
      _conversations.fold(0, (sum, conv) => sum + conv.unreadCount);

  // Charger les conversations
  Future<void> loadConversations({int page = 1, int limit = 20}) async {
    if (page == 1) {
      _isLoadingConversations = true;
      _conversationsError = null;
      notifyListeners();
    }
    
    try {
      final response = await _messagingService.getUserConversations(
        page: page,
        limit: limit,
      );
      
      if (page == 1) {
        _conversations = response.conversations;
      } else {
        _conversations.addAll(response.conversations);
      }
      
      _conversationsError = null;
    } catch (e) {
      _conversationsError = e.toString();
      if (kDebugMode) {
        print('Erreur lors du chargement des conversations: $e');
      }
    } finally {
      _isLoadingConversations = false;
      notifyListeners();
    }
  }

  // Créer ou récupérer une conversation
  Future<Conversation?> createConversation(String otherUserId) async {
    try {
      final conversation = await _messagingService.createConversation(otherUserId);
      
      // Ajouter à la liste si pas déjà présente
      final existingIndex = _conversations.indexWhere((c) => c.id == conversation.id);
      if (existingIndex >= 0) {
        _conversations[existingIndex] = conversation;
      } else {
        _conversations.insert(0, conversation);
      }
      
      notifyListeners();
      return conversation;
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la création de la conversation: $e');
      }
      return null;
    }
  }

  // Sélectionner une conversation
  void setCurrentConversation(Conversation conversation) {
    _currentConversation = conversation;
    notifyListeners();
    
    // Charger les messages si pas déjà chargés
    if (!_conversationMessages.containsKey(conversation.id)) {
      loadMessages(conversation.id);
    }
  }

  // Charger les messages d'une conversation
  Future<void> loadMessages(String conversationId, {int page = 1, int limit = 50}) async {
    if (page == 1) {
      _isLoadingMessages = true;
      _messagesError = null;
      notifyListeners();
    }
    
    try {
      final response = await _messagingService.getConversationMessages(
        conversationId,
        page: page,
        limit: limit,
      );
      
      if (page == 1) {
        _conversationMessages[conversationId] = response.messages;
      } else {
        _conversationMessages[conversationId] = [
          ..._conversationMessages[conversationId] ?? [],
          ...response.messages,
        ];
      }
      
      _messagesError = null;
    } catch (e) {
      _messagesError = e.toString();
      if (kDebugMode) {
        print('Erreur lors du chargement des messages: $e');
      }
    } finally {
      _isLoadingMessages = false;
      notifyListeners();
    }
  }

  // Envoyer un message
  Future<bool> sendMessage(SendMessageRequest request) async {
    try {
      final message = await _messagingService.sendMessage(request);
      
      // Ajouter le message à la liste locale
      final conversationId = request.conversationId;
      if (_conversationMessages.containsKey(conversationId)) {
        _conversationMessages[conversationId]!.add(message);
      } else {
        _conversationMessages[conversationId] = [message];
      }
      
      // Mettre à jour la conversation
      final convIndex = _conversations.indexWhere((c) => c.id == conversationId);
      if (convIndex >= 0) {
        _conversations[convIndex] = _conversations[convIndex].updateWithNewMessage(message);
        
        // Déplacer la conversation en haut de la liste
        final updatedConv = _conversations.removeAt(convIndex);
        _conversations.insert(0, updatedConv);
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de l\'envoi du message: $e');
      }
      return false;
    }
  }

  // Marquer une conversation comme lue
  Future<void> markConversationAsRead(String conversationId) async {
    try {
      await _messagingService.markConversationAsRead(conversationId);
      
      // Mettre à jour localement
      final convIndex = _conversations.indexWhere((c) => c.id == conversationId);
      if (convIndex >= 0) {
        _conversations[convIndex] = _conversations[convIndex].markAsRead();
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors du marquage comme lu: $e');
      }
    }
  }

  // Rafraîchir les données
  Future<void> refresh() async {
    await loadConversations();
    if (_currentConversation != null) {
      await loadMessages(_currentConversation!.id);
    }
  }

  // Nettoyer les ressources
  void clear() {
    _conversations.clear();
    _conversationMessages.clear();
    _currentConversation = null;
    _isLoadingConversations = false;
    _isLoadingMessages = false;
    _conversationsError = null;
    _messagesError = null;
    notifyListeners();
  }

  // Méthode pour récupérer les messages d'une conversation spécifique
  List<Message> getCurrentMessages(String conversationId) {
    return _conversationMessages[conversationId] ?? [];
  }
  
  // Méthode pour vérifier si on charge des données (conversations ou messages)
  bool get isLoading => _isLoadingConversations || _isLoadingMessages;
  
  // Méthode pour récupérer l'erreur courante
  String? get error => _conversationsError ?? _messagesError;
}
