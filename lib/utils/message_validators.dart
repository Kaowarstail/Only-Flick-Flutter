import '../constants/message_constants.dart';
import '../models/dto/message_dto.dart';

class MessageValidators {
  static String? validateContent(String? content) {
    if (content == null || content.trim().isEmpty) {
      return null; // Content peut être vide si média présent
    }

    if (content.length > MessageConstants.maxContentLength) {
      return 'Message trop long (max ${MessageConstants.maxContentLength} caractères)';
    }

    // Validation contenu inapproprié basique
    if (_containsInappropriateContent(content)) {
      return 'Le message contient du contenu inapproprié';
    }

    return null;
  }

  static String? validateMediaUrl(String? mediaUrl, String? mediaType) {
    if (mediaUrl == null || mediaUrl.trim().isEmpty) {
      return null;
    }

    // Vérification URL basique
    final uri = Uri.tryParse(mediaUrl);
    if (uri == null || (!uri.hasScheme || (uri.scheme != 'http' && uri.scheme != 'https'))) {
      return 'URL du média invalide';
    }

    // Type requis si URL présente
    if (mediaType == null || mediaType.trim().isEmpty) {
      return 'Type de média requis';
    }

    // Vérifier type autorisé
    if (!MessageConstants.isAllowedMimeType(mediaType)) {
      return 'Type de média non supporté';
    }

    return null;
  }

  static String? validateSendMessageRequest(SendMessageRequest request) {
    final hasContent = request.content != null && request.content!.trim().isNotEmpty;
    final hasMedia = request.mediaUrl != null && request.mediaUrl!.trim().isNotEmpty;

    if (!hasContent && !hasMedia) {
      return 'Le message doit contenir du texte ou un média';
    }

    // Valider contenu
    final contentError = validateContent(request.content);
    if (contentError != null) return contentError;

    // Valider média
    final mediaError = validateMediaUrl(request.mediaUrl, request.mediaType);
    if (mediaError != null) return mediaError;

    // Valider conversation ID
    if (request.conversationId.trim().isEmpty) {
      return 'ID de conversation requis';
    }

    return null;
  }

  static String? validateConversationId(String? conversationId) {
    if (conversationId == null || conversationId.trim().isEmpty) {
      return 'ID de conversation requis';
    }
    return null;
  }

  static String? validateUserId(String? userId) {
    if (userId == null || userId.trim().isEmpty) {
      return 'ID utilisateur requis';
    }
    return null;
  }

  static String? validateFileSize(int? fileSizeBytes) {
    if (fileSizeBytes == null) return null;
    
    if (!MessageConstants.isValidFileSize(fileSizeBytes)) {
      return 'Fichier trop volumineux (max ${MessageConstants.maxMediaFileSizeMB} MB)';
    }
    
    return null;
  }

  static bool _containsInappropriateContent(String content) {
    // Liste basique de mots interdits (à personnaliser selon besoins)
    final forbiddenWords = <String>[
      // Ajouter mots inappropriés selon contexte
      'spam',
      'scam',
      // Autres mots à bannir...
    ];

    final contentLower = content.toLowerCase();
    return forbiddenWords.any((word) => contentLower.contains(word.toLowerCase()));
  }

  // Validation pour les URLs d'images
  static bool isValidImageUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    
    final path = uri.path.toLowerCase();
    return path.endsWith('.jpg') || 
           path.endsWith('.jpeg') || 
           path.endsWith('.png') || 
           path.endsWith('.gif') || 
           path.endsWith('.webp');
  }

  // Validation pour les URLs de vidéos
  static bool isValidVideoUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    
    final path = uri.path.toLowerCase();
    return path.endsWith('.mp4') || 
           path.endsWith('.webm') || 
           path.endsWith('.mov') || 
           path.endsWith('.avi');
  }

  // Validation pour les URLs d'audio
  static bool isValidAudioUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    
    final path = uri.path.toLowerCase();
    return path.endsWith('.mp3') || 
           path.endsWith('.wav') || 
           path.endsWith('.ogg') || 
           path.endsWith('.m4a');
  }

  // Validation complète d'un message avant envoi
  static List<String> validateMessageForSending(SendMessageRequest request) {
    final errors = <String>[];
    
    final validationError = validateSendMessageRequest(request);
    if (validationError != null) {
      errors.add(validationError);
    }
    
    return errors;
  }
}
