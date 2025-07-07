/// Message models for OnlyFlick messaging system
/// Supports text, media, and paid messages with Instagram-style UI

import '../models/user.dart';

enum MessageType {
  text,           // Message texte classique
  image,          // Photo dans le chat
  video,          // Vidéo dans le chat
  paid_text,      // Message payant (texte)
  paid_media,     // Média payant (photo/vidéo)
}

enum MessageStatus {
  sending,        // En cours d'envoi
  sent,          // Envoyé
  delivered,     // Délivré
  read,          // Lu
  failed,        // Échec d'envoi
}

enum MediaType {
  image,
  video,
}

/// Message model with full support for paid content
class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final User sender;
  final MessageType type;
  final String content;
  final String? mediaUrl;
  final String? thumbnailUrl;
  
  // Messages payants
  final bool isPaid;
  final double? price;
  final bool isUnlocked;
  final String? previewContent;
  
  final MessageStatus status;
  final DateTime createdAt;
  final DateTime? readAt;
  final DateTime? updatedAt;

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.sender,
    required this.type,
    required this.content,
    this.mediaUrl,
    this.thumbnailUrl,
    this.isPaid = false,
    this.price,
    this.isUnlocked = true,
    this.previewContent,
    this.status = MessageStatus.sending,
    required this.createdAt,
    this.readAt,
    this.updatedAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id']?.toString() ?? '',
      conversationId: json['conversation_id']?.toString() ?? '',
      senderId: json['sender_id']?.toString() ?? '',
      sender: User.fromJson(json['sender'] ?? {}),
      type: MessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MessageType.text,
      ),
      content: json['content'] ?? '',
      mediaUrl: json['media_url'],
      thumbnailUrl: json['thumbnail_url'],
      isPaid: json['is_paid'] ?? false,
      price: json['price']?.toDouble(),
      isUnlocked: json['is_unlocked'] ?? true,
      previewContent: json['preview_content'],
      status: MessageStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => MessageStatus.sent,
      ),
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      readAt: json['read_at'] != null ? DateTime.tryParse(json['read_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'sender_id': senderId,
      'type': type.name,
      'content': content,
      'media_url': mediaUrl,
      'thumbnail_url': thumbnailUrl,
      'is_paid': isPaid,
      'price': price,
      'is_unlocked': isUnlocked,
      'preview_content': previewContent,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Message copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    User? sender,
    MessageType? type,
    String? content,
    String? mediaUrl,
    String? thumbnailUrl,
    bool? isPaid,
    double? price,
    bool? isUnlocked,
    String? previewContent,
    MessageStatus? status,
    DateTime? createdAt,
    DateTime? readAt,
    DateTime? updatedAt,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      sender: sender ?? this.sender,
      type: type ?? this.type,
      content: content ?? this.content,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      isPaid: isPaid ?? this.isPaid,
      price: price ?? this.price,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      previewContent: previewContent ?? this.previewContent,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Conversation model with participant management
class Conversation {
  final String id;
  final List<String> participantIds;
  final List<User> participants;
  final Message? lastMessage;
  final int unreadCount;
  final DateTime updatedAt;
  final DateTime createdAt;
  final bool isActive;

  Conversation({
    required this.id,
    required this.participantIds,
    required this.participants,
    this.lastMessage,
    this.unreadCount = 0,
    required this.updatedAt,
    required this.createdAt,
    this.isActive = true,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id']?.toString() ?? '',
      participantIds: List<String>.from(json['participant_ids'] ?? []),
      participants: (json['participants'] as List<dynamic>?)
          ?.map((p) => User.fromJson(p))
          .toList() ?? [],
      lastMessage: json['last_message'] != null 
          ? Message.fromJson(json['last_message'])
          : null,
      unreadCount: json['unread_count'] ?? 0,
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participant_ids': participantIds,
      'participants': participants.map((p) => p.toJson()).toList(),
      'last_message': lastMessage?.toJson(),
      'unread_count': unreadCount,
      'updated_at': updatedAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'is_active': isActive,
    };
  }

  /// Get the other participant in a 1-on-1 conversation
  User? getOtherParticipant(String currentUserId) {
    return participants.firstWhere(
      (p) => p.id != currentUserId,
      orElse: () => participants.first,
    );
  }

  /// Check if user is typing (for future implementation)
  bool isUserTyping(String userId) {
    // This would be implemented with WebSocket or polling
    return false;
  }
}

/// Request models for API calls
class SendMessageRequest {
  final String conversationId;
  final String content;
  final MessageType type;
  final String? mediaUrl;
  final String? thumbnailUrl;

  SendMessageRequest({
    required this.conversationId,
    required this.content,
    required this.type,
    this.mediaUrl,
    this.thumbnailUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'conversation_id': conversationId,
      'content': content,
      'type': type.name,
      'media_url': mediaUrl,
      'thumbnail_url': thumbnailUrl,
    };
  }
}

class PaidMessageRequest {
  final String conversationId;
  final String content;
  final MessageType type;
  final double price;
  final String? mediaUrl;
  final String? thumbnailUrl;
  final String? previewContent;

  PaidMessageRequest({
    required this.conversationId,
    required this.content,
    required this.type,
    required this.price,
    this.mediaUrl,
    this.thumbnailUrl,
    this.previewContent,
  });

  Map<String, dynamic> toJson() {
    return {
      'conversation_id': conversationId,
      'content': content,
      'type': type.name,
      'price': price,
      'media_url': mediaUrl,
      'thumbnail_url': thumbnailUrl,
      'preview_content': previewContent,
    };
  }
}

/// Response models for API calls
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final int? statusCode;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.statusCode,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic) fromJson) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      data: json['data'] != null ? fromJson(json['data']) : null,
      message: json['message'],
      statusCode: json['status_code'],
    );
  }
}


