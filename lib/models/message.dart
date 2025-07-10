import 'user.dart';

enum MessageType {
  text,
  image,
  video,
  audio,
}

enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed,
}

class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final User sender;
  final String? content;
  final String? mediaUrl;
  final String? mediaType;
  final String? thumbnailUrl;
  final MessageType messageType;
  final MessageStatus status;
  final DateTime createdAt;
  final DateTime? readAt;

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.sender,
    this.content,
    this.mediaUrl,
    this.mediaType,
    this.thumbnailUrl,
    required this.messageType,
    required this.status,
    required this.createdAt,
    this.readAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id']?.toString() ?? '',
      conversationId: json['conversation_id']?.toString() ?? json['conversationId']?.toString() ?? '',
      senderId: json['sender_id']?.toString() ?? json['senderId']?.toString() ?? '',
      sender: User.fromJson(json['sender'] ?? {}),
      content: json['content'],
      mediaUrl: json['media_url'] ?? json['mediaUrl'],
      mediaType: json['media_type'] ?? json['mediaType'],
      thumbnailUrl: json['thumbnail_url'] ?? json['thumbnailUrl'],
      messageType: _parseMessageType(json['message_type'] ?? json['messageType']),
      status: _parseMessageStatus(json['status']),
      createdAt: DateTime.tryParse(json['created_at'] ?? json['createdAt'] ?? '') 
          ?? DateTime.now(),
      readAt: json['read_at'] != null || json['readAt'] != null
          ? DateTime.tryParse(json['read_at'] ?? json['readAt'] ?? '')
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'sender_id': senderId,
      'sender': sender.toJson(),
      'content': content,
      'media_url': mediaUrl,
      'media_type': mediaType,
      'thumbnail_url': thumbnailUrl,
      'message_type': _messageTypeToString(messageType),
      'status': _messageStatusToString(status),
      'created_at': createdAt.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
    };
  }

  static MessageType _parseMessageType(String? type) {
    switch (type?.toLowerCase()) {
      case 'text':
        return MessageType.text;
      case 'image':
        return MessageType.image;
      case 'video':
        return MessageType.video;
      case 'audio':
        return MessageType.audio;
      default:
        return MessageType.text;
    }
  }

  static MessageStatus _parseMessageStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'sending':
        return MessageStatus.sending;
      case 'sent':
        return MessageStatus.sent;
      case 'delivered':
        return MessageStatus.delivered;
      case 'read':
        return MessageStatus.read;
      case 'failed':
        return MessageStatus.failed;
      default:
        return MessageStatus.sent;
    }
  }

  static String _messageTypeToString(MessageType type) {
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

  static String _messageStatusToString(MessageStatus status) {
    switch (status) {
      case MessageStatus.sending:
        return 'sending';
      case MessageStatus.sent:
        return 'sent';
      case MessageStatus.delivered:
        return 'delivered';
      case MessageStatus.read:
        return 'read';
      case MessageStatus.failed:
        return 'failed';
    }
  }

  Message copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    User? sender,
    String? content,
    String? mediaUrl,
    String? mediaType,
    String? thumbnailUrl,
    MessageType? messageType,
    MessageStatus? status,
    DateTime? createdAt,
    DateTime? readAt,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      sender: sender ?? this.sender,
      content: content ?? this.content,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      mediaType: mediaType ?? this.mediaType,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      messageType: messageType ?? this.messageType,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
    );
  }

  // Helper methods
  bool get isRead => readAt != null;
  bool get isMediaMessage => mediaUrl != null && mediaUrl!.isNotEmpty;
  bool get isTextMessage => messageType == MessageType.text;
  bool get isSending => status == MessageStatus.sending;
  bool get hasFailed => status == MessageStatus.failed;

  String get displayContent {
    if (content != null && content!.isNotEmpty) {
      return content!;
    }

    switch (messageType) {
      case MessageType.image:
        return '📸 Image';
      case MessageType.video:
        return '🎥 Vidéo';
      case MessageType.audio:
        return '🎵 Audio';
      default:
        return '💬 Message';
    }
  }

  String get shortDisplayContent {
    final display = displayContent;
    if (display.length > 50) {
      return '${display.substring(0, 50)}...';
    }
    return display;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Message && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Message(id: $id, type: $messageType, status: $status)';
}
