/// Configuration centralisée pour les services de messagerie
class MessagingConfig {
  // ========== Endpoints API ==========
  
  static const String messagesEndpoint = '/messages';
  static const String conversationsEndpoint = '/conversations';
  static const String uploadEndpoint = '/upload/chat-media';
  static const String mediaEndpoint = '/media';
  
  // ========== Polling Configuration ==========
  
  /// Intervalle de polling quand l'app est active
  static const Duration pollingIntervalActive = Duration(seconds: 5);
  
  /// Intervalle de polling quand l'app est en arrière-plan
  static const Duration pollingIntervalBackground = Duration(seconds: 30);
  
  /// Intervalle de polling quand l'app est inactive
  static const Duration pollingIntervalInactive = Duration(minutes: 5);
  
  // ========== Pagination ==========
  
  static const int defaultMessagesPerPage = 50;
  static const int defaultConversationsPerPage = 20;
  static const int maxMessagesPerPage = 100;
  static const int maxConversationsPerPage = 50;
  
  // ========== Cache Configuration ==========
  
  static const Duration cacheExpiration = Duration(minutes: 5);
  static const int maxCachedConversations = 100;
  static const int maxCachedMessages = 1000;
  
  // ========== Upload Configuration ==========
  
  static const int maxRetryAttempts = 3;
  static const Duration uploadTimeout = Duration(minutes: 2);
  static const Duration requestTimeout = Duration(seconds: 30);
  
  // ========== Features Flags ==========
  
  /// Active/désactive le chiffrement des messages
  static const bool enableMessageEncryption = false;
  
  /// Active/désactive le mode hors ligne
  static const bool enableOfflineMode = true;
  
  /// Active/désactive la recherche dans les messages
  static const bool enableMessageSearch = true;
  
  /// Active/désactive les réactions aux messages
  static const bool enableMessageReactions = false;
  
  /// Active/désactive la compression automatique des images
  static const bool enableImageCompression = true;
  
  /// Active/désactive les notifications push
  static const bool enablePushNotifications = true;
  
  // ========== Error Messages ==========
  
  static const Map<String, String> errorMessages = {
    'network_error': 'Erreur de connexion réseau',
    'timeout_error': 'Délai d\'attente dépassé',
    'upload_error': 'Erreur lors de l\'upload',
    'validation_error': 'Données invalides',
    'auth_error': 'Erreur d\'authentification',
    'permission_error': 'Permissions insuffisantes',
    'file_too_large': 'Fichier trop volumineux',
    'file_type_not_supported': 'Type de fichier non supporté',
    'conversation_not_found': 'Conversation introuvable',
    'message_not_found': 'Message introuvable',
    'user_blocked': 'Utilisateur bloqué',
    'unknown_error': 'Erreur inconnue',
  };
  
  // ========== Success Messages ==========
  
  static const Map<String, String> successMessages = {
    'message_sent': 'Message envoyé',
    'message_deleted': 'Message supprimé',
    'conversation_created': 'Conversation créée',
    'conversation_deleted': 'Conversation supprimée',
    'user_blocked': 'Utilisateur bloqué',
    'user_unblocked': 'Utilisateur débloqué',
    'media_uploaded': 'Média téléchargé',
  };
  
  // ========== Helper Methods ==========
  
  /// Récupère un message d'erreur localisé
  static String getErrorMessage(String errorType) {
    return errorMessages[errorType] ?? errorMessages['unknown_error']!;
  }
  
  /// Récupère un message de succès localisé
  static String getSuccessMessage(String successType) {
    return successMessages[successType] ?? 'Opération réussie';
  }
  
  /// Détermine l'intervalle de polling selon l'état de l'app
  static Duration getPollingInterval(AppState appState) {
    switch (appState) {
      case AppState.active:
        return pollingIntervalActive;
      case AppState.background:
        return pollingIntervalBackground;
      case AppState.inactive:
        return pollingIntervalInactive;
    }
  }
  
  /// Vérifie si une fonctionnalité est activée
  static bool isFeatureEnabled(String feature) {
    switch (feature) {
      case 'encryption':
        return enableMessageEncryption;
      case 'offline_mode':
        return enableOfflineMode;
      case 'search':
        return enableMessageSearch;
      case 'reactions':
        return enableMessageReactions;
      case 'image_compression':
        return enableImageCompression;
      case 'push_notifications':
        return enablePushNotifications;
      default:
        return false;
    }
  }
  
  /// Valide les paramètres de pagination
  static Map<String, int> validatePagination({int? page, int? limit, bool isMessages = false}) {
    final validPage = (page != null && page > 0) ? page : 1;
    final maxLimit = isMessages ? maxMessagesPerPage : maxConversationsPerPage;
    final defaultLimit = isMessages ? defaultMessagesPerPage : defaultConversationsPerPage;
    final validLimit = (limit != null && limit > 0 && limit <= maxLimit) ? limit : defaultLimit;
    
    return {
      'page': validPage,
      'limit': validLimit,
    };
  }
}

/// États possibles de l'application
enum AppState { 
  active,      // App au premier plan, utilisateur actif
  background,  // App en arrière-plan mais processus actif
  inactive     // App complètement inactive
}

/// Niveaux de log pour debug
enum LogLevel { 
  debug, 
  info, 
  warning, 
  error 
}

/// Configuration de debug
class MessagingDebugConfig {
  static const bool enableDetailedLogs = true;
  static const LogLevel logLevel = LogLevel.debug;
  static const bool logApiCalls = true;
  static const bool logPollingActivity = false;
  static const bool logStreamEvents = false;
  
  static void log(String message, {LogLevel level = LogLevel.info}) {
    if (!enableDetailedLogs) return;
    
    if (level.index >= logLevel.index) {
      final timestamp = DateTime.now().toIso8601String();
      final levelStr = level.toString().split('.').last.toUpperCase();
      print('[$timestamp] [$levelStr] MESSAGING: $message');
    }
  }
}
