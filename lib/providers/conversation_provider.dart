import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/conversation_service.dart';
import '../services/messaging_service_locator.dart';

/// Provider pour la gestion des conversations
class ConversationProvider extends ChangeNotifier {
  final ConversationService _conversationService;
  
  // État des conversations
  Map<int, Conversation> _conversations = {};
  List<int> _conversationIds = [];
  bool _isLoading = false;
  bool _hasMoreConversations = true;
  String? _error;
  int _currentPage = 1;
  static const int _pageSize = 20;

  // Conversation actuellement sélectionnée
  Conversation? _currentConversation;
  
  // Cache des statistiques
  ConversationStats? _stats;
  DateTime? _lastStatsUpdate;

  ConversationProvider({ConversationService? conversationService})
      : _conversationService = conversationService ?? ConversationService();

  // ========== Getters ==========

  /// Liste des conversations triées par dernière activité
  List<Conversation> get conversations {
    return _conversationIds
        .map((id) => _conversations[id])
        .where((conv) => conv != null)
        .cast<Conversation>()
        .toList();
  }

  /// Conversation actuellement sélectionnée
  Conversation? get currentConversation => _currentConversation;

  /// État de chargement
  bool get isLoading => _isLoading;

  /// Indique s'il y a plus de conversations à charger
  bool get hasMoreConversations => _hasMoreConversations;

  /// Dernière erreur
  String? get error => _error;

  /// Statistiques des conversations
  ConversationStats? get stats => _stats;

  /// Nombre total de conversations
  int get conversationCount => _conversations.length;

  /// Nombre de conversations non lues
  int get unreadCount {
    return _conversations.values
        .where((conv) => conv.unreadMessagesCount > 0)
        .length;
  }

  // ========== Méthodes publiques ==========

