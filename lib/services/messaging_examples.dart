import 'dart:io';
import '../models/models.dart';
import '../services/services.dart';

/// Exemple d'utilisation des services de messagerie OnlyFlick
class MessagingExample {
  
  /// Exemple complet d'envoi de message avec média
  static Future<void> exampleSendMessageWithMedia() async {
    try {
      // 1. Démarrer les services
      messagingServices.startServices();
      
      // 2. Créer ou récupérer une conversation
      final conversation = await ConversationService.createOrGetConversation('user_123');
      if (conversation == null) {
        print('❌ Impossible de créer la conversation');
        return;
      }
      
      // 3. Upload d'un média (exemple avec image)
      final imageFile = File('/path/to/image.jpg');
      if (await imageFile.exists()) {
        final uploadResult = await MediaService.uploadMedia(
          file: imageFile,
          mediaType: MediaType.image,
          onProgress: (progress) {
            print('📤 Upload progress: ${(progress * 100).toInt()}%');
          },
        );
        
        if (uploadResult.success) {
          // 4. Envoyer le message avec le média
          final messageRequest = SendMessageRequest(
            conversationId: conversation.id,
            content: 'Voici une image !',
            mediaUrl: uploadResult.mediaUrl,
            mediaType: uploadResult.mimeType,
            messageType: MessageType.image,
          );
          
          final message = await MessageService.sendMessage(messageRequest);
          if (message != null) {
            print('✅ Message envoyé: ${message.id}');
          }
        } else {
          print('❌ Erreur upload: ${uploadResult.error}');
        }
      }
      
    } catch (e) {
      print('❌ Erreur: $e');
    }
  }
  
  /// Exemple de récupération des conversations avec pagination
  static Future<void> exampleGetConversations() async {
    try {
      int page = 1;
      bool hasMore = true;
      
      while (hasMore) {
        final response = await ConversationService.getConversations(
          page: page,
          limit: 20,
        );
        
        if (response != null) {
          print('📄 Page $page: ${response.conversations.length} conversations');
          
          for (final conversation in response.conversations) {
            print('💬 ${conversation.getDisplayTitle("current_user_id")}');
            if (conversation.lastMessage != null) {
              print('   📝 ${conversation.lastMessage!.shortDisplayContent}');
            }
            print('   🔔 ${conversation.unreadCount} non lus');
          }
          
          hasMore = response.hasMore;
          page++;
        } else {
          hasMore = false;
        }
      }
      
    } catch (e) {
      print('❌ Erreur: $e');
    }
  }
  
  /// Exemple d'écoute des notifications en temps réel
  static void exampleListenToNotifications() {
    // Écouter le nombre de messages non lus
    messagingServices.unreadCountStream.listen((unreadCount) {
      print('🔔 Messages non lus: $unreadCount');
      // Mettre à jour l'UI
    });
    
    // Écouter les mises à jour de conversations
    messagingServices.conversationsStream.listen((conversations) {
      print('📱 ${conversations.length} conversations mises à jour');
      // Rafraîchir la liste des conversations
    });
  }
  
  /// Exemple de gestion de l'état de l'app
  static void exampleAppStateManagement() {
    // Quand l'app devient active
    messagingServices.setAppState(true);
    
    // Quand l'app va en arrière-plan
    messagingServices.setAppState(false);
    
    // Forcer une vérification
    messagingServices.checkNotifications();
  }
  
  /// Exemple de recherche dans les conversations
  static Future<void> exampleSearchConversations() async {
    try {
      final results = await ConversationService.searchConversations(
        query: 'Alice',
        page: 1,
        limit: 10,
      );
      
      print('🔍 ${results.length} conversations trouvées');
      for (final conversation in results) {
        print('💬 ${conversation.getDisplayTitle("current_user_id")}');
      }
      
    } catch (e) {
      print('❌ Erreur de recherche: $e');
    }
  }
  
  /// Exemple de validation de fichier avant upload
  static Future<void> exampleValidateFile() async {
    final file = File('/path/to/video.mp4');
    
    if (await MediaService.canUploadFile(file, MediaType.video)) {
      print('✅ Fichier valide pour upload');
      
      final mediaInfo = await MediaService.getMediaInfo(file);
      print('📋 Infos fichier:');
      print('   📁 Nom: ${mediaInfo.name}');
      print('   📏 Taille: ${mediaInfo.formattedSize}');
      print('   🔖 Extension: ${mediaInfo.extension}');
    } else {
      print('❌ Fichier invalide pour upload');
    }
  }
  
  /// Exemple de gestion d'erreurs avec retry
  static Future<Message?> exampleSendMessageWithRetry(SendMessageRequest request) async {
    int attempts = 0;
    const maxAttempts = 3;
    
    while (attempts < maxAttempts) {
      try {
        final message = await MessageService.sendMessage(request);
        print('✅ Message envoyé après ${attempts + 1} tentative(s)');
        return message;
      } catch (e) {
        attempts++;
        print('❌ Tentative $attempts échouée: $e');
        
        if (attempts < maxAttempts) {
          print('🔄 Nouvelle tentative dans 2 secondes...');
          await Future.delayed(Duration(seconds: 2));
        }
      }
    }
    
    print('❌ Échec après $maxAttempts tentatives');
    return null;
  }
  
  /// Exemple de nettoyage lors de la déconnexion
  static void exampleCleanupOnLogout() {
    // Arrêter tous les services
    messagingServices.stopServices();
    
    // Reset pour nouveau user
    messagingServices.reset();
    
    print('🧹 Services nettoyés');
  }
}

/// Helper pour démarrer rapidement la messagerie
class MessagingQuickStart {
  
  /// Initialise la messagerie pour un utilisateur
  static Future<void> initialize() async {
    try {
      // Démarrer les services
      messagingServices.startServices();
      
      // Vérifier immédiatement les notifications
      await messagingServices.checkNotifications();
      
      print('🚀 Messagerie initialisée');
    } catch (e) {
      print('❌ Erreur initialisation: $e');
    }
  }
  
  /// Configure les listeners essentiels
  static void setupListeners({
    required Function(int) onUnreadCountChanged,
    required Function(List<dynamic>) onConversationsUpdated,
  }) {
    messagingServices.unreadCountStream.listen(onUnreadCountChanged);
    messagingServices.conversationsStream.listen(onConversationsUpdated);
  }
  
  /// Envoi rapide d'un message texte
  static Future<bool> sendQuickMessage(String conversationId, String content) async {
    try {
      final request = SendMessageRequest(
        conversationId: conversationId,
        content: content,
        messageType: MessageType.text,
      );
      
      final message = await MessageService.sendMessage(request);
      return message != null;
    } catch (e) {
      print('❌ Erreur envoi rapide: $e');
      return false;
    }
  }
}
