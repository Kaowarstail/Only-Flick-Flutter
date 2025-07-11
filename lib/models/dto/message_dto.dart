import '../message.dart';

class SendMessageRequest {
  final String conversationId;
  final String? content;
  final String? mediaUrl;
  final String? mediaType;
  final MessageType messageType;

  SendMessageRequest({
    required this.conversationId,
    this.content,
    this.mediaUrl,
    this.mediaType,
    required this.messageType,
  });

  Map<String, dynamic> toJson() {
    return {
      'conversation_id': conversationId,
      'content': content,
      'media_url': mediaUrl,
      'media_type': mediaType,
      'message_type': _messageTypeToString(messageType),
    };
  }

  String _messageTypeToString(MessageType type) {
    switch (type) {
      case MessageType.text:
        return 'text';
      case MessageType.image:
        return 'image';
      case MessageType.video:
        return 'video';
      case MessageType.audio:
        return 'audio';
    }
  }

  // Validation
  bool get isValid {
    // Au moins contenu OU média requis
    final hasContent = content != null && content!.trim().isNotEmpty;
    final hasMedia = mediaUrl != null && mediaUrl!.trim().isNotEmpty;
    
    if (!hasContent && !hasMedia) {
      return false;
    }
    
    // Conversation ID requis
    if (conversationId.trim().isEmpty) {
      return false;
    }
    
    return true;
  }

  String? get validationError {
    if (conversationId.trim().isEmpty) {
      return 'ID de conversation requis';
    }
    
    final hasContent = content != null && content!.trim().isNotEmpty;
    final hasMedia = mediaUrl != null && mediaUrl!.trim().isNotEmpty;
    
    if (!hasContent && !hasMedia) {
      return 'Le message doit contenir du texte ou un média';
    }
    
    return null;
  }
}