  /// Charge les conversations (page initiale)
  Future<void> loadConversations({bool refresh = false}) async {
    if (_isLoading && !refresh) return;

    try {
      _setLoading(true);
      _clearError();

      if (refresh) {
        _conversations.clear();
        _conversationIds.clear();
        _currentPage = 1;
        _hasMoreConversations = true;
      }

      final result = await _conversationService.getConversations(
        page: _currentPage,
        limit: _pageSize,
      );

      if (result['success'] == true) {
        final List<dynamic> conversationsData = result['conversations'] ?? [];
        final List<Conversation> newConversations = conversationsData
            .map((data) => Conversation.fromJson(data))
            .toList();

        // Mise à jour du cache
        for (final conv in newConversations) {
          _conversations[conv.id] = conv;
        }

        // Mise à jour de l'ordre (par dernière activité)
        _updateConversationOrder();

        // Vérifier s'il y a plus de conversations
        _hasMoreConversations = newConversations.length == _pageSize;
        
        if (_hasMoreConversations) {
          _currentPage++;
        }
      } else {
        _setError(result['message'] ?? 'Erreur lors du chargement des conversations');
      }
    } catch (e) {
      _setError('Erreur technique: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Charge plus de conversations (pagination)
  Future<void> loadMoreConversations() async {
    if (_isLoading || !_hasMoreConversations) return;

    try {
      _setLoading(true);
      _clearError();

      final result = await _conversationService.getConversations(
        page: _currentPage,
        limit: _pageSize,
      );

      if (result['success'] == true) {
        final List<dynamic> conversationsData = result['conversations'] ?? [];
        final List<Conversation> newConversations = conversationsData
            .map((data) => Conversation.fromJson(data))
            .toList();

        // Ajouter les nouvelles conversations
        for (final conv in newConversations) {
          if (!_conversations.containsKey(conv.id)) {
            _conversations[conv.id] = conv;
          }
        }

        // Mise à jour de l'ordre
        _updateConversationOrder();

        // Vérifier s'il y a plus de conversations
        _hasMoreConversations = newConversations.length == _pageSize;
        
        if (_hasMoreConversations) {
          _currentPage++;
        }
      } else {
        _setError(result['message'] ?? 'Erreur lors du chargement');
      }
    } catch (e) {
      _setError('Erreur technique: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Sélectionne une conversation
  Future<void> selectConversation(int conversationId) async {
    final conversation = _conversations[conversationId];
    if (conversation != null) {
      _currentConversation = conversation;
      
      // Marquer comme lue si nécessaire
      if (conversation.unreadMessagesCount > 0) {
        await markConversationAsRead(conversationId);
      }
      
      notifyListeners();
    }
  }

  /// Crée ou récupère une conversation avec un utilisateur
  Future<Conversation?> createOrGetConversation(int participantId) async {
    try {
      _clearError();

      final result = await _conversationService.createOrGetConversation(participantId);

      if (result['success'] == true) {
        final conversationData = result['conversation'];
        final conversation = Conversation.fromJson(conversationData);
        
        // Mettre à jour le cache
        _conversations[conversation.id] = conversation;
        _updateConversationOrder();
        
        notifyListeners();
        return conversation;
      } else {
        _setError(result['message'] ?? 'Erreur lors de la création de la conversation');
        return null;
      }
    } catch (e) {
      _setError('Erreur technique: $e');
      return null;
    }
  }

  /// Marque une conversation comme lue
  Future<void> markConversationAsRead(int conversationId) async {
    try {
      final result = await _conversationService.markAsRead(conversationId);

      if (result['success'] == true) {
        // Mettre à jour localement
        final conversation = _conversations[conversationId];
        if (conversation != null) {
          _conversations[conversationId] = conversation.copyWith(
            unreadMessagesCount: 0,
          );
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error marking conversation as read: $e');
    }
  }

  /// Supprime une conversation
  Future<bool> deleteConversation(int conversationId) async {
    try {
      _clearError();

      final result = await _conversationService.deleteConversation(conversationId);

      if (result['success'] == true) {
        // Supprimer du cache
        _conversations.remove(conversationId);
        _conversationIds.remove(conversationId);
        
        // Si c'était la conversation courante, la désélectionner
        if (_currentConversation?.id == conversationId) {
          _currentConversation = null;
        }
        
        notifyListeners();
        return true;
      } else {
        _setError(result['message'] ?? 'Erreur lors de la suppression');
        return false;
      }
    } catch (e) {
      _setError('Erreur technique: $e');
      return false;
    }
  }

  /// Recherche dans les conversations
  Future<List<Conversation>> searchConversations(String query) async {
    if (query.isEmpty) return conversations;

    try {
      _clearError();

      final result = await _conversationService.searchConversations(query);

      if (result['success'] == true) {
        final List<dynamic> conversationsData = result['conversations'] ?? [];
        return conversationsData
            .map((data) => Conversation.fromJson(data))
            .toList();
      } else {
        _setError(result['message'] ?? 'Erreur lors de la recherche');
        return [];
      }
    } catch (e) {
      _setError('Erreur technique: $e');
      return [];
    }
  }

  /// Charge les statistiques des conversations
  Future<void> loadStats({bool forceRefresh = false}) async {
    // Utiliser le cache si disponible et récent (< 5 minutes)
    if (!forceRefresh && 
        _stats != null && 
        _lastStatsUpdate != null &&
        DateTime.now().difference(_lastStatsUpdate!).inMinutes < 5) {
      return;
    }

    try {
      final result = await _conversationService.getConversationStats();

      if (result['success'] == true) {
        _stats = ConversationStats.fromJson(result['stats']);
        _lastStatsUpdate = DateTime.now();
        notifyListeners();
      }
    } catch (e) {
      print('Error loading conversation stats: $e');
    }
  }

  /// Met à jour une conversation dans le cache
  void updateConversation(Conversation conversation) {
    _conversations[conversation.id] = conversation;
    _updateConversationOrder();
    notifyListeners();
  }

  /// Met à jour le nombre de messages non lus d'une conversation
  void updateUnreadCount(int conversationId, int unreadCount) {
    final conversation = _conversations[conversationId];
    if (conversation != null) {
      _conversations[conversationId] = conversation.copyWith(
        unreadMessagesCount: unreadCount,
      );
      notifyListeners();
    }
  }

  /// Met à jour le dernier message d'une conversation
  void updateLastMessage(int conversationId, Message lastMessage) {
    final conversation = _conversations[conversationId];
    if (conversation != null) {
      _conversations[conversationId] = conversation.copyWith(
        lastMessage: lastMessage,
        lastActivity: lastMessage.createdAt,
      );
      _updateConversationOrder();
      notifyListeners();
    }
  }

  /// Rafraîchit toutes les données
  Future<void> refresh() async {
    await Future.wait([
      loadConversations(refresh: true),
      loadStats(forceRefresh: true),
    ]);
  }

  /// Efface le cache et recharge
  Future<void> clearAndReload() async {
    _conversations.clear();
    _conversationIds.clear();
    _currentConversation = null;
    _stats = null;
    _lastStatsUpdate = null;
    _currentPage = 1;
    _hasMoreConversations = true;
    
    await loadConversations();
  }

  // ========== Méthodes privées ==========

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  /// Met à jour l'ordre des conversations par dernière activité
  void _updateConversationOrder() {
    final conversationsList = _conversations.values.toList();
    conversationsList.sort((a, b) => b.lastActivity.compareTo(a.lastActivity));
    _conversationIds = conversationsList.map((conv) => conv.id).toList();
  }

  @override
  void dispose() {
    // Nettoyage si nécessaire
    super.dispose();
  }
}
