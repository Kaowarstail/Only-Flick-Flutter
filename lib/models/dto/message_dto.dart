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
    
<<<<<<< HEAD
    if (!hasContent && !hasMedia) {
      return false;
    }
    
    // Conversation ID requis
    if (conversationId.trim().isEmpty) {
      return false;
    }
=======
    if (!hasContent && !hasMedia) return false;
    
    // Si média présent, type requis
    if (hasMedia && (mediaType == null || mediaType!.trim().isEmpty)) {
      return false;
    }
    
    // Validation longueur contenu
    if (hasContent && content!.length > 5000) return false;
    
    // Conversation ID requis
    if (conversationId.trim().isEmpty) return false;
>>>>>>> 9e6ce054e4dab9a259c45349328c263edf321aab
    
    return true;
  }

  String? get validationError {
<<<<<<< HEAD
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
=======
    if (!isValid) {
      final hasContent = content != null && content!.trim().isNotEmpty;
      final hasMedia = mediaUrl != null && mediaUrl!.trim().isNotEmpty;
      
      if (conversationId.trim().isEmpty) {
        return 'ID de conversation requis';
      }
      
      if (!hasContent && !hasMedia) {
        return 'Le message doit contenir du texte ou un média';
      }
      
      if (hasMedia && (mediaType == null || mediaType!.trim().isEmpty)) {
        return 'Le type de média est requis';
      }
      
      if (hasContent && content!.length > 5000) {
        return 'Le message est trop long (max 5000 caractères)';
      }
    }
    return null;
  }
}

class MessagesResponse {
  final List<Message> messages;
  final int total;
  final int page;
  final int limit;
  final bool hasMore;
  final int unreadCount;

  MessagesResponse({
    required this.messages,
    required this.total,
    required this.page,
    required this.limit,
    required this.hasMore,
    required this.unreadCount,
  });

  factory MessagesResponse.fromJson(Map<String, dynamic> json) {
    return MessagesResponse(
      messages: (json['messages'] as List<dynamic>? ?? [])
          .map((m) => Message.fromJson(m as Map<String, dynamic>))
          .toList(),
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 50,
      hasMore: json['has_more'] ?? json['hasMore'] ?? false,
      unreadCount: json['unread_count'] ?? json['unreadCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messages': messages.map((m) => m.toJson()).toList(),
      'total': total,
      'page': page,
      'limit': limit,
      'has_more': hasMore,
      'unread_count': unreadCount,
    };
  }
}

class MessageStatsResponse {
  final int totalMessages;
  final int unreadMessages;
  final int mediaMessages;
  final int textMessages;

  MessageStatsResponse({
    required this.totalMessages,
    required this.unreadMessages,
    required this.mediaMessages,
    required this.textMessages,
  });

  factory MessageStatsResponse.fromJson(Map<String, dynamic> json) {
    return MessageStatsResponse(
      totalMessages: json['total_messages'] ?? json['totalMessages'] ?? 0,
      unreadMessages: json['unread_messages'] ?? json['unreadMessages'] ?? 0,
      mediaMessages: json['media_messages'] ?? json['mediaMessages'] ?? 0,
      textMessages: json['text_messages'] ?? json['textMessages'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_messages': totalMessages,
      'unread_messages': unreadMessages,
      'media_messages': mediaMessages,
      'text_messages': textMessages,
    };
  }
}
>>>>>>> 9e6ce054e4dab9a259c45349328c263edf321aab
